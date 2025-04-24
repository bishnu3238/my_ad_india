import 'dart:developer' as dev;
import 'dart:io' show File;

import 'package:dartz/dartz.dart';
 import 'package:pack/services/base_services/base_service.dart';
import 'package:pack/services/connectivity_service/connectivity_service.dart';
import 'package:pack/services/failure/failure.dart';

import '../data/model/model.dart';

import '../domain/data_store/data_store.dart';
import '../domain/repository/merchant_dashboard_repository.dart';

class MerchantDashboardService {
  final MerchantDashboardStore _store;
  final MerchantDashboardRepository _repository;
  final ConnectivityService _connectivityService;

  const MerchantDashboardService(
    this._store,
    this._repository,
    this._connectivityService,
  );

  Future<void> fetchMerchantServices() async {
    _store.setStatus(DataStoreStatus.loading);

    // Check if the merchant is authenticated
    final isAuthenticated = _store.isLoggedIn;
    if (!isAuthenticated) {
      _store.setError(
        OperationFailure(message: 'Merchant is not authenticated.'),
      );
      return;
    }
    final merchantId = _store.entity?.merchantData.merchant.id;
    if (merchantId == null) {
      _store.setError(
        OperationFailure(message: 'Merchant ID is not available.'),
      );
      return;
    }
    final requestData = PostFetchMerchantServices(merchantId: '$merchantId');
    final result = await _repository.fetchMerchantServices(requestData);
    result.fold(
      (failure) {
        _store.setStatus(DataStoreStatus.error);
        _store.setError(failure.asOperationFailure);
      },
      (services) {
        _store.setStatus(DataStoreStatus.loaded);
        _store.setEntity(_store.entity?.copyWith(services: services));
      },
    );
  }

  Future<Either<Failure, MerchantPlanAccessModel>>
  fetchMerchantPlanAccess() async {
    _store.setStatus(DataStoreStatus.loading);
    // Check if the merchant is authenticated
    final isAuthenticated = _store.isLoggedIn;
    if (!isAuthenticated) {
      _store.setError(
        OperationFailure(message: 'Merchant is not authenticated.'),
      );
      return left(_store.error!);
    }
    // Check if the merchant ID is available
    final merchantId = _store.entity?.merchantData.merchant.id;
    if (merchantId == null) {
      _store.setError(
        OperationFailure(message: 'Merchant ID is not available.'),
      );
      return left(_store.error!);
    }
    final request = FetchMerchantPlanAccessRequest(merchantId: '$merchantId');

    final result = await _repository.fetchMerchantPlanAccess(request: request);
    result.fold(
      (failure) {
        _store.setStatus(DataStoreStatus.error);

        _store.setError(failure.asOperationFailure);
      },
      (planAccess) {
        _store.setStatus(DataStoreStatus.loaded);

        _store.setEntity(_store.entity?.copyWith(planAccess: planAccess));
      },
    );
    if (result.isLeft()) return left(_store.error!);
    return right(result.getRight());
  }

  Future<Either<Failure, bool>> submitServiceRequest(
    SubmitServiceRequest request,
  ) async {
    _store.setStatus(DataStoreStatus.loading);
    // Check if the network is available
    final isConnected = await _connectivityService.hasActiveInternet();
    if (!isConnected) {
      _store.setError(OperationFailure(message: 'No internet connection.'));
      return left(_store.error!);
    }

    // Check if the merchant ID is available
    if (request.merchantId.isEmpty) {
      _store.setError(
        OperationFailure(message: 'Merchant ID is not available.'),
      );
      return left(_store.error!);
    }

    return _repository.submitServiceRequest(request).then((result) {
      return result.fold(
        (failure) {
          _store.setError(failure.asOperationFailure);
          return left(_store.error!);
        },
        (response) {
          dev.log('MERCHANT=>ADD-SERVICE: is successful = ${response.success}');

          if (response.success) {
            if (request.requestType == ServiceRequestType.add &&
                response.service != null) {
              // Add new service to store
              _store.setEntity(
                _store.entity?.copyWith(
                  services: [...?_store.entity?.services, response.service!],
                ),
              );
            } else if (request.requestType == ServiceRequestType.update &&
                response.service != null) {
              // Update existing service in store
              _store.setEntity(
                _store.entity?.copyWith(
                  services:
                      _store.entity?.services.map((s) {
                        return s.id == response.service!.id
                            ? response.service!
                            : s;
                      }).toList(),
                ),
              );
            } else if (request.requestType == ServiceRequestType.delete) {
              // Remove service from store
              _store.setEntity(
                _store.entity?.copyWith(
                  services:
                      _store.entity?.services
                          .where(
                            (s) =>
                                s.id != int.tryParse(response.serviceId ?? '0'),
                          )
                          .toList(),
                ),
              );
            }
            return right(true);
          } else {
            _store.setError(OperationFailure(message: response.message));
            return left(_store.error!);
          }
        },
      );
    });
  }


  Future<Either<Failure, UploadImageResponse>> uploadMerchantBusinessImage({
    required int merchantId,
    required File imageFile,
    required dynamic Function(int, int)? onSendProgress,
  }) async {
    _store.setStatus(DataStoreStatus.loading);
    final isConnected = await _connectivityService.hasActiveInternet();
    if (!isConnected) {
      _store.setError(OperationFailure(message: 'No internet connection.'));
      return left(_store.error!);
    }

    // Check if the merchant ID is available
    if (_store.entity?.merchantData.merchant.id == null) {
      _store.setError(
        OperationFailure(message: 'Merchant ID is not available.'),
      );
      return left(_store.error!);
    }
    return await _repository.uploadMerchantBusinessImage(
      merchantId: merchantId,
      imageFile: imageFile,
      onSendProgress: onSendProgress,
    );
  }

  Future<Either<Failure, UploadImageResponse>> uploadServiceImages({
    required int merchantId,
    required File imageFile,
    required dynamic Function(int, int)? onSendProgress,
  }) async {
    _store.setStatus(DataStoreStatus.loading);
    final isConnected = await _connectivityService.hasActiveInternet();
    if (!isConnected) {
      _store.setError(OperationFailure(message: 'No internet connection.'));
      return left(_store.error!);
    }

    // Check if the merchant ID is available
    if (_store.entity?.merchantData.merchant.id == null) {
      _store.setError(
        OperationFailure(message: 'Merchant ID is not available.'),
      );
      return left(_store.error!);
    }
    return await _repository.uploadServiceImages(
      merchantId: merchantId,
      imageFile: imageFile,
      onSendProgress: onSendProgress,
    );
  }

  Future<Either<Failure, UploadVideoResponse>> uploadServiceVideo(
    UploadMerchantServiceVideoRequest request,
    dynamic Function(int, int)? onSendProgress,
  ) async {
    _store.setStatus(DataStoreStatus.loading);

    return _repository.uploadServiceVideo(
      request: request,
      onSendProgress: onSendProgress,
    );
  }
}
