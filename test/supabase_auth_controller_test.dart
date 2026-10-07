import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/auth/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemoryPkceStorage extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // This fixture intentionally uses a local HTTP server. The widget binding's
  // default HTTP override would return 400 before requests reach the fixture.
  final testHttpOverrides = HttpOverrides.current;
  HttpOverrides.global = null;
  tearDownAll(() => HttpOverrides.global = testHttpOverrides);

  test(
    'real SDK creates PKCE OAuth links without treating launch as login',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final launches = <Map<dynamic, dynamic>>[];
      var canLaunch = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'launch') {
              launches.add(call.arguments as Map<dynamic, dynamic>);
              return canLaunch;
            }
            return true;
          });
      final client = SupabaseClient(
        'https://steady-test.supabase.co',
        'sb_publishable_test',
        authOptions: AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.pkce,
          pkceAsyncStorage: MemoryPkceStorage(),
        ),
      );
      final auth = SupabaseAuthController(
        client,
        socialProviders: SocialAuthProvider.values.toSet(),
      );
      addTearDown(() async {
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        auth.dispose();
        await client.dispose();
      });
      for (final provider in SocialAuthProvider.values) {
        await auth.signInWithProvider(provider);
        final launch = launches.last;
        final url = Uri.parse(launch['url'] as String);
        expect(url.host, 'steady-test.supabase.co');
        expect(url.path, '/auth/v1/authorize');
        expect(url.queryParameters['provider'], provider.name);
        expect(url.queryParameters['redirect_to'], authCallbackUrl);
        expect(url.queryParameters['code_challenge'], isNotEmpty);
        expect(url.queryParameters['code_challenge_method'], 's256');
        if (provider == SocialAuthProvider.facebook) {
          expect(url.queryParameters['scopes'], 'email');
        }
        expect(launch['useWebView'], isFalse);
        expect(launch['useSafariVC'], isFalse);
        expect(auth.userId, isNull);
        expect(auth.sessionRevision, 0);
      }
      canLaunch = false;
      await expectLater(
        auth.signInWithProvider(SocialAuthProvider.google),
        throwsStateError,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(auth.socialProviders, isEmpty);
      final count = launches.length;
      await expectLater(
        auth.signInWithProvider(SocialAuthProvider.facebook),
        throwsStateError,
      );
      expect(launches, hasLength(count));
      expect(auth.userId, isNull);
    },
  );

  test('real Supabase SDK login, refresh, repeat events and logout isolate sessions', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var loginCount = 0;
    var tokenCounter = 0;
    final paths = <String>[];
    final signupRedirects = <String?>[];
    final user = {
      'id': 'user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'test@example.com',
      'app_metadata': {'provider': 'email'},
      'user_metadata': <String, dynamic>{},
      'created_at': '2026-10-07T00:00:00Z',
    };
    Map<String, dynamic> sessionJson() {
      final claims = base64Url
          .encode(
            utf8.encode(
              jsonEncode({
                'sub': 'user-1',
                'session_id': 'session-$loginCount',
                'exp':
                    DateTime.now()
                        .add(const Duration(hours: 1))
                        .millisecondsSinceEpoch ~/
                    1000,
                'counter': tokenCounter++,
              }),
            ),
          )
          .replaceAll('=', '');
      return {
        'access_token': 'eyJhbGciOiJIUzI1NiJ9.$claims.test-signature',
        'refresh_token': 'mock-refresh',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': user,
      };
    }

    final listener = server.listen((request) async {
      paths.add(request.uri.path);
      await utf8.decoder.bind(request).join();
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path.endsWith('/token')) {
        if (request.uri.queryParameters['grant_type'] == 'password') {
          loginCount++;
        }
        request.response.write(jsonEncode(sessionJson()));
      } else if (request.uri.path.endsWith('/logout')) {
        request.response.statusCode = HttpStatus.noContent;
      } else if (request.uri.path.endsWith('/signup')) {
        signupRedirects.add(request.uri.queryParameters['redirect_to']);
        request.response.write(jsonEncode(user));
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    });
    final client = SupabaseClient(
      'http://127.0.0.1:${server.port}',
      'mock-publishable',
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: MemoryPkceStorage(),
      ),
    );
    final auth = SupabaseAuthController(client);
    addTearDown(() async {
      auth.dispose();
      await client.dispose();
      await listener.cancel();
      await server.close(force: true);
    });
    expect(auth.userId, isNull);
    await auth.signIn('test@example.com', 'test-password');
    await Future<void>.delayed(Duration.zero);
    expect(auth.userId, 'user-1');
    expect(auth.email, 'test@example.com');
    final revision = auth.sessionRevision;
    final originalToken = client.auth.currentSession!.accessToken;
    await client.auth.refreshSession();
    await Future<void>.delayed(Duration.zero);
    expect(client.auth.currentSession!.accessToken, isNot(originalToken));
    expect(auth.sessionRevision, revision);
    await client.auth.setInitialSession(
      jsonEncode(client.auth.currentSession!.toJson()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(auth.sessionRevision, revision);
    await auth.signIn('test@example.com', 'test-password');
    await Future<void>.delayed(Duration.zero);
    expect(auth.sessionRevision, revision + 1);
    await auth.signOut();
    await Future<void>.delayed(Duration.zero);
    expect(auth.userId, isNull);
    expect(auth.sessionRevision, revision + 2);
    expect(paths.where((p) => p.endsWith('/token')), hasLength(3));
    expect(paths, contains('/auth/v1/logout'));
    expect(await auth.signUp('test@example.com', 'test-password'), isTrue);
    expect(signupRedirects, [authCallbackUrl]);
    expect(auth.userId, isNull);
    await expectLater(
      client.auth.recoverSession('invalid JSON'),
      throwsFormatException,
    );
    await Future<void>.delayed(Duration.zero);
    expect(auth.connectionError, isTrue);
  });
}
