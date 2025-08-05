import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppLocalizations
/// Handles loading and translation of strings from JSON files
class AppLocalizations {
  AppLocalizations(this.locale){
    _localizedStrings = <String, String>{ };
  }

  /// Gets the current instance from context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Static delegate for localization
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  final Locale locale;
  late Map<String, String> _localizedStrings;

  /// Loads translation file for current locale
  Future<void> load() async {
    String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  /// Translates a key to current language
  String? translate(String key) {
    return _localizedStrings[key];
  }
}

/// Custom localization delegate
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
