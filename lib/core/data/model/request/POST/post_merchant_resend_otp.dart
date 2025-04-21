class PostMerchantResendOtp{

  final String merchantId;

  /// Constructor

  PostMerchantResendOtp({
    required this.merchantId,
  });

  /// Converts the request to a JSON map

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
    };
  }
}