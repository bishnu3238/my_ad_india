// File: easy_localize_extensions.dart
import 'package:flutter/material.dart';
import 'easy_localize.dart';
import 'easy_localize_provider.dart';

extension EasyLocalizeExtension on BuildContext {
  EasyLocalize get easyLocalize => EasyLocalizeProvider.of(this).easyLocalize;

  String tr(String key, {Map<String, dynamic>? args}) {
    return easyLocalize.translate(key, args: args);
  }

  String plural(String key, int count, {Map<String, dynamic>? args}) {
    return easyLocalize.translatePlural(key, count, args: args);
  }

  Locale get locale => easyLocalize.currentLocale;

  Future<void> setLocale(Locale locale) {
    return easyLocalize.setLocale(locale);
  }
}
