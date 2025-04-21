import 'dart:developer' as dev;

 import 'package:go_router/go_router.dart';
import 'package:my_ad/features/settings/core/settins_navigator.dart';
import '../../../core/injector/dependency_injection.dart';
import 'package:provider/provider.dart';

 import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';

import '../../all_category/core/all_category_route.dart';
 import '../../merchant/merchant_registration/core/merchant_registration_view_model.dart';
import '../../merchant/merchant_registration/merchant_registration_screen.dart';
import '../home_page.dart';
import '../shell/home_screen/home_screen.dart';
import '../shell/profile_settings_screen/settings/setting_screen.dart';
import '../shell/search/search_screen.dart';
  import 'home_provider.dart';

class HomeRoute {
  static const String home = '/home';
  static const String search = '/search';
  static const String addContent = '/ads-content';
  static const String category = '/category';
  static const String setting = '/setting';

  static StatefulShellRoute page() => StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return NetworkConnectivitySnackBar(
        connectivityService: DependencyInjector.get<ConnectivityService>(),
        child: ChangeNotifierProvider(
          create:
              (ctx) =>
                  HomeProvider(shell: navigationShell)..checkShowPopupStatus(),
          child: HomePage(navigationShell: navigationShell),
        ),
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder:
                (context, state) => NoTransitionPage(child: HomeScreen()),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: search,
            builder:
                (context, state) => SearchScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/ads-content',
            builder:
                (context, state) => ChangeNotifierProvider(
                  create:
                      (ctx) =>
                          DependencyInjector.get<
                            MerchantRegistrationViewModel
                          >(),
                  child: MerchantRegistrationScreen(),
                ),
          ),
        ],
      ),
      StatefulShellBranch(routes: [AllCategoriesRoute.page()]),
      StatefulShellBranch(
        preload: true,
        routes: [
          GoRoute(path: setting, builder: (ctx, state) => ProfileSettingsScreen(), routes: [
            SettingNavigator.page()
          ]),
        ],
      ),
    ],
  );
}

