import 'package:flutter/material.dart';

import 'app/steady_app.dart';
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
  runApp(SteadyApp(initialLocale: locale, languagePreferences: preferences));
}
