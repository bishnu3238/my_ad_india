import 'package:get_it/get_it.dart';
import 'package:my_ad/features/chat/core/chat_viewmodel.dart';
import 'package:my_ad/features/chat/repositories/chat_repository.dart';
import 'package:my_ad/features/chat/repository/chat_repository.dart';
import 'package:my_ad/features/chat/services/chat_service.dart';
import 'package:my_ad/features/chat/services/i_chat_service.dart';
import 'package:my_ad/features/settings/core/settings_view_model.dart';
import '../../features/home/shell/profile_settings_screen/settings/core/setting_view_model.dart';
import 'package:my_ad/features/onboarding/core/onboarding_provider.dart';
import 'package:my_ad/features/profile/core/profile_provider.dart';
import 'package:pack/services/service.dart';
import '../../features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';
import '../../features/merchant/merchant_dashboard/shell/dashboard/core/merchant_dashboard_provider.dart';
import '../../features/merchant/merchant_dashboard/shell/merchant_services/core/merchant_services_provider.dart';
import '../../features/merchant/merchant_login/core/merchant_login_viewmodel.dart';
import '../../features/merchant/merchant_registration/core/merchant_registration_view_model.dart';
import '../../features/merchant/subscription/core/subscription_plan_provider.dart';
import '../../provider_state/local_notification_provider.dart';

import '../../features/all_category/core/all_category_view_modal.dart';
import '../../features/home/shell/profile_settings_screen/settings/core/local.dart';
import '../../features/intro/core/intro_provider.dart';

import '../../features/home/shell/home_screen/core/home_provider.dart';
import '../../features/location/core/location_view_model.dart';
import '../../provider_state/location_provider.dart';
import '../../provider_state/scroll_visibility_provider.dart';
import '../../provider_state/theme_provider.dart';
import '../data/api/api_config.dart';
import '../data/model/model.dart';
import '../data/repository/repository.dart';
import '../data/repository/user_repository/user_repository.dart';
import '../domain/repository/repository.dart';
import '../domain/data_store/data_store.dart';
import 'package:pack/auth/custom_auth.dart';
import '../domain/use_cases/api_call_use_cases.dart';
import '../services/service.dart';

class DependencyInjector {
  static final GetIt _getIt = GetIt.instance;

  static void setup() async {
    //
    //
    /// TODO:---- [Pack] - Add all the dependencies here -----------------------
    ///
    _getIt.registerLazySingleton<AuthProviderModel<UserModel>>(
      () => AuthProviderModel<UserModel>()..initialize(),
    );
    _getIt.registerLazySingleton<AppVersionTracker>(() => AppVersionTracker());

    /// TODO:---- [Services] ---------------------------------------------------
    _getIt.registerLazySingleton<LocalNotificationService>(
      () => LocalNotificationService(),
    );
    _getIt.registerLazySingleton<NotifyService>(() => NotifyService());

    _getIt.registerLazySingleton<ApiCallService>(
      () => ApiCallService(baseUrl: ApiConfig.baseLocalUrl),
    );

    _getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(),
    );

    /// TODO:---- [Pack-End] ---------------------------------------------------
    ///
    ///
    ///
    ///
    ///
    /// TODO:---- [Service-Start] ----------------------------------------------
    _getIt.registerLazySingleton<IChatService>(() => ChatService());

    ///
    ///
    ///
    /// TODO:---- [Data-Store] -------------------------------------------------
    ///
    _getIt.registerLazySingleton<AppMerchantsStore>(() => AppMerchantsStore());
    _getIt.registerLazySingleton<BannerStore>(() => BannerStore());
    _getIt.registerLazySingleton<CategoryStore>(() => CategoryStore());
    _getIt.registerLazySingleton<CitiesStore>(() => CitiesStore());
    _getIt.registerLazySingleton(() => MerchantDashboardStore());
    _getIt.registerLazySingleton<ProductStore>(() => ProductStore());
    _getIt.registerLazySingleton<ReferralStore>(() => ReferralStore());
    _getIt.registerLazySingleton<ServiceStore>(() => ServiceStore());
    _getIt.registerLazySingleton<StateStore>(() => StateStore());
    _getIt.registerLazySingleton<SubCategoryStore>(() => SubCategoryStore());
    _getIt.registerLazySingleton(() => SubscriptionPlanStore());
    _getIt.registerLazySingleton(() => UserAuthenticationStore());
    _getIt.registerLazySingleton(() => LocalAppSettingStorage());

    ///
    ///
    /// TODO:---- [Data-Store-End] ---------------------------------------------
    ///
    ///
    ///
    /// TODO:---- [Repository-Start] -------------------------------------------
    ///

