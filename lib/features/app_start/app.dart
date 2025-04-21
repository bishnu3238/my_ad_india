import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';

import 'other_package_injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalizeApp(
      supportedLocales: [
        Locale('en', 'US'), // English
        Locale('hi', 'IN'), // Hindi
        Locale('bn', 'IN'), // Bengali
        Locale('sa', 'IN'), // Sanskrit
        Locale('ja', 'JP'), // Japanese
        Locale('zh', 'CN'), // Chinese (Simplified)
        Locale('fr', 'FR'), // French
        Locale('kn', 'IN'), // Kannada
        Locale('ta', 'IN'), // Tamil
        // Add more locales as needed
      ],
      translationsPath: 'assets/translations',
      defaultLocale: Locale('en', 'US'),
      child: OtherPackageInjection(),
    );
  }
}
