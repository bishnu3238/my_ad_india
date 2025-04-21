import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import '../../model/model.dart';
import 'package:pack/pack.dart';

class MerchantPlanAccessResponse extends Equatable {
  final bool success;
  final MerchantPlanAccessModel? data;
  final String message;
  final String timestamp;

  const MerchantPlanAccessResponse({
    required this.success,
    this.data,
    required this.message,
    required this.timestamp,
  });

  factory MerchantPlanAccessResponse.fromJson(Map<String, dynamic> json) {
    dev.log('FETCH-MERCHANT-PLAN-ACCESS-RESPONSE: => $json');

    return MerchantPlanAccessResponse(
      success: json.getBool('success'),
      data:
          json['success'] && json['data'] != null
              ? MerchantPlanAccessModel(
                merchantId: json.getMap('data').getInt('merchant_id'),
            planModel: json.getMap('data').containsKey('plan')
                ? SubscriptionPlanModel.fromJson(json.getMap('data').getMap('plan'))
                : SubscriptionPlanModel.empty(),
                accessibleFeatures:
                    (json['data']['accessible_features'] as List)
                        .map((e) => PlanActivityModel.fromJson(e))
                        .toList(),
                numberOfServices: json
                    .getMap('data')
                    .getInt('number_of_services'),
                remainingServices: json
                    .getMap('data')
                    .getInt('remaining_services'),
                remainingUpdates: json
                    .getMap('data')
                    .getInt('remaining_updates'),
                validUntil: json.getMap('data').getDateTime('valid_until'),
              )
              : MerchantPlanAccessModel.empty(),
      message: json.getString('message'),
      timestamp: json.getString('timestamp'),
    );
  }

  @override
  List<Object?> get props => [success, data, message, timestamp];
}
