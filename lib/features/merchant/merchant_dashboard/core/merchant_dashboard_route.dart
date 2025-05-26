// Navigation Routes for Merchant Admin Dashboard
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/domain/data_store/merchant_dashboard_store.dart';
import 'package:my_ad/core/services/merchant_auth_service.dart';
import 'package:my_ad/features/chat_feature/core/services/socket_services.dart';
import 'package:my_ad/features/chat_feature/route/routes.dart';
import 'package:my_ad/features/merchant/merchant_add_service/merchant_add_service_screen.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/review/merchant_reviews.dart';
import 'package:pack/extensions/extensions.dart';
// import 'package:my_ad/features/chat/screens/chat_screen.dart';
// import 'package:my_ad/features/chat/screens/conversation_list_screen.dart';
// import 'package:my_ad/features/chat/widgets/empty_chat_view.dart';
import 'package:pack/ui/widgets/loading/advance_shimmer_loading_ui.dart';
import 'package:provider/provider.dart';
import '../../../chat_feature/screens/chat/chat_list_screen.dart';

import '../../../../core/injector/dependency_injection.dart';
import '../../../../core/services/merchant_dashboard_service.dart';
// import '../../../chat/screens/inquiry_screen.dart';
import '../../customer_inquiries/customer_inquiries.dart';
import '../../subscription/core/subscription_plan_route.dart';
import '../merchant_dashboard_shell.dart';
import '../shell/dashboard/dashboard.dart';
import '../shell/merchant_add_service/core/merchant_add_service_route.dart';
import '../shell/merchant_services/core/merchant_services_route.dart';

import '../shell/merchant_services/merchant_services_screen.dart';
import '../shell/profile/profile.dart';
import '../shell/report/report.dart';
import '../shell/review/core/merchant_review_provider.dart';
import 'merchant_dashboard_shell_provider.dart';
import '../../../chat_feature/screens/chat/chat_list_screen.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../chat_feature/core/services/chat_list_service.dart';
import '../../../chat_feature/core/services/api_client.dart';
import 'package:pack/services/service.dart';
import '../../../chat_feature/core/provider/chat_list_provider.dart';

class MerchantDashboardRoute {
  static const String dashboard = '/merchant/dashboard';
  static const String plans = '/merchant/plans';
  static const String chatList = '/chat-list';
  static const String recentInquiries  = '/recent-inquiries';

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
            // MerchantServicesRoute.page(_services),
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
          builder: (context, state) {
            final merchantId =
                context.read<MerchantDashboardStore>().entity!.id;

            return ChangeNotifierProvider(
              create:
                  (ctx) => MerchantReviewProvider(
                    DependencyInjector.get<ReviewService>(),
                    merchantId: merchantId,
                  ),

              child: const MerchantReviews(),
            );
          },
          // builder: (context, state) => const MerchantReportsScreen(),
        ),
      ],
    ),
    // Services Branch
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: services,
          builder: (context, state) => const MerchantServicesScreen(),
        ),
      ],
    ),
/// TODO: comment this and uncomment ChatListScreen when the chat service is ready
//     StatefulShellBranch(
//       routes: [
//         GoRoute(
//           path: recentInquiries,
//           builder: (context, state) => const CustomerInquiriesPage(),
//         ),
//       ],
//     ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: chatList,
          builder: (ctx, state) {
            final userId = ctx.read<MerchantDashboardStore>().entity!.id.toInt;
            return ChangeNotifierProvider(
              create:
                  (ctx) => ChatListProvider(
                    chatListService: ChatListService(
                      apiClient: ApiClient(
                        baseUrl: ApiConfig.baseChatUrl,
                        api: DependencyInjector.get<ApiCallService>(),
                      ),
                    ),
                  ),
              child: ChatListScreen(
                userType: 'merchant',
                userId: userId,
                onChatTap: (conv) {
                  dev.log("GOING CHAT SCREEN: $conv");
                  ChatFeatureRoutes.goToChatScreen(
                    ctx,
                    conv.customerId,
                    conv.merchantId,
                    'merchant',
                    conv.customerName ?? 'Customer',
                  );
                },
              ),
            );
          },
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
