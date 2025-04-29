// Navigation Routes for Merchant Admin Dashboard
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/services/merchant_auth_service.dart';
import 'package:my_ad/features/chat/screens/chat_screen.dart';
import 'package:my_ad/features/chat/screens/conversation_list_screen.dart';
import 'package:my_ad/features/chat/widgets/empty_chat_view.dart';
import 'package:pack/ui/widgets/loading/advance_shimmer_loading_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/injector/dependency_injection.dart';
import '../../../../core/services/merchant_dashboard_service.dart';
import '../../../chat/screens/inquiry_screen.dart';
import '../../subscription/core/subscription_plan_route.dart';
import '../merchant_dashboard_shell.dart';
import '../shell/dashboard/dashboard.dart';
import '../shell/merchant_add_service/core/merchant_add_service_route.dart';
import '../shell/merchant_services/core/merchant_services_route.dart';

import '../shell/merchant_services/merchant_services_screen.dart';
import '../shell/profile/profile.dart';
import '../shell/report/report.dart';
import 'merchant_dashboard_shell_provider.dart';

class MerchantDashboardRoute {
  static const String dashboard = '/merchant/dashboard';
  static const String plans = '/merchant/plans';
  static const String chatScreen = '/merchant/chatScreen';

  static const String banners = '/merchant/banners';
  static const String videos = '/merchant/videos';
  static const String reports = '/merchant/reports';
  static const String customers = '/merchant/customers';
  static const String profile = '/merchant/profile';

  // sub-routes full path
  static const String services = dashboard + _services;
  static const String addService = dashboard + _addService;
  static const String subscription = dashboard + _subscription;

  // Sub-routes
  static const String _addService = '/add-service';
  static const String _services = '/services';
  static const String _subscription = '/subscription';

  static final List<StatefulShellBranch> branches = [
    // Dashboard Branch
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: dashboard,
          builder: (context, state) => const MerchantDashboardHome(),
          routes: [
            MerchantAddServiceRoute.page(_addService),
            MerchantServicesRoute.page(_services),
            SubscriptionPlanRoute.page(_subscription),
          ],
        ),
      ],
    ),
    // Analytics Branch
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: reports,
          builder: (context, state) => const InquiryScreen(),
        ),
      ],
    ),
    // Services Branch
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: services,
          // builder: (context, state) => const MerchantServicesScreen(),
          builder: (context, state) => const MerchantServicesScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: chatScreen,
          builder: (context, state) =>   ConversationListScreen(),
        ),
      ],
    ),
    // Profile Branch
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: profile,
          builder: (context, state) => const MerchantProfileScreen(),
        ),
      ],
    ),
  ];

  static StatefulShellRoute page() => StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return ChangeNotifierProvider(
        create:
            (ctx) => MerchantDashboardShellProvider(
              DependencyInjector.get<MerchantAuthService>(),
              DependencyInjector.get<MerchantDashboardService>(),
              shell: navigationShell,
            ),
        child: MerchantDashboardShell(navigationShell: navigationShell),
      );
    },
    branches: branches,
  );
}
