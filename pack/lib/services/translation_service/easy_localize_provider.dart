// File: easy_localize_provider.dart
import 'package:flutter/material.dart';
import 'easy_localize.dart';

class EasyLocalizeProvider extends InheritedWidget {
  final EasyLocalize easyLocalize;

  const EasyLocalizeProvider({
    Key? key,
    required this.easyLocalize,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(EasyLocalizeProvider oldWidget) {
    return true;
  }

  static EasyLocalizeProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<EasyLocalizeProvider>();
    if (provider == null) {
      throw Exception('No EasyLocalizeProvider found in context');
    }
    return provider;
  }
}
