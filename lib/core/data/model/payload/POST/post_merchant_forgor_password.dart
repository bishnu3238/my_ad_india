class PostMerchantForgotPassword {
  String merchantId;
  String? email;
  String? phone;

  PostMerchantForgotPassword({
    required this.merchantId,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'email': email,
      'phone': phone,
    };
  }
}