import 'package:flutter/material.dart';
// import 'package:my_ad/utils/translation_service/easy_localize.dart';
import 'package:pack/services/service.dart';
import 'package:pack/ui/widgets/network_connectivity_snackbar.dart';
import '../../provider_state/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../routes/app_router.dart';

class MyAdd extends StatelessWidget {
  const MyAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Consumer<AppThemeProvider>(
          builder:
              (ctx, themeProvider, _) => EasyLocalizeApp(
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
                router: AppRouter.router,
                translationsPath: 'assets/translations',
                defaultLocale: Locale('en', 'US'),
                themeProvider: themeProvider

                ,
                child: const SizedBox.shrink(),
              ),
        );
      },
    );
  }
}






