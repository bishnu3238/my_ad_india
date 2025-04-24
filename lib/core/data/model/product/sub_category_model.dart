import 'dart:convert';
 import 'package:flutter/foundation.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import '../../api/api_config.dart';

// Enum for status with additional utility
enum SubCategoryStatus {
  active(1, 'Active'),
  inactive(0, 'Inactive');

  const SubCategoryStatus(this.value, this.displayName);
  final int value;
  final String displayName;

  @override
  String toString() => displayName;
}

// Immutable SubCategoryModel with advanced features
@immutable
class SubCategoryModel extends BaseModel<SubCategoryModel> implements Searchable {
   final String name;
  final String imageUrl;
  final SubCategoryStatus status;
  final String categoryId;

  const SubCategoryModel({
    required super.id,
    required this.name,
    this.imageUrl = '',
    this.status = SubCategoryStatus.active,
    required this.categoryId,
  });

  // Factory constructor for JSON deserialization
  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id']?.toString() ?? '0',
      name: json['subcategory'] as String? ?? 'Unknown',
      imageUrl: json['image'] as String? ?? '',
      status: json.getStatus(
        'status',
        SubCategoryStatus.values,
        SubCategoryStatus.inactive,
      ),
      categoryId: json['category']?.toString() ?? '0',
    );
  }

  // Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcategory': name,
      'image': imageUrl,
      'status': status.value.toString(),
      'category': categoryId,
    }..removeWhere((_, v) => v == null || v == '');
  }

  // Copy with method for immutable updates
  SubCategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    SubCategoryStatus? status,
    String? categoryId,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // Validation
  bool get isValid => id.isNotEmpty && name.isNotEmpty && categoryId.isNotEmpty;

  // Utility properties
  bool get isActive => status == SubCategoryStatus.active;
  bool get hasImage => imageUrl.isNotEmpty && imageUrl != 'null';
  String get displayName => name.isEmpty ? 'Unnamed Subcategory' : name;


  String get fullImageUrl =>
      imageUrl.startsWith('http')
          ? imageUrl
          : "${ApiConfig.baseUrl}${ApiConfig.subCategoryImgPath}/$imageUrl";



  // Equatable implementation for value comparison
  @override
  List<Object?> get props => [id, name, imageUrl, status, categoryId];

  @override
  String toString() {
    return 'SubCategoryModel(id: $id, name: $name, status: $status, categoryId: $categoryId)';
  }

  @override
  String get displayDescription => '';

  @override
  bool matchesQuery(String query) {
    return searchableFields.values.any(
          (value) => value.toLowerCase().contains(query.toLowerCase()),
    );
  }

  @override
   SearchResultType get resultType => SearchResultType.subCategory;

  @override
   Map<String, String> get searchableFields => {
    'name': name,
  };

  static SubCategoryModel empty() => SubCategoryModel(id: '', name: '', categoryId: '');
}

// Extension for additional functionality
extension SubCategoryModelExtension on SubCategoryModel {
  // Check if matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.trim().toLowerCase().contains(lowerQuery.trim());
  }

  // Get image URL with fallback
  String getImageUrlWithFallback(String fallbackUrl) {
    return hasImage ? imageUrl : fallbackUrl;
  }

  // Async validation or enrichment (e.g., checking image availability)
  Future<SubCategoryModel> enrichWithNetworkCheck(
    String defaultImageUrl,
  ) async {
    try {
      // Simulate network check for image availability
      await Future.delayed(const Duration(milliseconds: 100));
      if (!hasImage) {
        return copyWith(imageUrl: defaultImageUrl);
      }
      return this;
    } catch (e) {
      return copyWith(imageUrl: defaultImageUrl);
    }
  }

  // Convert to a simplified display map
  Map<String, String> toDisplayMap() => {
    'id': id,
    'name': displayName,
    'categoryId': categoryId,
    'status': status.displayName,
  };
}

// Utility class for parsing lists
class SubCategoryParser {
  static List<SubCategoryModel> fromJsonList(dynamic data) {
    if (data is! List) return [];
    return data
        .map((item) => SubCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String toJsonList(List<SubCategoryModel> subcategories) {
    return jsonEncode(subcategories.map((e) => e.toJson()).toList());
  }
}
