import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('vi'), // Vietnamese
  ];

  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'vi': 'Tiếng Việt',
  };

  // Language names with flags
  static const Map<String, String> languageNamesWithFlags = {
    'en': '🇬🇧  English',
    'vi': '🇻🇳  Tiếng Việt',
  };

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }

  String getCurrentLanguageName() {
    return languageNames[_locale.languageCode] ?? 'English';
  }
}
