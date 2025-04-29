import 'package:go_router/go_router.dart';
import '../core/data/model/user/user_model.dart';
import 'package:provider/provider.dart';

import '../core/domain/data_store/data_store.dart';
import '../features/all_category/core/all_category_route.dart';
import '../features/category_services/core/category_service_route.dart';
import '../features/chat/screens/call_history_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/chat/screens/inquiry_screen.dart';
import '../features/chat/screens/merchant_chat_screen.dart';
import '../features/ead_products/core/ead_product_navigator.dart';
import '../features/error/error_screen.dart';
import '../features/intro/core/intro_navigator.dart';
import '../features/home/core/home_navigator.dart';
import '../features/intro/core/intro_provider.dart';
import '../features/location/core/location_navigator.dart';
import '../features/all_services/core/all_services_route.dart';
import '../features/merchant/core/merchant_navigation.dart';
import '../features/merchant/merchant_dashboard/core/merchant_dashboard_route.dart';
import '../features/merchant/merchant_notification/core/notification_route.dart';
import '../features/onboarding/core/onboarding_navigator.dart';
import '../features/onboarding/core/onboarding_provider.dart';
import '../features/profile/core/profile_navigator.dart';
import '../features/refer_earn/core/refer_earn_route.dart';
import '../features/terms/core/terms_and_conditiaons_route.dart';
import '../utils/handler/app_navigation_observer.dart';
import 'auth/auth_routes.dart';
import 'package:pack/auth/custom_auth.dart';
import '../features/chat/core/chat_navigator.dart';

class AppRouter {
  // Singleton instance
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  static final initialLocation = '/';

  static final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      IntroRoute.page(),
      OnboardingRoute.page(),
      ...AuthRoutes.pages(),
      HomeRoute.page(),
      LocationRoute.page(),
      AllCategoriesRoute.page(),
      AllServicesRoute.page(),
      EadProductRoute.page(),
      ReferEarnRoute.page(),
      ...MerchantRoute.pages(),
      MerchantDashboardRoute.page(),
      ...TermsRoute.pages(),
      CategoryServicesRoute.page(),
      ProfileNavigator.page(),
      NotificationRoute.page(),
      ...ChatNavigator.pages(),
      
      // Merchant chat routes
      GoRoute(
        path: '/merchant/chat/:merchantId/:merchantName',
        builder: (context, state) {
          final merchantId = state.pathParameters['merchantId'] ?? '';
          final merchantName = state.pathParameters['merchantName'] ?? '';
          
          return MerchantChatScreen(
            merchantId: merchantId,
            merchantName: merchantName,
          );
        },
      ),
      GoRoute(
        path: '/merchant/chat/conversation/:conversationId/:otherUserName/:otherUserImage/:otherUserType/:otherUserId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          final otherUserName = Uri.decodeComponent(state.pathParameters['otherUserName'] ?? '');
          final otherUserImage = Uri.decodeComponent(state.pathParameters['otherUserImage'] ?? '');
          final otherUserType = state.pathParameters['otherUserType'] ?? '';
          final otherUserId = state.pathParameters['otherUserId'] ?? '';
          
          return ChatScreen(
            conversationId: conversationId,
            otherUserName: otherUserName,
            otherUserImage: otherUserImage,
            otherUserType: otherUserType,
            otherUserId: otherUserId,
          );
        },
      ),
      GoRoute(
        path: '/merchant/chat/inquiries',
        builder: (context, state) => const InquiryScreen(),
      ),
      GoRoute(
        path: '/merchant/chat/calls',
        builder: (context, state) => const CallHistoryScreen(),
      ),
    ],
    observers: [AppNavigationObserver()],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    debugLogDiagnostics: true,
    restorationScopeId: null,
    redirect: (context, state) async {
      /// ------------------- [Providers] -------------------
      final introProvider = context.read<IntroProvider>();
      final authProvider = context.read<AuthProviderModel<UserModel>>();
      final onboardingProvider = context.read<OnboardingProvider>();
      final merchantAuthProvider = context.read<MerchantDashboardStore>();

      /// ------------------- [Check onboarding status] -------------------
      final isOnboardingComplete =
          await onboardingProvider.checkOnboardingStatus();

      /// ------------------- [Redirect logics] -------------------
      if (state.matchedLocation == OnboardingRoute.onBoarding &&
          !introProvider.isLoading) {
        /// TOTO: remove "!isOnboardingComplete" and replace with "isOnboardingComplete" to test onboarding
        return !isOnboardingComplete ? '/home' : null;
      }

      if (state.matchedLocation == MerchantRoute.merchantLogin) {
        if (merchantAuthProvider.isLoggedIn) {
          return MerchantDashboardRoute.dashboard;
        }
        return null;
      }
      if (state.matchedLocation == MerchantRoute.merchantRegister) {
        if (merchantAuthProvider.isLoggedIn) {
          return MerchantDashboardRoute.dashboard;
        }
        return null;
      }

      return null;
    },
  );
}
