import 'auth_controller.dart';
import 'public_auth_config.dart';

/// Public client settings; optional build-time overrides replace the project.
class AuthConfiguration {
  const AuthConfiguration({
    required this.url,
    required this.publishableKey,
    this.googleEnabled = false,
    this.facebookEnabled = false,
  });

  factory AuthConfiguration.fromEnvironment() => AuthConfiguration.resolve({
    if (const bool.hasEnvironment('SUPABASE_URL'))
      'SUPABASE_URL': const String.fromEnvironment('SUPABASE_URL'),
    if (const bool.hasEnvironment('SUPABASE_PUBLISHABLE_KEY'))
      'SUPABASE_PUBLISHABLE_KEY': const String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
    'AUTH_GOOGLE_ENABLED': const String.fromEnvironment('AUTH_GOOGLE_ENABLED'),
    'AUTH_FACEBOOK_ENABLED': const String.fromEnvironment(
      'AUTH_FACEBOOK_ENABLED',
    ),
  });

  /// Plain `flutter run` and fresh clones use the same public Steady project.
  /// A partial/invalid override fails closed instead of mixing two projects.
  factory AuthConfiguration.resolve(Map<String, String> environment) {
    final override =
        environment.containsKey('SUPABASE_URL') ||
        environment.containsKey('SUPABASE_PUBLISHABLE_KEY');
    return AuthConfiguration(
      url: override
          ? (environment['SUPABASE_URL'] ?? '').trim()
          : steadySupabaseUrl,
      publishableKey: override
          ? (environment['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim()
          : steadySupabasePublishableKey,
      googleEnabled: environment['AUTH_GOOGLE_ENABLED'] == 'true',
      facebookEnabled: environment['AUTH_FACEBOOK_ENABLED'] == 'true',
    );
  }

  final String url;
  final String publishableKey;
  final bool googleEnabled;
  final bool facebookEnabled;

  bool get isValid {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        (uri.path.isEmpty || uri.path == '/') &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        !url.contains('YOUR_PROJECT') &&
        RegExp(r'^sb_publishable_[A-Za-z0-9_-]+$').hasMatch(publishableKey) &&
        !publishableKey.contains('REPLACE_WITH');
  }

  Set<SocialAuthProvider> get socialProviders => {
    if (googleEnabled) SocialAuthProvider.google,
    if (facebookEnabled) SocialAuthProvider.facebook,
  };
}
