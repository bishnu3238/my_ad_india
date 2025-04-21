// File: easy_localize.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


 export 'easy_localize_builder.dart';
export 'easy_localize_app.dart';
export 'easy_localize_extensions.dart';
export 'language_selector.dart';
export 'package:flutter_localizations/flutter_localizations.dart';

class EasyLocalize {
  // Singleton instance
  static final EasyLocalize _instance = EasyLocalize._internal();
  factory EasyLocalize() => _instance;
  EasyLocalize._internal();

  // Private fields
  late Locale _currentLocale;
  late List<Locale> _supportedLocales;
  late Map<String, Map<String, dynamic>> _localizedValues = {};
  late StreamController<Locale> _localeController;
  final String _prefsKey = 'selected_locale';

  // Getters
  Locale get currentLocale => _currentLocale;
  Stream<Locale> get localeStream => _localeController.stream;

  // Initialize the localization service
  Future<void> initialize({
    required Locale defaultLocale,
    required List<Locale> supportedLocales,
    required String path,
  }) async {
    _localeController = StreamController<Locale>.broadcast();
    _supportedLocales = supportedLocales;

    // Load saved locale or use default
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleString = prefs.getString(_prefsKey);

    if (savedLocaleString != null) {
      final parts = savedLocaleString.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      } else {
        _currentLocale = Locale(parts[0], '');
      }
    } else {
      _currentLocale = defaultLocale;
    }

    // Ensure the saved locale is supported
    bool isSupported = false;
    for (var locale in supportedLocales) {
      if (locale.languageCode == _currentLocale.languageCode) {
        isSupported = true;
        break;
      }
    }

    if (!isSupported) {
      _currentLocale = defaultLocale;
    }

    // Load all translations
    await _loadAllTranslations(path);

    // Notify listeners
    _localeController.add(_currentLocale);
  }

  // Load translations for all supported locales
  Future<void> _loadAllTranslations(String path) async {
    for (var locale in _supportedLocales) {
      final langCode = locale.languageCode;
      final countryCode = locale.countryCode;

      String filePath;
      if (countryCode == null || countryCode.isEmpty) {
        filePath = '$path/$langCode.json';
      } else {
        filePath = '$path/${langCode}_$countryCode.json';
      }

      try {
        final jsonString = await rootBundle.loadString(filePath);
        final Map<String, dynamic> values = json.decode(jsonString);
        _localizedValues[langCode] = values;
      } catch (e) {
        print('Error loading language file: $filePath');
        print(e);
      }
    }
  }

  // Change the current locale
  Future<void> setLocale(Locale locale) async {
    // Check if locale is supported
    bool isSupported = false;
    for (var supportedLocale in _supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        isSupported = true;
        break;
      }
    }

    if (!isSupported) {
      throw Exception('Locale $locale is not supported');
    }

    _currentLocale = locale;

    // Save selected locale
    final prefs = await SharedPreferences.getInstance();
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      await prefs.setString(_prefsKey, '${locale.languageCode}_${locale.countryCode}');
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }

    // Notify listeners
    _localeController.add(locale);
  }

  // Get a translated string
  String translate(String key, {Map<String, dynamic>? args}) {
    final langCode = _currentLocale.languageCode;

    if (!_localizedValues.containsKey(langCode)) {
      print('No translations available for $langCode');
      return key;
    }

    final translations = _localizedValues[langCode]!;

    if (!translations.containsKey(key)) {
      print('No translation found for key: $key in $langCode');
      return key;
    }

    String value = translations[key].toString();

    // Handle parameter substitution
    if (args != null && args.isNotEmpty) {
      args.forEach((argKey, argValue) {
        value = value.replaceAll('{$argKey}', argValue.toString());
      });
    }

    return value;
  }

  // Translate with plurals
  String translatePlural(String key, int count, {Map<String, dynamic>? args}) {
    final langCode = _currentLocale.languageCode;

    if (!_localizedValues.containsKey(langCode)) {
      return key;
    }

    final translations = _localizedValues[langCode]!;

    if (!translations.containsKey(key)) {
      return key;
    }

    final Map<String, dynamic> pluralForms = translations[key];

    String? pluralKey;
    if (count == 0 && pluralForms.containsKey('zero')) {
      pluralKey = 'zero';
    } else if (count == 1 && pluralForms.containsKey('one')) {
      pluralKey = 'one';
    } else if (count == 2 && pluralForms.containsKey('two')) {
      pluralKey = 'two';
    } else {
      pluralKey = 'other';
    }

    if (!pluralForms.containsKey(pluralKey)) {
      return key;
    }

    String value = pluralForms[pluralKey].toString();

    // Handle parameter substitution
    Map<String, dynamic> allArgs = args ?? {};
    allArgs['count'] = count;

    allArgs.forEach((argKey, argValue) {
      value = value.replaceAll('{$argKey}', argValue.toString());
    });

    return value;
  }

  // Clean up resources
  void dispose() {
    _localeController.close();
  }
}






// File: pubspec.yaml additions
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.0

flutter:
  assets:
    - assets/translations/
*/