import 'dart:developer' as dev;
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/src/types/image_source.dart';
import 'package:pack/services/service.dart';

import '../../domain/repository/repository.dart';
import '../../services/plan_feature_manager.dart';
import '../api/api_config.dart';
import '../model/model.dart';
import 'package:mime/mime.dart';

import 'dart:core';

class MerchantDashboardRepositoryImpl implements MerchantDashboardRepository {
  final ApiCallService _apiService;
  MerchantDashboardRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, MerchantPlanAccessModel>> fetchMerchantPlanAccess({
    required FetchMerchantPlanAccessRequest request,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiService.request<MerchantPlanAccessResponse>(
        config: RequestConfig(
          baseUrl: ApiConfig.baseUrl,
          endpoint: ApiConfig.merchantService,
          queryParameters: {'action': 'get_merchant_plan_access'},
          method: RequestMethod.post,
          body: request.toJson(),
        ),
        responseConverter: (data) => MerchantPlanAccessResponse.fromJson(data),
      );

      return response.fold((failure) => Left(failure), (result) async {
        if (!result.data!.success || result.data == null) {
          return Left(
            NetworkFailure(
              message: 'Failed to fetch plan access: ${result.data!.message}',
            ),
          );
        }

        return Right(result.data!.data!);
      });
    } catch (e) {
      dev.log('Error getting merchant plan access: $e');
      return Left(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MerchantServiceModel>>> fetchMerchantServices(
    PostFetchMerchantServices request,
  ) async {
    try {
      final response = await _apiService.request<MerchantServiceResponse>(
        config: RequestConfig(
          baseUrl: ApiConfig.baseUrl,
          endpoint: ApiConfig.merchantService,
          method: RequestMethod.post,
          queryParameters: {'action': 'fetch_services'},
          body: request.toJson(),
        ),
        responseConverter: (data) => MerchantServiceResponse.fromJson(data),
      );
      return response.fold((failure) => left(failure), (result) {
        if (result.data!.services.isEmpty) {
          return Left(
            NetworkFailure(message: 'No services found for the merchant.'),
          );
        }
        return Right(result.data!.services);
      });
    } catch (error) {
      return Left(NetworkFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, MerchantServiceModel>>
  fetchMerchantServicesByServiceId(String serviceId) {
    // TODO: implement fetchMerchantServicesByServiceId
    throw UnimplementedError();
  }

  @override
  Future<Either<NetworkFailure, ServiceValidationResponse>>
  validateServiceOperation(ValidateServiceOperationRequest request) async {
    try {
      final planAccessResult = await fetchMerchantPlanAccess(
        request: FetchMerchantPlanAccessRequest(merchantId: request.merchantId),
      );

      return planAccessResult.fold(
        (failure) => Left(NetworkFailure(message: failure.message)),
        (planAccess) async {
          // Use the new PlanFeatureManager for validation
          final featureManager = PlanFeatureManager(planAccess);
          dev.log('What is your plan Validaty Date?: ${planAccess.validUntil}');
          dev.log(
            'Is your plan Validat?: ${planAccess.validUntil!.isAfter(DateTime.now())}',
          );
          // Check subscription validity
          if (!featureManager.isSubscriptionValid) {
            return Right(
              ServiceValidationResponse.notValid(
                message: 'Your subscription has expired. Please renew.',
                isValid: false,
              ),
            );
          }

          // Perform operation-specific validations
          String? validationError;
          switch (request.operationType) {
            case OperationType.add:
              if (!planAccess.canAddMoreServices()) {
                validationError =
                    'You have reached the maximum number of services allowed by your plan.';
              } else {
                validationError = featureManager.validateService(
                  request.service,
                );
              }
              break;
            case OperationType.update:
              if (!planAccess.canUpdateService()) {
                validationError =
                    'You have reached the maximum number of updates allowed by your plan.';
              } else if (request.service.updateLimits >=
                  planAccess.remainingUpdates) {
                validationError = 'Service update limit exceeded.';
              } else {
                validationError = featureManager.validateService(
                  request.service,
                );
              }
              break;
            case OperationType.delete:
              // No additional restrictions typically for deletion
              break;
          }

          if (validationError != null) {
            return Right(
              ServiceValidationResponse.notValid(message: validationError),
            );
          }

          // Fetch server-side validation as a backup
          final validationResponse = await _apiService
              .request<ServiceValidationResponse>(
                config: RequestConfig(
                  baseUrl: ApiConfig.baseUrl,
                  endpoint: ApiConfig.merchantService,
                  queryParameters: {'action': 'validate_service_operation'},
                  method: RequestMethod.post,
                  body: request.toJson(),
                ),
                responseConverter:
                    (data) => ServiceValidationResponse.fromJson(data),
              );

          return validationResponse.fold((failure) => Left(failure), (result) {
            dev.log(
              'WHAT IS THE RESULT OF THE SERVICE VALIDATION RESPONSE?: ${result.data!}',
            );
            if (!result.data!.success) {
              // return Right({'isValid': false, 'message': result.data!.message});
              return Right(result.data!);
            }
            // If server validation is successful, return valid response
            return Right(
              ServiceValidationResponse.isValid(
                message: result.data!.message,
                timestamp: result.data!.timestamp,
                isValid: true,
              ),
            );
          });
        },
      );
    } catch (e) {
      dev.log('Error validating service operation: $e');
      return Left(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  /// Submit service request with advanced features
  @override
  Future<Either<Failure, SubmitServiceResponse>> submitServiceRequest(
    SubmitServiceRequest request,
  ) async {
    try {
      // Validate before submission if requested
      // if (request.validateFirst) {
      //   final validationResult = await validateServiceOperation(
      //     ValidateServiceOperationRequest(
      //       merchantId: request.merchantId,
      //       service: request.service,
      //       subscription: MerchantSubscriptionModel.empty(),
      //     ),
      //   );
      //   return validationResult.fold((failure) => Left(failure), (result) {
      //     dev.log('WHAT IS THE RESULT OF THE VALIDATION?: ${result.isValid}');
      //     if (!result.isValid) {
      //       return Left(NetworkFailure(message: result.message));
      //     }
      return _submitRequest(request);
      //     });
      //   }
      //   return _submitRequest(request);
    } catch (e) {
      dev.log('Error submitting service request: $e');
      return Left(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  Future<Either<Failure, SubmitServiceResponse>> _submitRequest(
    SubmitServiceRequest request,
  ) async {
    final response = await _apiService.request<SubmitServiceResponse>(
      config: RequestConfig(
        baseUrl: ApiConfig.baseUrl,
        endpoint: ApiConfig.merchantService,
        queryParameters: {'action': 'submit_service_request'},
        method: RequestMethod.post,
        body: request.toJson(),
      ),
      responseConverter: (data) {
        dev.log('IS WE GET RESPONSE FOR SUBMIT SERVICE REQUEST ?: $data');
        return SubmitServiceResponse.fromJson(data);
      },
    );

    return response.fold((failure) => Left(failure), (result) {
      if (!result.data!.success!) {
        return Left(NetworkFailure(message: result.data!.message!));
      }
      return Right(result.data!);
    });
  }

  /// Helper method to check remaining updates for a specific service
  Future<Either<NetworkFailure, int>> getRemainingUpdatesForService({
    required MerchantModel merchant,
    required int serviceId,
  }) async {
    final planAccessResult = await fetchMerchantPlanAccess(
      request: FetchMerchantPlanAccessRequest(merchantId: '${merchant.id}'),
    );

    return planAccessResult.fold(
      (failure) => Left(NetworkFailure(message: failure.message)),
      (planAccess) {
        // Fetch service to get current update count
        // This assumes an API endpoint exists; adjust as needed
        return Right(
          planAccess.remainingUpdates,
        ); // Simplified; add service-specific logic if needed
      },
    );
  }

  @override
  String get repositoryName => 'MerchantDashboardRepositoryImpl';

  @override
  Future<Either<Failure, UploadImageResponse>> uploadServiceImages({
    required int merchantId,
    required File imageFile,
    required dynamic Function(int, int)? onSendProgress,
  }) async {
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    if (![
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
    ].contains(mimeType)) {
      return Left(NetworkFailure(message: 'Invalid image format: $mimeType'));
    }
    final config = RequestConfig.forFileUpload(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantServiceImageUpload,
      files: {'image': imageFile, 'mime_type': mimeType},
      fields: {'merchant_id': '$merchantId'},
      onSendProgress: onSendProgress,
      method: RequestMethod.post,
      headers: {'Content-Type': 'multipart/form-data'},
    );
    dev.log('Config: $config');
    dev.log('Image file: ${imageFile.path}');

    try {
      final response = await _apiService.request<UploadImageResponse>(
        config: config,
        responseConverter: (data) => UploadImageResponse.fromJson(data),
      );

      return response.fold((failure) => Left(failure), (result) {
        dev.log('${result.data}');
        final data = result.data;
        if (data!.success == true && data.imageUrl != null) {
          return Right(result.data!);
        }
        return Left(NetworkFailure(message: data.message));
      });
    } catch (e) {
      dev.log('Error uploading image: $e');
      return Left(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> uploadServiceVideos() {
    // TODO: implement uploadServiceVideos
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UploadVideoResponse>> uploadServiceVideo({
    required UploadMerchantServiceVideoRequest request,
    required Function(int p1, int p2)? onSendProgress,
  }) async {
    final mimeType = lookupMimeType(request.videoFile.path) ?? 'video/mp4';
    if (!['video/mp4', 'video/mpeg', 'video/quicktime'].contains(mimeType)) {
      return Left(NetworkFailure(message: 'Invalid video format: $mimeType'));
    }

    final config = RequestConfig.forFileUpload(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantServiceImageUpload,
      files: {'video': request.videoFile, 'mime_type': mimeType},
      fields: {'merchant_id': '$request.merchantId'},
      onSendProgress: onSendProgress,
      method: RequestMethod.post,
      headers: {'Content-Type': 'multipart/form-data'},
    );
    dev.log('Config: $config');
    dev.log('video file: $request');

    try {
      final response = await _apiService.request<UploadVideoResponse>(
        config: config,
        responseConverter: (data) => UploadVideoResponse.fromJson(data),
      );

      return response.fold((failure) => Left(failure), (result) {
        dev.log('${result.data}');
        final data = result.data;
        if (data!.success == true && data.videoUrl != null) {
          return Right(result.data!);
        }
        return Left(NetworkFailure(message: data.message));
      });
    } catch (e) {
      dev.log('Error uploading image: $e');
      return Left(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UploadImageResponse>> uploadMerchantBusinessImage({required int merchantId, required File imageFile, Function(int p1, int p2)? onSendProgress}) async{
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    if (![
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
    ].contains(mimeType)) {
      return Left(NetworkFailure(message: 'Invalid image format: $mimeType'));
    }
    final config = RequestConfig.forFileUpload(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantBusinessImageUpload,
      files: {'image': imageFile, 'mime_type': mimeType},
      fields: {'merchant_id': '$merchantId'},
      onSendProgress: onSendProgress,
      method: RequestMethod.post,
      headers: {'Content-Type': 'multipart/form-data'},
    );
    dev.log('Config: $config');
    dev.log('Image file: ${imageFile.path}');

    try {
      final response = await _apiService.request<UploadImageResponse>(
        config: config,
        responseConverter: (data) => UploadImageResponse.fromJson(data),
      );

      return response.fold((failure) => Left(failure), (result) {
        dev.log('${result.data}');
        final data = result.data;
        if (data!.success == true && data.imageUrl != null) {
          return Right(result.data!);
        }
        return Left(NetworkFailure(message: data.message));
      });
    } catch (e) {
      dev.log('Error uploading image: $e');
      return Left(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }
}
