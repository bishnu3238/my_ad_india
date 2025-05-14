import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/data_store/data_store.dart';
import '../../core/injector/dependency_injection.dart';
import 'app_providers.dart';

class DataStoreInjection extends StatelessWidget {
    const DataStoreInjection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// TODO: [DataStore-Start] ------------------------------------------
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<AppMerchantsStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<BannerStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<CategoryStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<CitiesStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<MerchantDashboardStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<ProductStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<ReferralStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<ServiceStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<StateStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<SubCategoryStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<SubscriptionPlanStore>(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DependencyInjector.get<UserAuthenticationStore>(),
        ),

        /// TODO:---- [DataStore-End] ----------------------------------------
      ],
      child:
      AppProviders(),
    );
  }
}
