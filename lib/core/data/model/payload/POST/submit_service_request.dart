import '../../merchant/merchant.dart';

class SubmitServiceRequest {
  final String merchantId;
  final ServiceRequestType requestType;
  final MerchantServiceModel service;
  final int? serviceId;
  final bool validateFirst = true;
  const SubmitServiceRequest({
    required this.merchantId,
    required this.requestType,
    required this.service,
    this.serviceId,
  });
  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'request_type': requestType.name,
      'service': service.toJson(),
      if (serviceId != null) 'service_id': serviceId,
    };
  }
}
