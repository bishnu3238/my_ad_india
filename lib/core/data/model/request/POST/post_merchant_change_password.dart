class PostMerchantChangePassword {
   final String merchantId;
  final String? oldPassword;
  final String? newPassword;

   const PostMerchantChangePassword({required this.merchantId, this.oldPassword, this.newPassword});



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['old_password'] = oldPassword;
    data['new_password'] = newPassword;
    return data;
  }


  @override
  String toString() {
    return 'PostMerchantChangePassword{oldPassword: $oldPassword, newPassword: $newPassword}';
  }
}