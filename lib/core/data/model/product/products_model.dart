import 'package:my_ad/core/data/api/api_config.dart';
import 'package:pack/services/service.dart';

import 'package:pack/pack.dart';
import '../../../constant/image.dart';
import '../merchant/merchant_model.dart';

enum OfferStatus { inactive, active }

class Merchant {
  final String id;
  final String username;
  final String companyName;
  final String email;
  final String mobile;
  final String imgUrl;

  Merchant({
    required this.id,
    required this.username,
    required this.companyName,
    required this.email,
    required this.mobile,
    this.imgUrl = AppImage.defaultMerchantImg,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json.getString('merchant_id'),
      username: json.getString('merchant_username'),
      companyName: json.getString('merchant_company'),
      email: json.getString('merchant_email'),
      mobile: json.getString('merchant_mobile'),
      imgUrl: json.getString('merchant_img'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': id,
      'merchant_username': username,
      'merchant_company': companyName,
      'merchant_email': email,
      'merchant_mobile': mobile,
      'merchant_img': imgUrl,
    };
  }
}

class ProductImages {
  String id, productId, image;
  Status status;
  DateTime date;

  ProductImages({
    required this.id,
    required this.productId,
    required this.image,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'image': image,
      'status': status,
      'date': date,
    };
  }

  factory ProductImages.fromMap(Map<String, dynamic> map) {
    return ProductImages(
      id: map['id'] as String,
      productId: map['productId'] as String,
      image: map['image'] as String,
      status: map['status'] as Status,
      date: map['date'] as DateTime,
    );
  }
}

class ProductModel extends BaseModel<ProductModel> implements Searchable {
  final Merchant merchant;
  final int categoryId;
  final String categoryTitle;
  final int subcategoryId;
  final String subcategoryName;
  final int serviceId;
  final String serviceName;
  final String serviceFullName;
  final String video;
  final int quantity;
  final String description; // Base64 encoded, can decode if needed
  final String offers; // Base64 encoded, can decode if needed
  final OfferStatus offerStatus;
  final double planRate;
  final int cityId;
  final String cityName;
  final int stateId;
  final String stateName;
  final String address;
  final double latitude;
  final double longitude;
  final String? closeReason;
  final Status status;
  final int updateLimits;
  final Status videoStatus;

  final Status businessPartnerApprove;
  final List<ProductImages> images;

  const ProductModel({
    required super.id,
    required this.merchant,
    required this.categoryId,
    required this.categoryTitle,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceFullName,
    required this.video,
    required this.quantity,
    required this.description,
    required this.offers,
    required this.offerStatus,
    required this.planRate,
    required this.cityId,
    required this.cityName,
    required this.stateId,
    required this.stateName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.closeReason,
    required this.status,
    required this.updateLimits,
    required this.videoStatus,
    required this.businessPartnerApprove,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<ProductImages> productImages = [];

    if (json.containsKey('images') && json['images'] != null) {
      productImages =
          (json['images'] as List)
              .map(
                (img) => ProductImages.fromMap({
                  'id': img['id'] as String,
                  'productId': img['ead_product_id'] as String,
                  'image': img['image'] as String,
                  'status':
                      img['status'] == '1' ? Status.active : Status.inActive,
                  'date': DateTime.parse(img['date']),
                }),
              )
              .toList();
    }
    return ProductModel(
      id: json.getString('id'),
      merchant: Merchant.fromJson(json),
      categoryId: json.getInt('category'),
      categoryTitle: json.getString('category_title', 'Unknown Category'),
      subcategoryId: json.getInt('subcategory'),
      subcategoryName: json.getString(
        'subcategory_name',
        'Unknown Subcategory',
      ),
      serviceId: json.getInt('service'),
      serviceName: json.getString('service_name'),
      serviceFullName: json.getString('service_full_name', 'Unknown Service'),
      video: json.getString('video'),
      images: productImages,
      quantity: json.getInt('quantity'),
      description: json.getString('description'),
      offers: json.getString('offers'),
      offerStatus: json.getStatus(
        'offer_status',
        OfferStatus.values,
        OfferStatus.inactive,
      ),
      planRate: json.getDouble('plan_rate'),
      cityId: json.getInt('city'),
      cityName: json.getString('city_name'),
      stateId: json.getInt('state'),
      stateName: json.getString('state_name'),
      address: json.getString('address'),
      latitude: json.getDouble('lat'),
      longitude: json.getDouble('lon'),
      closeReason:
          json.containsKey('close_reason') && json['close_reason'] != null
              ? json.getString('close_reason')
              : null,
      status: json.getStatus('status', Status.values, Status.inActive),
      updateLimits: json.getInt('update_limits'),
      videoStatus: json.getStatus(
        'video_status',
        Status.values,
        Status.inActive,
      ),
      businessPartnerApprove: json.getStatus(
        'business_partner_approve',
        Status.values,
        Status.inActive,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchant.id,
      'category': categoryId,
      'category_title': categoryTitle,
      'subcategory': subcategoryId,
      'subcategory_name': subcategoryName,
      'service': serviceId,
      'service_name': serviceName,
      'service_full_name': serviceFullName,
      'video': video,
      'quantity': quantity,
      'description': description,
      'offers': offers,
      'offer_status': offerStatus == OfferStatus.active ? '1' : '0',
      'plan_rate': planRate,
      'city': cityId,
      'city_name': cityName,
      'state': stateId,
      'state_name': stateName,
      'address': address,
      'lat': latitude,
      'lon': longitude,
      'close_reason': closeReason,
      'status': status == Status.active ? '1' : '0',
      'update_limits': updateLimits,
      'video_status': videoStatus == Status.active ? '1' : '0',
      'business_partner_approve':
          businessPartnerApprove == Status.active ? '1' : '0',
      'merchant_username': merchant.username,
      'merchant_company': merchant.companyName,
      'merchant_email': merchant.email,
      'merchant_mobile': merchant.mobile,
    };
  }

  String get fullImgUrl => images[0].image;

  @override
  String get displayDescription => description;

  @override
  String get displayName => serviceName;

  @override
  String? get imageUrl => images[0].image;

  @override
  bool matchesQuery(String query) {
    return searchableFields.values.any(
      (value) => value.toLowerCase().contains(query.toLowerCase()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    merchant,
    serviceName,
    description,
    offers,
    status,
  ];

  @override
  SearchResultType get resultType => SearchResultType.eadProduct;

  @override
  Map<String, dynamic> get searchableFields => {
    'service_name': serviceName,
    'description': description,
  };

  ProductModel copyWith() {
    throw UnimplementedError();
  }
}
