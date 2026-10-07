import 'auth_controller.dart';

/// Public client settings supplied at build time; never contains OAuth secrets.
class AuthConfiguration {
  const AuthConfiguration({
    required this.url,
    required this.publishableKey,
    this.googleEnabled = false,
    this.facebookEnabled = false,
  });

  const AuthConfiguration.fromEnvironment()
    : url = const String.fromEnvironment('SUPABASE_URL'),
      publishableKey = const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      googleEnabled = const bool.fromEnvironment('AUTH_GOOGLE_ENABLED'),
      facebookEnabled = const bool.fromEnvironment('AUTH_FACEBOOK_ENABLED');

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
        !url.contains('YOUR_PROJECT') &&
        publishableKey.startsWith('sb_publishable_') &&
        publishableKey.length > 'sb_publishable_'.length &&
        !publishableKey.contains('REPLACE_WITH');
  }

  Set<SocialAuthProvider> get socialProviders => {
    if (googleEnabled) SocialAuthProvider.google,
    if (facebookEnabled) SocialAuthProvider.facebook,
  };
}
