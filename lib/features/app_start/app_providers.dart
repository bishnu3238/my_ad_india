import 'package:flutter/cupertino.dart';
import 'package:pack/services/version_tracker/app_version_tracker.dart';
import 'package:provider/provider.dart';

import '../../core/injector/dependency_injection.dart';
import '../../core/services/merchant_auth_service.dart';
import '../../provider_state/theme_provider.dart';
import '../merchant/core/merchant_auth_provider.dart';
import '../chat/services/chat_manager.dart';
import '../merchant/merchant_notification/core/notification_module.dart';
import 'screen_providers.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (ctx) => MerchantAuthProvider(
                DependencyInjector.get<MerchantAuthService>(),
              ),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (x) => DependencyInjector.get<AppThemeProvider>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<AppVersionTracker>(),
        ),
        ...NotificationModule.providers(),
        ChangeNotifierProvider(
          create: (ctx) => ChatManager(),
        ),

      ],
      child: ScreenProviders(),
    );
  }
}
