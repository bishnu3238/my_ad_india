 import 'package:pack/services/service.dart';
import 'package:pack/pack.dart';
import '../../api/api_config.dart';

enum CategoryStatus { active, inactive }

// Category Model
class CategoryModel extends BaseModel<CategoryModel> implements Searchable {
    final String category, title, favIcon;
  @override
  final String searchImageUrl;
  final CategoryStatus status;

  const CategoryModel({
    required super.id,
    required this.category,
    required this.searchImageUrl,
    required this.favIcon,
    required this.title,
    required this.status,
  });

   CategoryModel copyWith({
    String? id,
    String? category,
    String? title,
    String? imageUrl,
    String? favIcon,
    CategoryStatus? status,
  }) => CategoryModel(
    id: id ?? this.id,
    category: category ?? this.category,
    title: title ?? this.title,
    searchImageUrl: imageUrl ?? this.searchImageUrl,
    favIcon: favIcon ?? this.favIcon,
    status: status ?? this.status,
  );
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'image': searchImageUrl,
      'fav_icon': favIcon,
      'title': title,
      'status': status == CategoryStatus.inactive ? '0' : '1',
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json.getString('id'),
      category: json.getString('category'),
      title: json.getString('title'),
      searchImageUrl: json.getString('image'),
      favIcon: json.getString('fav_icon'),
      status: json.getStatus(
        'status',
        CategoryStatus.values,
        CategoryStatus.active,
      ),
    );
  }

  // Validation and utilities
  bool get isValid => id.isNotEmpty && searchImageUrl.isNotEmpty;
  bool get isActive => status == CategoryStatus.active;
  String get fullImageUrl =>
      searchImageUrl.startsWith('http')
          ? searchImageUrl
          : "${ApiConfig.baseUrl}${ApiConfig.categoryImgPath}/$searchImageUrl";

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $category, imageUrl: $searchImageUrl, favIcon: $favIcon, title: $title, status: $status}';
  }

  @override
  String get displayDescription => category;

  @override
  String get displayName => title;

  @override
  bool matchesQuery(String query) {
    return searchableFields.values.any(
      (value) => value.toLowerCase().contains(query.toLowerCase()),
    );
  }

  @override
  List<Object?> get props => [id, category, title, searchImageUrl, favIcon, status];

  @override
  SearchResultType get resultType => SearchResultType.category;

  @override
  Map<String, String> get searchableFields => {
    'title': title,
    'category': category,
  };

  static CategoryModel empty() => CategoryModel(
    id: '',
    category: 'Select Category',
    searchImageUrl: '',
    favIcon: '',
    title: '',
    status: CategoryStatus.active,
  );

   CategoryModel fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
