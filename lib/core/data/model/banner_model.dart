import 'package:equatable/equatable.dart';
import 'package:pack/services/base_services/base_model.dart' show BaseModel;
import '../api/api_config.dart';
import 'package:pack/pack.dart';
import 'package:flutter/foundation.dart';

enum BannerStatus { active, inactive }

@immutable
class BannerModel extends BaseModel<BannerModel> {
  final String imageUrl;
  final BannerStatus status;

  const BannerModel({
    required super.id,
    this.imageUrl = '',
    this.status = BannerStatus.active,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json.getString('id', '0'),
      imageUrl: json.getString('image'),
      status: json.getStatus(
        'status',
        BannerStatus.values,
        BannerStatus.inactive,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'status': status == BannerStatus.inactive ? '0' : '1',
    };
  }

   BannerModel copyWith({String? id, String? imageUrl, BannerStatus? status}) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }

  // Validation and utilities
  bool get isValid => id.isNotEmpty && imageUrl.isNotEmpty;
  bool get isActive => status == BannerStatus.active;
  String get fullImageUrl =>
      imageUrl.startsWith('http')
          ? imageUrl
          : "${ApiConfig.baseUrl}${ApiConfig.bannersImgPath}/$imageUrl";

  @override
  List<Object?> get props => [id, imageUrl, status];

   BannerModel fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  static BannerModel empty() =>
      BannerModel(id: '', imageUrl: '', status: BannerStatus.inactive);
}