    _getIt.registerLazySingleton<BannerRepository>(
      () => BannerRepositoryImpl(_getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(_getIt.get<ApiCallService>()),
    );
    _getIt.registerLazySingleton<CitiesRepository>(
      () => CitiesRepositoryImpl(
        _getIt.get<ApiCallService>(),
        _getIt.get<CitiesStore>(),
      ),
    );
    _getIt.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(),
    );
    _getIt.registerLazySingleton<MerchantAuthRepository>(
      () => MerchantAuthRepositoryImpl(_getIt.get<ApiCallService>()),
    );
    _getIt.registerLazySingleton<MerchantDashboardRepository>(
      () => MerchantDashboardRepositoryImpl(_getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(apiCallService: _getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<ReferralRepository>(
      () => ReferralRepositoryImpl(apiService: _getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(_getIt.get<ApiCallService>()),
    );
    _getIt.registerLazySingleton<StateRepository>(
      () => StateRepositoryImpl(_getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<SubCategoryRepository>(
      () => SubCategoryRepositoryImpl(_getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<SubscriptionPlanRepository>(
      () => SubscriptionPlanRepositoryImpl(_getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(_getIt.get<ApiCallService>()),
    );

    _getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepository(_getIt.get<IChatService>()),
    );

    ///
    /// TODO:---- [Repository-End] ---------------------------------------------
    ///
    ///
    ///
    /// TODO:---- [Services-Start] ---------------------------------------------
    ///
    _getIt.registerLazySingleton(
      () => BannerService(
        _getIt.get<BannerStore>(),
        _getIt.get<BannerRepository>(),
      ),
    );
    _getIt.registerLazySingleton(
      () => CategoryService(
        _getIt.get<CategoryStore>(),
        _getIt.get<CategoryRepository>(),
      ),
    );
    _getIt.registerLazySingleton(
      () => CityService(
        _getIt.get<CitiesStore>(),
        _getIt.get<CitiesRepository>(),
      ),
    );
    _getIt.registerLazySingleton<MerchantAuthService>(
      () => MerchantAuthService(
        _getIt.get<MerchantDashboardStore>(),
        _getIt.get<MerchantAuthRepository>(),
      )..initialize(),
    );
    _getIt.registerLazySingleton(
      () => MerchantDashboardService(
        _getIt.get<MerchantDashboardStore>(),
        _getIt.get<MerchantDashboardRepository>(),
        _getIt.get<ConnectivityService>(),
      ),
    );

    _getIt.registerLazySingleton(
      () => ProductService(
        _getIt.get<ProductStore>(),
        _getIt.get<ProductRepository>(),
      ),
    );
    _getIt.registerLazySingleton(
      () => ReferralService(
        _getIt.get<ReferralStore>(),
        _getIt.get<ReferralRepository>(),
      ),
    );
    _getIt.registerLazySingleton(
      () => ServicesService(
        _getIt.get<ServiceStore>(),
        _getIt.get<ServiceRepository>(),
      ),
    );
    _getIt.registerLazySingleton(
      () =>
          StateService(_getIt.get<StateStore>(), _getIt.get<StateRepository>()),
    );
    _getIt.registerLazySingleton(
      () => SubcategoryService(
        _getIt.get<SubCategoryStore>(),
        _getIt.get<SubCategoryRepository>(),
      ),
    );
    _getIt.registerLazySingleton(
      () => SubscriptionPlanService(
        _getIt.get<SubscriptionPlanStore>(),
        _getIt.get<SubscriptionPlanRepository>(),
      ),
    );

    /// TODO:---- [Services-End] -----------------------------------------------
    ///
    ///
    ///
    ///
    /// TODO:---- [Use-Cases] --------------------------------------------------
    _getIt.registerLazySingleton<ApiCallUseCase>(
      () => ApiCallUseCase(
        _getIt.get<CityService>(),
        _getIt.get<BannerService>(),
        _getIt.get<CategoryService>(),
        _getIt.get<SubcategoryService>(),
        _getIt.get<ServicesService>(),
        _getIt.get<StateService>(),
        _getIt.get<MerchantAuthService>(),
        _getIt.get<SubscriptionPlanService>(),
        _getIt.get<ProductService>(),
        _getIt.get<ReferralService>(),
      ),
    );

    ///
    /// TODO:---- [Use-Cases-End] ----------------------------------------------
    ///
    ///
    ///
    ///
    /// TODO:---- [App-Providers-Start] ----------------------------------------
    ///
    _getIt.registerLazySingleton<LocationProvider>(() => LocationProvider());
    _getIt.registerLazySingleton<AppThemeProvider>(() => AppThemeProvider());

    _getIt.registerLazySingleton<LocalNotificationProvider>(
      () => LocalNotificationProvider(_getIt.get<LocalNotificationService>()),
    );
    _getIt.registerLazySingleton<ScrollVisibilityProvider>(
      () => ScrollVisibilityProvider(),
    );

    ///
    /// TODO:---- [App-Providers-End] ------------------------------------------
    ///
    ///
    ///
    ///
    /// TODO:---- [Screen-Providers] -------------------------------------------
    ///

    _getIt.registerLazySingleton<IntroProvider>(
      () => IntroProvider(_getIt.get<CityService>()),
    );
    _getIt.registerLazySingleton<OnboardingProvider>(
      () => OnboardingProvider(),
    );

    // ------------------------------ [HOME] -----------------------------------
    _getIt.registerFactory<HomeScreenProvider>(
      () => HomeScreenProvider(
        _getIt.get<ApiCallUseCase>(),
        _getIt.get<ConnectivityService>(),
      ),
    );
    _getIt.registerFactory<LocationScreenProvider>(
      () => LocationScreenProvider(_getIt.get<CitiesStore>()),
    );

    _getIt.registerFactoryParam<
      ProfileSettingsViewModel,
      AuthProviderModel<UserModel>,
      AppThemeProvider
    >(
      (param1, param2) => ProfileSettingsViewModel(
        param1,
        param2,
        DependencyInjector.get<AppVersionTracker>(),
      ),
    );
    // ---------------------------- [HOME-END] ---------------------------------

    _getIt.registerLazySingleton(
      () => AllCategoriesScreenProvider(
        _getIt.get<CategoryStore>(),
        _getIt.get<ApiCallUseCase>(),
      ),
    );
    _getIt.registerLazySingleton<MerchantRegistrationViewModel>(
      () => MerchantRegistrationViewModel(
        _getIt.get<MerchantAuthService>(),
        _getIt.get<ApiCallUseCase>(),
        _getIt.get<StateStore>(),
        _getIt.get<SubscriptionPlanStore>(),
      ),
    );

    _getIt.registerFactoryParam<
      SearchProvider,
      SearchRepository,
      RecentSearchStorage
    >(
      (param1, param2) =>
          SearchProvider(repository: param1, recentSearchStorage: param2),
    );

    _getIt.registerFactoryParam<
      MerchantAddServiceProvider,
      MerchantDashboardStore,
      int
    >(
      (param1, param2) => MerchantAddServiceProvider(
        store: param1,
        service: _getIt.get<MerchantDashboardService>(),
      ),
    );

    _getIt.registerFactoryParam<
      MerchantServicesProvider,
      MerchantDashboardStore,
      int
    >(
      (param1, param2) => MerchantServicesProvider(
        merchantData:
            param1.entity == null
                ? MerchantData.empty()
                : param1.entity!.merchantData,
        planRestrictionService: _getIt.get<MerchantDashboardService>(),
      ),
    );

    _getIt.registerLazySingleton<SubscriptionPlanProvider>(
      () => SubscriptionPlanProvider(
        merchantStore: _getIt.get<MerchantDashboardStore>(),
        repository: _getIt.get<SubscriptionPlanRepository>(),
        planRestrictionService: _getIt.get<MerchantDashboardService>(),
      ),
    );

    /// [MerchantLoginScreenProvider]---------------------------------------

    _getIt.registerLazySingleton<MerchantLoginScreenViewModel>(
      () => MerchantLoginScreenViewModel(_getIt.get<MerchantAuthService>()),
    );

    _getIt.registerLazySingleton(
      () => DashboardProvider(_getIt.get<MerchantDashboardService>()),
    );
    _getIt.registerLazySingleton<ProfileProviderModel>(
      () => ProfileProviderModel(_getIt.get<UserRepository>()),
    );
    _getIt.registerFactoryParam<SettingsViewModel, AppThemeProvider, UserModel>(
      (param1, param2) => SettingsViewModel(
        param1,
        _getIt.get<AppVersionTracker>(),
        user: param2,
      ),
    );

    _getIt.registerLazySingleton<ChatViewModel>(
      () => ChatViewModel(_getIt.get<ChatRepository>()),
    );

    // -------------------------- End Screen Providers ---------------------------
  }

  // Helper method to get services
  static T get<T extends Object>() => _getIt.get<T>();
  static T getWithParam<T extends Object, P>({required P param}) =>
      _getIt.get<T>(param1: param);

  static T getWithParams<T extends Object, P1, P2>({
    required P1 param1,
    required P2 param2,
  }) => _getIt.get<T>(param1: param1, param2: param2);
}
