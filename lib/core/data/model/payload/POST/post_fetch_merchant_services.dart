class PostFetchMerchantServices {
  final String merchantId;
  final String? serviceType;

  PostFetchMerchantServices({
    required this.merchantId,
    this.serviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'service_type': serviceType,
    };
  }


  @override
  String toString() {
    return 'FetchMerchantServicesRequest{merchantId: $merchantId, serviceType: $serviceType}';
  }
}