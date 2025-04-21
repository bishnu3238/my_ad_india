import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
import 'package:pack/ui/widgets/network_connectivity_snackbar.dart';
import '../../provider_state/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../routes/app_router.dart';

class MyAdd extends StatelessWidget {
  const MyAdd({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<AppThemeProvider>(
      builder:
          (ctx, themeProvider, _) => MaterialApp.router(
            title: "MyAd",
            debugShowCheckedModeBanner: false,

            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: _getThemeModeForMaterialApp(themeProvider),
            routerConfig: AppRouter.router,
            locale: context.locale,
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
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
    );
  }
}

ThemeMode _getThemeModeForMaterialApp(AppThemeProvider themeProvider) {
  switch (themeProvider.currentThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
}




