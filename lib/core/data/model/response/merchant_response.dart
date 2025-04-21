import '../model.dart';

class MerchantResponse {
  final MerchantModel merchant;
  final MerchantSubscriptionModel subscription;

  MerchantResponse({required this.merchant, required this.subscription});

  factory MerchantResponse.fromJson(Map<String, dynamic> json) {
    return MerchantResponse(
      merchant: MerchantModel.fromJson(
        json['merchant'] as Map<String, dynamic>,
      ),
      subscription: MerchantSubscriptionModel.fromJson(
        json['subscription'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  String toString() {
    return 'MerchantResponse{merchant: $merchant, subscription: $subscription}';
  }
}
