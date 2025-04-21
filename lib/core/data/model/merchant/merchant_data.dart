import 'merchant_model.dart';
import 'merchant_subscription_model.dart';
import 'package:pack/services/service.dart';

class MerchantData extends BaseModel<MerchantData> {
  final MerchantModel merchant;
  final MerchantSubscriptionModel subscription;

  const MerchantData({
    required this.merchant,
    required this.subscription,
    super.id = '0',
  });

  static MerchantData empty() {
    return MerchantData(
      merchant: MerchantModel.empty(),
      subscription: MerchantSubscriptionModel.empty(),
    );
  }

  factory MerchantData.fromLocalMap(Map<String, dynamic> json) {
    return MerchantData(
      merchant: MerchantModel.fromLocalMap(json['merchant']),
      subscription: MerchantSubscriptionModel.fromLocalMap(
        json['subscription'],
      ),
    );
  }

  bool get isEmpty => this == empty();

  @override
  String toString() {
    return 'MerchantData{merchant: $merchant, subscription: $subscription}';
  }

   MerchantData copyWith(
    MerchantModel? merchant,
    MerchantSubscriptionModel? subscription,
  ) {
    return MerchantData(
      merchant: merchant ?? this.merchant,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  List<Object?> get props => [merchant, subscription];

  @override
  Map<String, dynamic> toJson() {
    return {
      'merchant': merchant.toJson(),
      'subscription': subscription.toJson(),
    };
  }
}
