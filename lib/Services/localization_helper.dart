import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationHelper {
  final Locale locale;
  static Map<String, String>? _localizedStrings;

  LocalizationHelper(this.locale);

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }

  static LocalizationHelper of(BuildContext context) {
    return Localizations.of<LocalizationHelper>(context, LocalizationHelper)!;
  }
}

class LocalizationDelegate extends LocalizationsDelegate<LocalizationHelper> {
  final Locale newLocale;

  const LocalizationDelegate(this.newLocale);

  @override
  bool isSupported(Locale locale) {
    // Checks if the locale is supported by comparing its language code
    return ['en', 'hi','te'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationHelper> load(Locale locale) async {
    // Loads the localization data for the provided locale
    LocalizationHelper localization = LocalizationHelper(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<LocalizationHelper> old) {
    // Returns false since there's no need to reload the localization
    return false;
  }
}
