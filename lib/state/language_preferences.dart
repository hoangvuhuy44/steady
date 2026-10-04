import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Only the language choice is persisted, never health or nutrition data.
class LanguagePreferences {
  static const key = 'steady.language';
  Future<Locale?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(key);
    return code == 'en' || code == 'vi' ? Locale(code!) : null;
  }

  Future<void> save(Locale? locale) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = locale == null
        ? await preferences.remove(key)
        : await preferences.setString(key, locale.languageCode);
    if (!saved) throw StateError('Could not save language preference');
  }
}
