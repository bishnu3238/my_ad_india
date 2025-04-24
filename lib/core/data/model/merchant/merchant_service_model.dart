// models/merchant_service_model.dart
import 'package:equatable/equatable.dart';

import 'package:pack/pack.dart';

class MerchantServiceModel extends Equatable {
  final int? id;
  final int merchantId;
  final int categoryId;
  final int subcategoryId;
  final int serviceTypeId;
  final String serviceName;
  final String? videoUrl;
  final int quantity;
  final String description;
  final String offers;
  final bool offerStatus;
  final double planRate;
  final String cityName;
  final String? stateName;
  final String address;
  final String latitude;
  final String longitude;
  final String? closeReason;
  final int status;
  final int
  updateLimits; // Tracks how many times merchant has updated this service
  final int videoStatus;
  final int businessPartnerApprove;
  final List<String> servicePhotos; // Store photo URLs
  final String merchantPhoto;

  const MerchantServiceModel({
    this.id,
    required this.merchantId,
    required this.categoryId,
    required this.subcategoryId,
    required this.serviceTypeId,
    required this.serviceName,
    this.videoUrl,
    required this.quantity,
    required this.description,
    required this.offers,
    required this.offerStatus,
    required this.planRate,
    required this.cityName,
    this.stateName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.closeReason,
    required this.status,
    required this.updateLimits,
    required this.videoStatus,
    required this.businessPartnerApprove,
    required this.servicePhotos,
    this.merchantPhoto = '',
  });

  const MerchantServiceModel.empty()
    : id = null,
      merchantId = 0,
      categoryId = 0,
      subcategoryId = 0,
      serviceTypeId = 0,
      serviceName = '',
      videoUrl = null,
      quantity = 0,
      description = '',
      offers = '',
      offerStatus = false,
      planRate = 0.0,
      cityName = '',
      stateName = null,
      address = '',
      latitude = '0',
      longitude = '0',
      closeReason = null,
      status = 1,
      updateLimits = 0,
      videoStatus = 0,
      businessPartnerApprove = 0,
      servicePhotos = const [],
      merchantPhoto = '';

  factory MerchantServiceModel.fromJson(Map<String, dynamic> json) {
    return MerchantServiceModel(
      id: json.getInt('id'),
      merchantId: json.getInt('merchant_id'),
      categoryId: json.getInt('category'),
      subcategoryId: json.getInt('subcategory'),
      serviceTypeId: json.getInt('service'),
      serviceName: json.getString('service_name'),
      videoUrl: json.getString('video'),
      quantity: json.getInt('quantity'),
      description: json.getString('description'),
      offers: json.getString('offers'),
      offerStatus: json.getInt('offer_status') == 1,
      planRate: json.getDouble('plan_rate'),
      cityName: json.getString('city_name'),
      stateName: json.getString('state_name'),
      address: json.getString('address'),
      latitude: json.getString('lat'),
      longitude: json.getString('lon'),
      closeReason: json.getString('close_reason'),
      status: json.getInt('status'),
      updateLimits: json.getInt('update_limits'),
      videoStatus: json.getInt('video_status'),
      businessPartnerApprove: json.getInt('business_partner_approve'),
      // Extract photos from a comma-separated string or list
      // servicePhotos:
      //     json.containsKey('photos')
      //         ? (json['photos'] is String
      //             ? json.getString('photos').split(',')
      //             : List<String>.from(json['photos']))
      //         : [],
      servicePhotos:
          json.containsKey('photos')
              ? (json['photos'] is String
                  ? json.getString('photos').split(',')
                  : json.getStringList('photos'))
              : [],
      merchantPhoto: json.getString('company_logo'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'category': categoryId,
      'subcategory': subcategoryId,
      'service': serviceTypeId,
      'service_name': serviceName.trim(),
      'video': videoUrl,
      'quantity': quantity,
      'description': description,
      'offers': offers,
      'offer_status': offerStatus ? 1 : 0,
      'plan_rate': planRate,
      'city_name': cityName,
      'state_name': stateName,
      'address': address,
      'lat': latitude,
      'lon': longitude,
      'close_reason': closeReason,
      'status': status,
      'update_limits': updateLimits,
      'video_status': videoStatus,
      'business_partner_approve': businessPartnerApprove,
      'photos': servicePhotos.join(','),
      'merchant_photo': merchantPhoto,
    };
  }

  MerchantServiceModel copyWith({
    int? id,
    int? merchantId,
    int? categoryId,
    int? subcategoryId,
    int? serviceTypeId,
    String? serviceName,
    String? videoUrl,
    int? quantity,
    String? description,
    String? offers,
    bool? offerStatus,
    double? planRate,
    String? cityName,
    String? stateName,
    String? address,
    String? latitude,
    String? longitude,
    String? closeReason,
    int? status,
    int? updateLimits,
    int? videoStatus,
    int? businessPartnerApprove,
    List<String>? servicePhotos,
    String? merchantPhoto,
  }) {
    return MerchantServiceModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceName: serviceName ?? this.serviceName,
      videoUrl: videoUrl ?? this.videoUrl,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      offers: offers ?? this.offers,
      offerStatus: offerStatus ?? this.offerStatus,
      planRate: planRate ?? this.planRate,
      cityName: cityName ?? this.cityName,
      stateName: stateName ?? this.stateName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      closeReason: closeReason ?? this.closeReason,
      status: status ?? this.status,
      updateLimits: updateLimits ?? this.updateLimits,
      videoStatus: videoStatus ?? this.videoStatus,
      businessPartnerApprove:
          businessPartnerApprove ?? this.businessPartnerApprove,
      servicePhotos: servicePhotos ?? this.servicePhotos,
      merchantPhoto: merchantPhoto ?? this.merchantPhoto,
    );
  }

  @override
  List<Object?> get props => [
    id,
    merchantId,
    categoryId,
    subcategoryId,
    serviceTypeId,
    serviceName,
    videoUrl,
    quantity,
    description,
    offers,
    offerStatus,
    planRate,
    cityName,
    stateName,
    address,
    latitude,
    longitude,
    closeReason,
    status,
    updateLimits,
    videoStatus,
    businessPartnerApprove,
    servicePhotos,
    merchantPhoto,
  ];

  bool get isNotEmpty => this != MerchantServiceModel.empty();

  @override
  String toString() {
    return 'MerchantServiceModel{id: $id, merchantId: $merchantId, categoryId: $categoryId, subcategoryId: $subcategoryId, serviceTypeId: $serviceTypeId, serviceName: $serviceName, videoUrl: $videoUrl, quantity: $quantity, description: $description, offers: $offers, offerStatus: $offerStatus, planRate: $planRate, cityName: $cityName, stateName: $stateName, address: $address, latitude: $latitude, longitude: $longitude, closeReason: $closeReason, status: $status, updateLimits: $updateLimits, videoStatus: $videoStatus, businessPartnerApprove: $businessPartnerApprove, servicePhotos: $servicePhotos}';
  }
}
