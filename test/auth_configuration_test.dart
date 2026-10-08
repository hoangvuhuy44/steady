import 'package:flutter_test/flutter_test.dart';
import 'package:steady/auth/auth_configuration.dart';
import 'package:steady/auth/auth_controller.dart';

void main() {
  test('plain flutter run resolves the public Steady project', () {
    final configuration = AuthConfiguration.resolve({});
    expect(configuration.isValid, isTrue);
    expect(configuration.url, 'https://bgcczipzseddvnwpvkhz.supabase.co');
    expect(configuration.socialProviders, isEmpty);
  });
  test(
    'explicit project overrides replace both public connection settings',
    () {
      final configuration = AuthConfiguration.resolve({
        'SUPABASE_URL': ' https://other-project.supabase.co ',
        'SUPABASE_PUBLISHABLE_KEY': ' sb_publishable_other ',
        'AUTH_GOOGLE_ENABLED': 'true',
      });
      expect(configuration.url, 'https://other-project.supabase.co');
      expect(configuration.publishableKey, 'sb_publishable_other');
      expect(configuration.isValid, isTrue);
      expect(configuration.socialProviders, {SocialAuthProvider.google});
    },
  );
  test(
    'partial, empty or secret overrides never fall back to another project',
    () {
      for (final override in [
        {'SUPABASE_URL': 'https://other-project.supabase.co'},
        {'SUPABASE_PUBLISHABLE_KEY': 'sb_publishable_other'},
        {'SUPABASE_URL': '', 'SUPABASE_PUBLISHABLE_KEY': ''},
        {
          'SUPABASE_URL': 'https://other-project.supabase.co',
          'SUPABASE_PUBLISHABLE_KEY': 'sb_secret_private',
        },
      ]) {
        expect(AuthConfiguration.resolve(override).isValid, isFalse);
      }
    },
  );
  test('API URL cannot contain callbacks, credentials or REST paths', () {
    for (final url in [
      'https://steady-test.supabase.co/auth/v1',
      'https://steady-test.supabase.co/?key=value',
      'https://steady-test.supabase.co/#callback',
      'https://user:password@steady-test.supabase.co',
    ]) {
      expect(
        AuthConfiguration(
          url: url,
          publishableKey: 'sb_publishable_test',
        ).isValid,
        isFalse,
      );
    }
  });
  test(
    'web callback keeps origin/path and removes previous auth parameters',
    () {
      for (final value in [
        'http://localhost:3000/?code=old-code',
        'http://localhost:3000/#access_token=old-token',
        'http://localhost:3000/?error=access_denied#description=cancelled',
      ]) {
        expect(webAuthRedirectUrl(Uri.parse(value)), 'http://localhost:3000/');
      }
      expect(
        webAuthRedirectUrl(Uri.parse('https://steady.example/app/?code=old')),
        'https://steady.example/app/',
      );
    },
  );

  test('email needs a real URL and public client key', () {
    expect(
      const AuthConfiguration(url: '', publishableKey: '').isValid,
      isFalse,
    );
    expect(
      const AuthConfiguration(
        url: 'https://YOUR_PROJECT_REF.supabase.co',
        publishableKey: 'sb_publishable_REPLACE_WITH_YOUR_KEY',
      ).isValid,
      isFalse,
    );
    for (final key in [
      'sb_secret_private',
      'service_role',
      'sb_publishable_',
    ]) {
      expect(
        AuthConfiguration(
          url: 'https://steady-test.supabase.co',
          publishableKey: key,
        ).isValid,
        isFalse,
      );
    }
    expect(
      const AuthConfiguration(
        url: 'https://steady-test.supabase.co',
        publishableKey: 'sb_publishable_test',
      ).isValid,
      isTrue,
    );
  });

  test('social providers are explicitly enabled independently', () {
    const emailOnly = AuthConfiguration(url: '', publishableKey: '');
    expect(emailOnly.socialProviders, isEmpty);
    const google = AuthConfiguration(
      url: '',
      publishableKey: '',
      googleEnabled: true,
    );
    expect(google.socialProviders, {SocialAuthProvider.google});
    const both = AuthConfiguration(
      url: '',
      publishableKey: '',
      googleEnabled: true,
      facebookEnabled: true,
    );
    expect(both.socialProviders, SocialAuthProvider.values.toSet());
  });
}
