import 'package:go_router/go_router.dart';
import '../core/data/model/user/user_model.dart';
import 'package:provider/provider.dart';

import '../core/domain/data_store/data_store.dart';
import '../core/injector/dependency_injection.dart';
import '../features/merchant/merchant_profile_edit/core/edit_profile_navigator.dart';
import '../features/myad_categories/core/all_category_route.dart';
import '../features/category_services/core/category_service_route.dart';
import '../features/chat_feature/route/routes.dart';
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
import '../features/post_requirement/core/route.dart';
import '../features/profile/core/profile_navigator.dart';
import '../features/refer_earn/core/refer_earn_route.dart';
import '../features/support/core/support_provider.dart';
import '../features/support/ui/support_screen.dart';
import '../features/terms/core/terms_and_conditions_route.dart';
import '../utils/handler/app_navigation_observer.dart';
import 'auth/auth_routes.dart';
import 'package:pack/auth/custom_auth.dart';

class AppRouter {
  // Singleton instance
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  /// TODO: uncomment if later for this project uses
  static final initialLocation = '/';
  // static final initialLocation = '/demo';

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
      ...ChatFeatureRoutes.page(),
      PostRequirementRoute.page(),
      EditMerchantProfileNavigator.page(),
      SupportNavigator.page(),
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
