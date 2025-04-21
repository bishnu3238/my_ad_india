import 'package:dartz/dartz.dart';

import 'package:pack/services/service.dart';
 import '../../domain/repository/category_repository.dart';
import '../api/api_config.dart';
import '../model/product/category_model.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final ApiCallService _apiCallService;

  CategoryRepositoryImpl(this._apiCallService);

  @override
  Future<Either<NetworkFailure, List<CategoryModel>>> fetchCategories() async {
    return _apiCallService
        .request<List<CategoryModel>?>(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.categories,
          ),
          responseConverter:  (json) => convertCategory(json),
        )
        .then(
          (value) => value.fold((failure) => left(failure), (result) {
            if (result.data == null) return right([]);
             return right(result.data!);
          }),
        );
  }

  List<CategoryModel>? convertCategory(json) {
    if (json is List) {
      return json.map((json) => CategoryModel.fromJson(json)).toList();
    }
    return null;
  }






  @override
   String get repositoryName => 'CategoryRepositoryImpl';
}
