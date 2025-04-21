class PostMerchantResetPassword{

  String? merchantId;
  String? password;
  String? newPassword;

  PostMerchantResetPassword({
    this.merchantId,
    this.password,
    this.newPassword,
  });



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['merchant_id'] = merchantId;
    data['password'] = password;
    data['new_password'] = newPassword;
    return data;
  }
}