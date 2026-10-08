// Explicit diagnostic only: no real account, email or password is used.
// flutter test tool/auth_service_probe_test.dart --dart-define=RUN_LIVE_AUTH_PROBE=true
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/auth/auth_configuration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'bundled configuration reaches the real password Auth endpoint',
    () async {
      final configuration = AuthConfiguration.fromEnvironment();
      expect(configuration.isValid, isTrue);
      final client = SupabaseClient(
        configuration.url,
        configuration.publishableKey,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      try {
        await expectLater(
          client.auth.signInWithPassword(
            email: 'steady-auth-probe@invalid.example',
            password: 'NotARealUserPassword_2026_probe',
          ),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'invalid_credentials',
            ),
          ),
        );
        expect(client.auth.currentSession, isNull);
      } finally {
        await client.dispose();
      }
    },
    skip: !const bool.fromEnvironment('RUN_LIVE_AUTH_PROBE'),
  );
}
