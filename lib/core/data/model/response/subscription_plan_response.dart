import 'package:pack/pack.dart';

import '../plan_model.dart';

class SubscriptionPlanResponse {
  final bool success;
  final int count;
  final List<SubscriptionPlanModel> plans;

  SubscriptionPlanResponse({
    required this.success,
    required this.count,
    required this.plans,
  });

  // Parse JSON manually
  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      success: json.getBool('success'),
      count: json.getInt('count'),
      plans: (json['plans'] as List<dynamic>?)
          ?.map((planJson) => SubscriptionPlanModel.fromJson(planJson as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  // Convert to JSON manually
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'plans': plans.map((plan) => plan.toJson()).toList(),
    };
  }
}
