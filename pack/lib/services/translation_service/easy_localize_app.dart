// File: easy_localize_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pack/services/translation_service/easy_localize_builder.dart';
import 'easy_localize.dart';
import 'easy_localize_provider.dart';

class EasyLocalizeApp extends StatefulWidget {
  final Widget child;
  final Locale defaultLocale;
  final List<Locale> supportedLocales;
  final String translationsPath;

  const EasyLocalizeApp({
    super.key,
    required this.child,
    required this.defaultLocale,
    required this.supportedLocales,
    this.translationsPath = 'assets/translations',
  });

  @override
  _EasyLocalizeAppState createState() => _EasyLocalizeAppState();
}

class _EasyLocalizeAppState extends State<EasyLocalizeApp> {
  final EasyLocalize _easyLocalize = EasyLocalize();
  late Locale _currentLocale;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  Future<void> _initializeLocalization() async {
    await _easyLocalize.initialize(
      defaultLocale: widget.defaultLocale,
      supportedLocales: widget.supportedLocales,
      path: widget.translationsPath,
    );

    _currentLocale = _easyLocalize.currentLocale;
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return EasyLocalizeProvider(
      easyLocalize: _easyLocalize,
      child: EasyLocalizeBuilder(
        builder: (context, locale) {
          return MaterialApp(
            locale: locale,
            supportedLocales: widget.supportedLocales,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: widget.child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _easyLocalize.dispose();
    super.dispose();
  }
}
