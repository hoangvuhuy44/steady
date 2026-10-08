import 'dart:io';

// A static release-build server, independent of an IDE/debugging session.
// Run after `flutter build web`: dart run tool/serve_web.dart
Future<void> main(List<String> arguments) async {
  final options = <String, String>{};
  for (final argument in arguments) {
    final parts = argument.split('=');
    if (parts.length != 2 ||
        !{'--host', '--port', '--root'}.contains(parts[0])) {
      stderr.writeln(
        'Usage: dart run tool/serve_web.dart --host=0.0.0.0 --port=3000 --root=build/web',
      );
      exitCode = 64;
      return;
    }
    options[parts[0]] = parts[1];
  }
  try {
    final server = await startWebServer(
      directory: Directory(options['--root'] ?? 'build/web'),
      address: InternetAddress(options['--host'] ?? '0.0.0.0'),
      port: int.parse(options['--port'] ?? '3000'),
    );
    stdout.writeln('Steady: http://127.0.0.1:${server.port}/');
    stdout.writeln(
      'Other devices: http://<this computer LAN IPv4>:${server.port}/',
    );
    stdout.writeln(
      'Listening on ${server.address.address}. Keep this process running.',
    );
  } catch (error) {
    stderr.writeln('Cannot start Steady server: $error');
    exitCode = 1;
  }
}

Future<HttpServer> startWebServer({
  required Directory directory,
  InternetAddress? address,
  int port = 3000,
}) async {
  final root = await directory.resolveSymbolicLinks();
  if (!await File('$root${Platform.pathSeparator}index.html').exists()) {
    throw StateError('Missing index.html. Run flutter build web first.');
  }
  final server = await HttpServer.bind(
    address ?? InternetAddress.anyIPv4,
    port,
  );
  server.listen((request) async {
    try {
      if (request.method != 'GET' && request.method != 'HEAD') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        request.response.headers.set(HttpHeaders.allowHeader, 'GET, HEAD');
        return;
      }
      final segments = request.uri.pathSegments
          .where((part) => part.isNotEmpty)
          .toList();
      if (segments.any(
        (part) =>
            part == '..' ||
            part == '.' ||
            part.contains('/') ||
            part.contains('\\') ||
            part.contains('\u0000'),
      )) {
        request.response.statusCode = HttpStatus.forbidden;
        return;
      }
      var file = File(
        [
          root,
          ...segments,
          if (segments.isEmpty) 'index.html',
        ].join(Platform.pathSeparator),
      );
      if (!await file.exists() &&
          (segments.isEmpty || !segments.last.contains('.'))) {
        file = File('$root${Platform.pathSeparator}index.html');
      }
      if (!await file.exists()) {
        request.response.statusCode = HttpStatus.notFound;
        return;
      }
      final resolved = await file.resolveSymbolicLinks();
      final prefix = '$root${Platform.pathSeparator}';
      if (!(Platform.isWindows
          ? resolved.toLowerCase().startsWith(prefix.toLowerCase())
          : resolved.startsWith(prefix))) {
        request.response.statusCode = HttpStatus.forbidden;
        return;
      }
      final extension = file.path.split('.').last.toLowerCase();
      request.response.headers.set(
        HttpHeaders.contentTypeHeader,
        _types[extension] ?? 'application/octet-stream',
      );
      request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
      request.response.headers.set('X-Content-Type-Options', 'nosniff');
      request.response.contentLength = await file.length();
      if (request.method == 'GET') {
        await request.response.addStream(file.openRead());
      }
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
      } catch (_) {
        // A disconnected client may already have closed the response headers.
      }
    } finally {
      try {
        await request.response.close();
      } catch (_) {
        // One interrupted download must not stop the server for all testers.
      }
    }
  });
  return server;
}

const _types = {
  'html': 'text/html; charset=utf-8',
  'js': 'application/javascript',
  'mjs': 'application/javascript',
  'json': 'application/json',
  'css': 'text/css',
  'wasm': 'application/wasm',
  'svg': 'image/svg+xml',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'webp': 'image/webp',
  'ico': 'image/x-icon',
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'woff': 'font/woff',
  'woff2': 'font/woff2',
};
