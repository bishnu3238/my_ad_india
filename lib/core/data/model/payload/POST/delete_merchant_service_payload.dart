import '../../merchant/merchant_service_model.dart';
import '../../merchant/service_request_model.dart';

class DeleteMerchantServicePayload {
  final String serviceId;
  final ServiceRequestType requestType;
  final MerchantServiceModel service;

  final String merchantId;

  DeleteMerchantServicePayload({
    required this.serviceId,
      this.requestType = ServiceRequestType.delete,
    required this.service,
    required this.merchantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'request_type': requestType.name,
      'service': service.toJson(),
      'merchant_id': merchantId,
    };
  }
}
