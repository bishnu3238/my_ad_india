// models/merchant_plan_access_model.dart
import 'dart:convert';

import 'package:my_ad/core/data/model/plan_model.dart';

import '../../../domain/entities/entities.dart';
import 'plan_activity_model.dart';

// models/merchant_plan_access.dart
import 'package:equatable/equatable.dart';

class MerchantPlanAccessModel extends Equatable {



  final int merchantId;
  final SubscriptionPlanModel planModel;
  final List<PlanActivityModel> accessibleFeatures;
  final int numberOfServices;
  final int remainingServices;
  final int remainingUpdates;
  final DateTime? validUntil;

  const MerchantPlanAccessModel({
    required this.merchantId,
    required this.accessibleFeatures,
    required this.numberOfServices,
    required this.remainingServices,
    required this.remainingUpdates,
      this.validUntil,
    required this.planModel
  });

  // Helper method to check if merchant can use a specific feature
  bool canUseFeature(int featureId) {
    return accessibleFeatures.any((feature) => feature.id == featureId);
  }

  // Helper method to check if merchant can add more services
  bool canAddMoreServices() {
    return remainingServices > 0;
  }

  // Helper method to check if merchant can update a service
  bool canUpdateService() {
    return remainingUpdates > 0;
  }

  // Helper method to check if subscription is still valid
  bool isSubscriptionValid() {
    return validUntil == null  ? false : validUntil!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [
    merchantId,
    accessibleFeatures,
    numberOfServices,
    remainingServices,
    remainingUpdates,
    validUntil,
  ];

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'plan': planModel.toJson(),
      'accessibleFeatures': jsonEncode(accessibleFeatures.map((e) => e.toJson()).toList()),
      'numberOfServices': numberOfServices,
      'remainingServices': remainingServices,
      'remainingUpdates': remainingUpdates,
      'validUntil': validUntil,
    };
  }

  static MerchantPlanAccessModel empty() =>   MerchantPlanAccessModel(
    merchantId: 0,
    planModel: SubscriptionPlanModel.empty(),
    accessibleFeatures: [],
    numberOfServices: 0,
    remainingServices: 0,
    remainingUpdates: 0,
   );


  MerchantPlanAccessModel copyWith({
    int? merchantId,
    SubscriptionPlanModel? planModel,
    List<PlanActivityModel>? accessibleFeatures,
    int? numberOfServices,
    int? remainingServices,
    int? remainingUpdates,
    DateTime? validUntil,
  }) {
    return MerchantPlanAccessModel(
      merchantId: merchantId ?? this.merchantId,
      planModel: planModel ?? this.planModel,
      accessibleFeatures: accessibleFeatures ?? this.accessibleFeatures,
      numberOfServices: numberOfServices ?? this.numberOfServices,
      remainingServices: remainingServices ?? this.remainingServices,
      remainingUpdates: remainingUpdates ?? this.remainingUpdates,
      validUntil: validUntil ?? this.validUntil,
     );
  }

  @override
  String toString() {
    return 'MerchantPlanAccessModel{merchantId: $merchantId, planModel: $planModel, accessibleFeatures: $accessibleFeatures, numberOfServices: $numberOfServices, remainingServices: $remainingServices, remainingUpdates: $remainingUpdates, validUntil: $validUntil}';
  }


}
