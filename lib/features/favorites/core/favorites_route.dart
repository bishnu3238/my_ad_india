import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:provider/provider.dart';
import '../../../core/domain/data_store/service_store.dart';
import '../../../core/services/services_service.dart';
import '../favorites_screen.dart';
import 'favorites_view_model.dart';

class FavoritesRoute {
  static const String favoritesPath = '/favorites';

  static GoRoute page() =>
      GoRoute(path: favoritesPath, builder: (ctx, state) => ChangeNotifierProvider(


        // New Favorites Provider
             create: (context) => FavoritesViewModel(
              DependencyInjector.get<ServicesService>(),
              context.read<ServiceStore>(),
            ),


          child: FavoritesScreen()));

  static openPage(BuildContext context) {
    context.push(favoritesPath);
  }
}
