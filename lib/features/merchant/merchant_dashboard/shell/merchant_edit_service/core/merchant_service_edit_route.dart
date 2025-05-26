import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/data/model/merchant/merchant.dart';
import '../merchant_edit_service.dart';

class MerchantServiceEditRoute {
  static const String serviceEdit = '/merchant/service-edit';

  static GoRoute page() => GoRoute(
    path: '$serviceEdit/:merchant_id',
    builder: (ctx, state) {
      final service = state.extra as MerchantServiceModel?;
      final merchantId = state.pathParameters['merchant_id'] ?? '';
      return MerchantServiceEditPage(service: service!, merchantId: merchantId);
    },
  );

  static open(
    BuildContext context,
    String merchantId,
    MerchantServiceModel model,
  ) => context.push('$serviceEdit/$merchantId', extra: model);
}
