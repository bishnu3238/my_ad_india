import 'package:dartz/dartz.dart';
import '../api/api_config.dart';
import '../model/banner_model.dart';
import 'package:pack/services/failure/failure.dart';
import '../../domain/repository/banner_repository.dart';
 import 'package:pack/services/api_services/api_services.dart';

class BannerRepositoryImpl extends BannerRepository {
  final ApiCallService _apiCallService;

  BannerRepositoryImpl(this._apiCallService);

  @override
  Future<Either<NetworkFailure, List<BannerModel>>> getBanners() async {
    return await _apiCallService
        .request<List<BannerModel>?>(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.bannersEndPoint,
          ),
          responseConverter: _convertBanner,
        )
        .then(
          (value) => value.fold((failure) => Left(failure), (result) {
            return Right(result.data!);
          }),
        );
  }

  List<BannerModel>? _convertBanner(json) {

    if (json is List) {
      return json.map((json) => BannerModel.fromJson(json)).toList();
    }
    return null;
  }


  @override
  String get repositoryName => 'BannerRepositoryImpl';
}
