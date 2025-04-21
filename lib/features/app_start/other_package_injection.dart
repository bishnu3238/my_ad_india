import 'package:flutter/material.dart';
import 'package:my_ad/features/app_start/data_store_injection.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';

import '../../core/data/model/model.dart';
import '../../core/injector/dependency_injection.dart';
import '../../provider_state/local_notification_provider.dart';

class OtherPackageInjection extends StatelessWidget {
  const OtherPackageInjection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProviderModel<UserModel>>(
          create: (x) => DependencyInjector.get<AuthProviderModel<UserModel>>(),
        ),

        ChangeNotifierProvider<LocalNotificationProvider>(
          create: (x) => DependencyInjector.get<LocalNotificationProvider>(),
        ),
      ],
      child: DataStoreInjection(),
    );
  }
}
