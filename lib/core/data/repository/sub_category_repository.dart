import 'package:dartz/dartz.dart';
import 'package:my_ad/core/domain/data_store/sub_category_store.dart';
import 'package:pack/services/service.dart';
import '../api/api_config.dart';
import 'package:pack/services/api_services/api_services.dart';
import 'package:pack/services/api_services/src/request_config.dart';

import '../../domain/repository/sub_category_repository.dart';
import '../model/product/sub_category_model.dart';

class SubCategoryRepositoryImpl implements SubCategoryRepository {
  final ApiCallService _apiCallService;
  SubCategoryRepositoryImpl(this._apiCallService,);

  @override
  Future<Either<NetworkFailure, List<SubCategoryModel>>>
  getSubCategories() async {
    return _apiCallService
        .request<List<SubCategoryModel>?>(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.subCategories,
          ),

          responseConverter: (data) {
            final List<SubCategoryModel> subCategories = [];
            for (final item in data) {
              subCategories.add(SubCategoryModel.fromJson(item));
            }
            return subCategories;
          },
        )
        .then(
          (value) => value.fold((failure) => left(failure), (result) {
            if(result.data == null) return Right([]);
             return Right(result.data!);
          }),
        );
  }
}
