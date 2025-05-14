import 'dart:developer' as dev;

import 'package:my_ad/core/data/model/response/merchant_otp_response.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/base_services/base_model.dart';

import '../response/merchant_login_response.dart';
import 'merchant.dart';

class MerchantDashboardModel extends BaseModel<MerchantDashboardModel> {
  final bool isAuthenticated;
  final String? token;
  final DateTime? tokenExpiry;
  final MerchantData merchantData;
  final MerchantPlanAccessModel planAccess;
  final List<MerchantServiceModel> services;
  final ServiceRequestModel serviceRequest;

  const MerchantDashboardModel({
    required super.id,
    required this.merchantData,
    required this.planAccess,
    required this.services,
    required this.serviceRequest,
    this.isAuthenticated = false,
    this.token,
    this.tokenExpiry,
  });

  @override
  List<Object?> get props => [
    id,
    isAuthenticated,
    merchantData,
    planAccess,
    services,
    serviceRequest,
  ];

  MerchantDashboardModel copyWith({
    bool? isAuthenticated,
    String? token,
    DateTime? tokenExpiry,
    MerchantData? merchant,
    MerchantPlanAccessModel? planAccess,
    List<MerchantServiceModel>? services,
    ServiceRequestModel? serviceRequest,
  }) {
    return MerchantDashboardModel(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      merchantData: merchant ?? this.merchantData,
      planAccess: planAccess ?? this.planAccess,
      services: services ?? this.services,
      serviceRequest: serviceRequest ?? this.serviceRequest,
      id: super.id,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAuthenticated': isAuthenticated,
      'token': token,
      'tokenExpiry': tokenExpiry,
      'merchant': merchantData.merchant.toJson(),
      'subscription': merchantData.subscription.toJson(),
      'service_details': merchantData.serviceDetails.toJson(),
    };
  }

  factory MerchantDashboardModel.formLogin(MerchantLoginResponse map) {
    return MerchantDashboardModel(
      isAuthenticated: true,
      token: map.timestamp,
      id: '${map.merchant!.merchant.id}',
      merchantData: map.merchant!,
      planAccess: MerchantPlanAccessModel.empty(),
      services: [],
      serviceRequest: ServiceRequestModel.empty(),
    );
  }

  factory MerchantDashboardModel.fromLocalMap(Map<String, dynamic> map) {
    dev.log('fromLocalMap: $map');
    return MerchantDashboardModel(
      isAuthenticated: map.getBool('isAuthenticated'),
      token: map.getString('token'),
      tokenExpiry: map.getDateTime('tokenExpiry'),
      merchantData: MerchantData.fromLocalMap(map),
      planAccess: MerchantPlanAccessModel.empty(),
      services: List<MerchantServiceModel>.empty(),
      serviceRequest: ServiceRequestModel.empty(),
      id: map['id'],
    );
  }

  static MerchantDashboardModel get empty => MerchantDashboardModel(
    id: '0',
    merchantData: MerchantData.empty(),
    planAccess: MerchantPlanAccessModel.empty(),
    services: [],
    serviceRequest: ServiceRequestModel.empty(),
    isAuthenticated: false,
  );

  static unAuthenticated() {
    return MerchantDashboardModel(
      id: '0',
      merchantData: MerchantData.empty(),
      planAccess: MerchantPlanAccessModel.empty(),
      services: [],
      serviceRequest: ServiceRequestModel.empty(),
      isAuthenticated: false,
    );
  }

  factory MerchantDashboardModel.requiredOtp(
    MerchantOtpVerificationResponse result,
  ) {
    return MerchantDashboardModel(
      isAuthenticated: true,
      token: result.timestamp,
      id: '${result.data!['merchant_id']}',
      merchantData: MerchantData.empty(),
      planAccess: MerchantPlanAccessModel.empty(),
      services: [],
      serviceRequest: ServiceRequestModel.empty(),
    );
  }

  factory MerchantDashboardModel.formOtp(
    MerchantOtpVerificationResponse result,
  ) {
    return MerchantDashboardModel(
      isAuthenticated: true,
      token: result.timestamp,
      id: '${result.merchant!.merchant.id}',
      merchantData: result.merchant!,
      planAccess: MerchantPlanAccessModel.empty(),
      services: [],
      serviceRequest: ServiceRequestModel.empty(),
    );
  }
}
