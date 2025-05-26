import 'package:go_router/go_router.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/features/chat_feature/core/services/api_client.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../core/domain/data_store/data_store.dart';
import '../../../core/domain/use_cases/api_call_use_cases.dart';
import '../../../core/injector/dependency_injection.dart';
import '../../../core/services/service.dart';
import '../ead_product_details/core/ead_product_details_viewmodel.dart';
import '../ead_product_details/ead_product_details.dart';
import '../ead_products.dart';
import 'ead_product_view_model.dart';

enum ProductSearchBy {
  category,
  subCategory,
  service,
  search,
  merchant,
  product,
  all,
}

class EadProductRoute {
  static const String eadServices = '/ead_service';
  static const String eadServiceDetails = '/ead_product_details';

  static GoRoute page() => GoRoute(
    path: '$eadServices/:id/:productSearchBy',
    builder:
        (ctx, state) => ChangeNotifierProvider(
          create:
              (ctx) => EadProductsViewModel(
                ctx.read<ProductStore>(),
                DependencyInjector.get<ApiCallUseCase>(),
                ctx.read<CategoryStore>(),
                ctx.read<SubCategoryStore>(),
                ctx.read<ServiceStore>(),
                ctx.read<AppMerchantsStore>(),

                type: state.pathParameters.getEnum(
                  'productSearchBy',
                  ProductSearchBy.values,
                  ProductSearchBy.all,
                ),
                id: state.pathParameters['id']!,
              ),
          child: const EadProducts(),
        ),
    routes: [
      GoRoute(
        path: eadServiceDetails,
        name: eadServiceDetails.snakeCase,
        builder: (ctx, state) {
          final product =
              state.extra
                  as ProductModel; //context.read<EadProductsViewModel>();
          return ChangeNotifierProvider(
            create:
                (ctx) => ProductDetailsViewModel(
                  ApiClient(baseUrl: ApiConfig.baseChatUrl),
                  product: product,
                  service: DependencyInjector.get<ProductService>(),
                ),
            child: EadProductDetails(),
          );
        },
      ),
    ],
  );

  static openEadProductDetails(BuildContext context, ProductModel product) {
    context.push(
      '${EadProductRoute.eadServices}/${product.id}/${ProductSearchBy.product.name}${EadProductRoute.eadServiceDetails}',
      extra: product,
    );
  }

  static openEadProducts(
    BuildContext context,
    String serviceId,
    ProductSearchBy searchThrough,
  ) => context.push(
    '${EadProductRoute.eadServices}/$serviceId/${searchThrough.name}',
  );
}
