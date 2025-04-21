import 'package:flutter/material.dart';
import 'package:pack/services/base_services/base_model.dart' show BaseModel;

class CityModel  extends BaseModel<CityModel> {
  final String name, state;
  final IconData? icon;
  final bool isPopular;

  const CityModel({
    required super.id,
    required this.name,
    this.state = '', // Default to empty string
    this.icon,
    this.isPopular = false,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['city'],
      state: json['state_id'] ?? '',
      isPopular: json['is_popular'] == 0 ? false : true,
    );
  }

  @override
  CityModel copyWith() {
    throw UnimplementedError();
  }



  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

