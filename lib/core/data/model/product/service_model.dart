import 'dart:developer' as dev;

  import 'package:pack/services/service.dart';
import 'package:pack/pack.dart';

import '../../api/api_config.dart';

// Status enum for service status
enum ServiceStatus { inactive, active }

// Service Image model
class ServiceImage extends BaseModel {
  final String image;

  const ServiceImage({required super.id, required this.image});

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json.getString('id'),
      image: json.getString('image'),
    );
  }

  @override
  String toString() {
    return 'ServiceImage{image: $image}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image};
  }

  ServiceImage copyWith({String? id, String? image}) {
    return ServiceImage(id: id ?? this.id, image: image ?? this.image);
  }

  @override
  List<Object?> get props => [id, image];

  @override
  String get id => throw UnimplementedError();
}

// Service model
class ServiceModel extends BaseModel<ServiceModel> implements Searchable {
  final String serviceName;
  final String description;
  final double price;
  final ServiceStatus status;
  final int categoryId;
  final String? categoryName;
  final int subcategoryId;
  final String? subcategoryName;
  final List<ServiceImage> imagesUrl;

  const ServiceModel({
    required super.id,
    required this.serviceName,
    this.description = '',
    this.price = 0.0,
    this.status = ServiceStatus.active,
    required this.categoryId,
    this.categoryName,
    required this.subcategoryId,
    this.subcategoryName,
    this.imagesUrl = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    try {
      final List<ServiceImage> serviceImages = [];

      serviceImages.add(ServiceImage(id: json.getString('id'), image: json.getString('service_image')));

      final imagesJson = json.get<List<dynamic>>('images', []);
      for (var imageJson in imagesJson) {
        if (imageJson is Map<String, dynamic>) {
          serviceImages.add(ServiceImage.fromJson(imageJson));
        }
      }

      return ServiceModel(
        id: json.getString('id'),
        serviceName: json.getString('service_name'),
        // description: json.getString('description'),
        // price: json.getDouble('price'),
        status: json.getStatus<ServiceStatus>(
          'status',
          ServiceStatus.values,
          ServiceStatus.inactive,
        ),
        categoryId: json.getInt('category_id'),
        categoryName: json.getString('category_name'),
        subcategoryId: json.getInt('subcategory_id'),
        subcategoryName: json.getString('subcategory_name'),
        imagesUrl: serviceImages,
      );
    } catch (e) {
      throw ParsingException('$e');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'description': description,
      'price': price,
      'status': status == ServiceStatus.active ? 1 : 0,
      'category': categoryId,
      'category_name': categoryName,
      'subcategory': subcategoryId,
      'subcategory_name': subcategoryName,
      'images': imagesUrl.map((image) => image.toJson()).toList(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? serviceName,
    String? description,
    double? price,
    ServiceStatus? status,
    int? categoryId,
    String? categoryName,
    int? subcategoryId,
    String? subcategoryName,
    List<ServiceImage>? images,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      imagesUrl: [...images ?? [], ...imagesUrl],
    );
  }

  String get fullImageUrl {
    if (imagesUrl.isNotEmpty) {
      return imagesUrl.first.image.startsWith('http')
          ? imagesUrl.first.image
          : "${ApiConfig.baseUrl}${ApiConfig.serviceImgPath}/${imagesUrl.first.image}";
    }
    return 'assets/images/placeholder.png'; // Fallback image path
  }

  bool get hasImages => imagesUrl.isNotEmpty;

  int get imageCount => imagesUrl.length;

  @override
  List<Object?> get props => [
    id,
    serviceName,
    price,
    status,
    categoryId,
    subcategoryId,
    imagesUrl,
  ];

  @override
  String get displayDescription => description;

  @override
  String get displayName => serviceName;

  @override
  String? get searchImageUrl => fullImageUrl;

  @override
  bool matchesQuery(String query) {
    return serviceName.toLowerCase().contains(query.toLowerCase()) ||
        description.toLowerCase().contains(query.toLowerCase());
  }

  @override
  SearchResultType get resultType => SearchResultType.service;

  @override
  Map<String, String> get searchableFields => {
    'service_name': serviceName,
    'description': description,
  };

  static ServiceModel empty() =>
      ServiceModel(id: '', serviceName: '', categoryId: 0, subcategoryId: 0);

  @override
  String toString() {
    return 'ServiceModel{id: $id, serviceName: $serviceName, description: $description, price: $price, status: $status, categoryId: $categoryId, categoryName: $categoryName, subcategoryId: $subcategoryId, subcategoryName: $subcategoryName, imagesUrl: $imagesUrl}';
  }
}

class BaseException implements Exception {
  final String message;

  BaseException(this.message);

  @override
  String toString() {
    return 'BaseException: $message';
  }
}

class ParsingException extends BaseException {
  ParsingException(super.message);

  @override
  String toString() {
    return 'ParsingError: $message';
  }
}
