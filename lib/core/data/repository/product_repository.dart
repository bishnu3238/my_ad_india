import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';

import 'package:pack/services/api_services/api_services.dart';
import 'package:pack/services/failure/failure.dart';

import '../../domain/repository/product_repository.dart';
import '../api/api_config.dart';
import '../model/model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiCallService apiCallService;

  ProductRepositoryImpl({required this.apiCallService});

  @override
  Future<Either<Failure, List<ProductModel>>> fetchEadProducts() async {
    return await apiCallService
        .request(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.products,
          ),
          responseConverter: (data) => EadProductResponse.fromJson(data),
        )
        .then(
          (value) => value.fold(
            (failure) {
              dev.log(failure.message);
              return left(NetworkFailure(message: failure.message));
            },
            (response) {
              if (response.isSuccess) return right(response.data!.products);

              return left(
                UnexpectedFailure(message: 'Unable to fetch products'),
              );
            },
          ),
        );
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByCategory(
    String i,
  ) async {
    return await apiCallService
        .request(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.products,
            queryParameters: {'category_id': i},
          ),
          responseConverter: (data) => EadProductResponse.fromJson(data),
        )
        .then(
          (value) => value.fold(
            (failure) => left(NetworkFailure(message: failure.message)),
            (response) {
              if (response.isSuccess) return right(response.data!.products);

              return left(
                UnexpectedFailure(message: 'Unable to fetch products'),
              );
            },
          ),
        );
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchNearByProductsOfUser(
    FetchNearByProductsOfUserPayload payload,
  ) async {
    return await apiCallService
        .request(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.nearbyProducts,
            method: RequestMethod.post,
            body: jsonEncode(payload.toJson()),
          ),
          responseConverter: (data) {
            dev.log('FETCH NEARBY PREDICTS ${data.toString()}');
            return EadProductResponse.fromJson(data);
          },
        )
        .then(
          (value) => value.fold(
            (failure) {
              dev.log(failure.message);
              return left(NetworkFailure(message: failure.message));
            },
            (response) {
              if (response.isSuccess) return right(response.data!.products);

              return left(
                UnexpectedFailure(message: 'Unable to fetch products'),
              );
            },
          ),
        );
  }
}
