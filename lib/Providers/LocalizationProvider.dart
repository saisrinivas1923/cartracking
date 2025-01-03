import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocalizationProvider() {
    _loadLocaleFromPrefs();
  }

  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(savedLanguageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', newLocale.languageCode);
    }
  }
}
