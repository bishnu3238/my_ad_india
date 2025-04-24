import 'dart:convert';

import '../../merchant/merchant_service_model.dart';
import '../../merchant/merchant_subscription_model.dart';

enum OperationType { add, update, delete }

class ValidateServiceOperationRequest {
  final String merchantId;
  final MerchantSubscriptionModel subscription;
  final OperationType operationType; // 'add', 'update', 'delete'
  final MerchantServiceModel service;

  const ValidateServiceOperationRequest({
    required this.merchantId,
    required this.subscription,
      this.operationType = OperationType.add,
    required this.service,
  });
  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'subscription': subscription.toJson(),
      'operation_type': operationType.name,
      'service_data': jsonEncode(service.toJson()),
    };
  }
}
