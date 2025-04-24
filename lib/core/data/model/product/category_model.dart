import 'package:pack/services/service.dart';
import 'package:pack/pack.dart';
import '../../api/api_config.dart';

enum CategoryStatus { active, inactive }

// Category Model
class CategoryModel extends BaseModel<CategoryModel> implements Searchable {
  final String category, title, favIcon;
  @override
  final String imageUrl;
  final CategoryStatus status;

  const CategoryModel({
    required super.id,
    required this.category,
    required this.imageUrl,
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
    imageUrl: imageUrl ?? this.imageUrl,
    favIcon: favIcon ?? this.favIcon,
    status: status ?? this.status,
  );
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'image': imageUrl,
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
      imageUrl: json.getString('image'),
      favIcon: json.getString('fav_icon'),
      status: json.getStatus(
        'status',
        CategoryStatus.values,
        CategoryStatus.active,
      ),
    );
  }

  // Validation and utilities
  bool get isValid => id.isNotEmpty && imageUrl.isNotEmpty;
  bool get isEmpty => this == empty();
  bool get isActive => status == CategoryStatus.active;
  String get fullImageUrl =>
      imageUrl.startsWith('http')
          ? imageUrl
          : "${ApiConfig.baseUrl}${ApiConfig.categoryImgPath}/$imageUrl";
  String get fullFavIconUrl =>
      favIcon.startsWith('http')
          ? favIcon
          : "${ApiConfig.baseUrl}${ApiConfig.categoryImgPath}/$favIcon";

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $category, imageUrl: $imageUrl, favIcon: $favIcon, title: $title, status: $status}';
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
  List<Object?> get props => [id, category, title, imageUrl, favIcon, status];

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
    imageUrl: '',
    favIcon: '',
    title: '',
    status: CategoryStatus.active,
  );

  CategoryModel fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
