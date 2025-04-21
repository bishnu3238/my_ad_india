import 'package:flutter/material.dart';
import 'package:my_ad/features/chat/core/chat_viewmodel.dart';
import 'package:my_ad/features/profile/core/profile_provider.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

import '../../core/domain/data_store/data_store.dart';
import '../../core/services/service.dart';
import '../all_services/core/all_service_view_model.dart';
import '../home/shell/home_screen/core/home_provider.dart';
import '../merchant/merchant_add_service/core/merchant_add_service_provider.dart';
import '../merchant/merchant_dashboard/shell/dashboard/core/merchant_dashboard_provider.dart';
import '../merchant/merchant_dashboard/shell/merchant_services/core/merchant_services_provider.dart';
import '../merchant/merchant_login/core/merchant_login_viewmodel.dart';

import 'package:pack/services/service.dart';

import '../../core/data/model/user/user_model.dart';

import '../all_category/core/all_category_view_modal.dart';
import '../intro/core/intro_provider.dart';

import '../../core/injector/dependency_injection.dart';
import '../../provider_state/location_provider.dart';
import '../../provider_state/scroll_visibility_provider.dart';
import '../../provider_state/theme_provider.dart';
import '../home/shell/profile_settings_screen/settings/core/setting_view_model.dart';
import '../merchant/merchant_registration/core/merchant_registration_view_model.dart';
import '../merchant/subscription/core/subscription_plan_provider.dart';
import '../onboarding/core/onboarding_provider.dart';
import 'my_add.dart';
import '../../core/data/model/model.dart';

class ScreenProviders extends StatelessWidget {
  const ScreenProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (x) => DependencyInjector.get<IntroProvider>(),
        ),
        ChangeNotifierProvider(
          create: (x) => DependencyInjector.get<OnboardingProvider>(),
        ),

        /// TODO : [HomeProvider] --------------------------
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<HomeScreenProvider>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<ScrollVisibilityProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => DependencyInjector.get<LocationProvider>(),
        ),
        ChangeNotifierProvider(
          create: (x) => DependencyInjector.get<AllCategoriesScreenProvider>(),
        ),
        ChangeNotifierProvider(
          create: (x) => DependencyInjector.get<SearchProvider>(),
        ),

        // -------------------- User Profile Page ------------------------------

        // -------------------- Setting Page -----------------------------------
        ChangeNotifierProvider(
          create:
              (ctx) => ServiceListViewModel(
                DependencyInjector.get<ServicesService>(),
                context.watch<ServiceStore>(),
              ),
        ),
        ChangeNotifierProxyProvider2<
          StateStore,
          SubscriptionPlanStore,
          MerchantRegistrationViewModel
        >(
          create:
              (ctx) => DependencyInjector.get<MerchantRegistrationViewModel>(),
          update: (
            BuildContext context,
            StateStore states,
            SubscriptionPlanStore plans,
            MerchantRegistrationViewModel? previous,
          ) {
            if (previous == null) {
              return DependencyInjector.get<MerchantRegistrationViewModel>();
            }
            return previous..updateStore(states, plans);
          },
        ),

        ChangeNotifierProvider(
          create:
              (ctx) => DependencyInjector.get<MerchantLoginScreenViewModel>(),
        ),
        ChangeNotifierProxyProvider<
          MerchantDashboardStore,
          MerchantAddServiceProvider
        >(
          create:
              (ctx) => DependencyInjector.getWithParams<
                MerchantAddServiceProvider,
                MerchantDashboardStore,
                int
              >(param1: context.read<MerchantDashboardStore>(), param2: 1),
          update: (ctx, store, previous) {
            if (previous == null) {
              return DependencyInjector.getWithParams<
                MerchantAddServiceProvider,
                MerchantDashboardStore,
                dynamic
              >(param1: store, param2: 1);
            }
            return previous..updateStore(store);
          },
        ),
        ChangeNotifierProxyProvider<
          AuthProviderModel<UserModel>,
          ProfileSettingsViewModel
        >(
          create:
              (ctx) => DependencyInjector.getWithParams<
                ProfileSettingsViewModel,
                AuthProviderModel<UserModel>,
                AppThemeProvider
              >(
                param1: context.read<AuthProviderModel<UserModel>>(),
                param2: context.read<AppThemeProvider>(),
              ),
          update: (ctx, auth, previous) {
            if (previous == null) {
              DependencyInjector.getWithParams<
                ProfileSettingsViewModel,
                AuthProviderModel<UserModel>,
                AppThemeProvider
              >(param1: auth, param2: context.read<AppThemeProvider>());
            }
            return previous!.updateStore(auth);
          },
        ),

        ChangeNotifierProxyProvider<
          MerchantDashboardStore,
          MerchantServicesProvider
        >(
          create:
              (ctx) => DependencyInjector.getWithParams<
                MerchantServicesProvider,
                MerchantDashboardStore,
                int
              >(param1: context.read<MerchantDashboardStore>(), param2: 01),
          update: (ctx, store, previous) {
            if (previous == null) {
              return DependencyInjector.getWithParams<
                MerchantServicesProvider,
                MerchantDashboardStore,
                dynamic
              >(param1: store, param2: 1);
            }
            return previous..updateStore(store);
          },
        ),

        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<SubscriptionPlanProvider>(),
        ),

        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<DashboardProvider>(),
        ),

        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<ProfileProviderModel>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<ChatViewModel>(),
        ),
      ],
      child: MyAdd(),
    );
  }
}
