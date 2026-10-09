import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/steady_app.dart';
import 'auth/auth_configuration.dart';
import 'auth/auth_controller.dart';
import 'state/language_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = LanguagePreferences();
  Locale? locale;
  try {
    locale = await preferences.load();
  } catch (_) {
    // Start with the device language if local settings are unavailable.
  }
  AuthController auth = UnconfiguredAuthController();
  final configuration = AuthConfiguration.fromEnvironment();
  // Only modern public client keys are accepted in the app configuration.
  if (configuration.isValid) {
    try {
      await Supabase.initialize(
        url: configuration.url,
        publishableKey: configuration.publishableKey,
      );
      auth = SupabaseAuthController(
        Supabase.instance.client,
        socialProviders: configuration.socialProviders,
      );
    } catch (error) {
      debugPrint('Supabase initialization failed (${error.runtimeType}).');
      // Local Home and check-ins remain available without the auth service.
      auth = UnconfiguredAuthController(initializationFailed: true);
    }
  }
  runApp(
    SteadyApp(
      initialLocale: locale,
      languagePreferences: preferences,
      auth: auth,
    ),
  );
}
