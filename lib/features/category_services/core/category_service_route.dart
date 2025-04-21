// category_services/core/category_services_route.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pack/services/service.dart';
import '../../../../core/data/model/product/category_model.dart';
import '../../../core/domain/data_store/data_store.dart';
import '../category_service.dart';
import 'category_service_provider.dart';

class CategoryServicesRoute {
  static const String categoryServices = '/category-services';

  static GoRoute   page() => GoRoute(
    path: '$categoryServices/:categoryId',
    builder: (BuildContext context, GoRouterState state) {
      final categoryId = state.pathParameters['categoryId'] ?? '';

      // Get category name from the store
      final categoryStore = context.read<CategoryStore>();
      final category = categoryStore.items.firstWhere(
        (c) => c.id == categoryId,
        orElse:
            () => CategoryModel(
              id: categoryId,
              category: 'Unknown',
              title: 'Unknown Category',
              searchImageUrl: '',
              favIcon: '',
              status: CategoryStatus.active,
            ),
      );

      return ChangeNotifierProvider(
        create:
            (ctx) => CategoryServicesProvider(
              serviceStore: context.read<ServiceStore>(),
            ),
        child: CategoryServicesPage(
          categoryId: categoryId,
          categoryName: category.title,
        ),
      );
    },
  );
}
