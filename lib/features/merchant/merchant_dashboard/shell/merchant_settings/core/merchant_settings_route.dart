import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_settings/core/privacy_security_manager.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_settings/core/service_manager.dart';
import 'package:pack/services/version_tracker/app_version_tracker.dart';
import 'package:provider/provider.dart';

import '../../../../../../provider_state/theme_provider.dart';
import '../merchant_settings.dart';
import 'notification_manager.dart';
import 'settings_provider.dart';

class MerchantSettingsRoute {
  static String settings = '/settings';

  static GoRoute page() {
    return GoRoute(
      path: settings,
      builder:
          (ctx, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AppThemeProvider()),
              ChangeNotifierProvider(create: (_) => AppVersionTracker()),
              ChangeNotifierProvider(create: (_) => ServiceManager()),
              ChangeNotifierProvider(create: (_) => NotificationManager()),
              ChangeNotifierProvider(create: (_) => PrivacySecurityManager()),
              Provider(create: (_) => SettingsProvider(ctx)),
            ],
            child: SettingsProviderWrapper(child: MerchantSettingsPage()),
          ),
    );
  }
}
