class PostMerchantOtpVerification {
  final String merchantId;
  final String otp;

  PostMerchantOtpVerification({required this.merchantId, required this.otp});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['merchantId'] = merchantId;
    data['otp'] = otp;
    return data;
  }

  @override
  String toString() {
    return 'MerchantOtpRequest{merchantId: $merchantId, otp: $otp}';
  }
}
