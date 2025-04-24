import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:pack/pack.dart';
import 'merchant_model.dart';

class MerchantServiceDetailsModel extends Equatable {
  final int? id;
  final int merchantId;
  final String categoryId;
  final String? subCategoryId;
  final String serviceId;
  final Status status;
  final DateTime date;

  const MerchantServiceDetailsModel({
    this.id,
    required this.merchantId,
    required this.categoryId,
    this.subCategoryId,
    required this.serviceId,
    required this.status,
    required this.date,
  });

  factory MerchantServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    dev.log('Parsing MerchantServiceDetailsModel JSON: $json');
    return MerchantServiceDetailsModel(
      id: json.getInt('id'),
      merchantId: json.getInt('merchant_id'),
      categoryId: json.getString('category_id'),
      subCategoryId: json.getString('sub_category_id'),
      serviceId: json.getString('service_id'),
      status: json.getStatus('status', Status.values, Status.inActive),
      date: json.getDateTime('date'),
    );
  }

  factory MerchantServiceDetailsModel.fromLocalMap(Map<String, dynamic> json) {
    dev.log('MERCHANT-SERVICE-DETAILS-FROM-LOCAL-MAP $json');
    return MerchantServiceDetailsModel(
      id: json.getInt('id'),
      merchantId: json.getInt('merchant_id'),
      categoryId: json.getString('category_id'),
      subCategoryId: json.getString('sub_category_id'),
      serviceId: json.getString('service_id'),
      status: json.getStatus('status', Status.values, Status.inActive),
      date: json.getDateTime('date'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'service_id': serviceId,
      'status': status == Status.active ? 1 : 0,
      'date': date.toIso8601String(),
    };
  }

  MerchantServiceDetailsModel copyWith({
    int? id,
    int? merchantId,
    String? categoryId,
    String? subCategoryId,
    String? serviceId,
    Status? status,
    DateTime? date,
  }) {
    return MerchantServiceDetailsModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      serviceId: serviceId ?? this.serviceId,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  static MerchantServiceDetailsModel empty() {
    return MerchantServiceDetailsModel(
      id: null,
      merchantId: 0,
      categoryId: '',
      subCategoryId: null,
      serviceId: '',
      status: Status.inActive,
      date: DateTime.now(),
    );
  }

  bool get isActive => status == Status.active;

  @override
  List<Object?> get props => [
    id,
    merchantId,
    categoryId,
    subCategoryId,
    serviceId,
    status,
    date,
  ];

  @override
  String toString() {
    return 'MerchantServiceDetailsModel{id: $id, merchantId: $merchantId, categoryId: $categoryId, subCategoryId: $subCategoryId, serviceId: $serviceId, status: $status, date: $date}';
  }
}