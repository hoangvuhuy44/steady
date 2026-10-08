import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/serve_web.dart';

void main() {
  late Directory fixture;
  late HttpServer server;
  late HttpClient client;
  setUp(() async {
    fixture = await Directory.systemTemp.createTemp('steady-web-test-');
    final web = await Directory('${fixture.path}/web').create();
    await File('${web.path}/index.html').writeAsString('<html>Steady</html>');
    await File('${web.path}/app.js').writeAsString('window.steady=true;');
    await File('${web.path}/module.wasm').writeAsBytes([0, 97, 115, 109]);
    await File('${fixture.path}/private.txt')
        .writeAsString('PRIVATE_TEST_CANARY');
    server = await startWebServer(
      directory: web,
      address: InternetAddress.loopbackIPv4,
      port: 0,
    );
    client = HttpClient();
  });
  tearDown(() async {
    client.close(force: true);
    await server.close(force: true);
    final tempRoot = await Directory.systemTemp.resolveSymbolicLinks();
    final target = await fixture.resolveSymbolicLinks();
    if (!target.startsWith(
      '$tempRoot${Platform.pathSeparator}steady-web-test-',
    )) {
      throw StateError(
        'Refusing to delete a directory outside this test fixture.',
      );
    }
    await fixture.delete(recursive: true);
  });
  Future<HttpClientResponse> get(String path) async =>
      (await client.getUrl(Uri.parse('http://127.0.0.1:${server.port}$path')))
          .close();

  test(
    'static server serves the build, fresh JS and WebAssembly types',
    () async {
      for (final path in ['/', '/app.js', '/module.wasm']) {
        final response = await get(path);
        expect(response.statusCode, 200);
        expect(
          response.headers.value(HttpHeaders.cacheControlHeader),
          'no-store',
        );
        expect(response.headers.contentType!.mimeType, switch (path) {
          '/' => 'text/html',
          '/app.js' => 'application/javascript',
          _ => 'application/wasm',
        });
        await response.drain<void>();
      }
    },
  );
  test(
    'HEAD and app routes work; missing assets and POST are explicit errors',
    () async {
      final route = await get('/account?code=example');
      expect(route.statusCode, 200);
      expect(await utf8.decoder.bind(route).join(), '<html>Steady</html>');
      final missing = await get('/missing.js');
      expect(missing.statusCode, 404);
      await missing.drain<void>();
      final head = await (await client.openUrl(
        'HEAD',
        Uri.parse('http://127.0.0.1:${server.port}/'),
      )).close();
      expect(head.statusCode, 200);
      expect(await utf8.decoder.bind(head).join(), isEmpty);
      final post = await (await client.postUrl(
        Uri.parse('http://127.0.0.1:${server.port}/'),
      )).close();
      expect(post.statusCode, 405);
      await post.drain<void>();
    },
  );
  test('encoded paths cannot read outside the public web build', () async {
    for (final path in [
      '/%2e%2e%2fprivate.txt',
      '/%5c..%5cprivate.txt',
      '/%00.txt',
    ]) {
      final response = await get(path);
      expect(response.statusCode, 403);
      expect(
        await utf8.decoder.bind(response).join(),
        isNot(contains('PRIVATE_TEST_CANARY')),
      );
    }
  });
}
