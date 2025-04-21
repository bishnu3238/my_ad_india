class FetchMerchantPlanAccessRequest {
  String? merchantId;
  String? planId;

  FetchMerchantPlanAccessRequest({this.merchantId, this.planId});

  FetchMerchantPlanAccessRequest.fromJson(Map<String, dynamic> json) {
    merchantId = json['merchant_id'];
    planId = json['plan_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['merchant_id'] = merchantId;
    data['plan_id'] = planId;
    return data;
  }
}