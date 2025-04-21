import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/services/service.dart';


abstract class MerchantDashboardRepository implements IRepository {
  /// Fetch merchant dashboard data
  Future<Either<Failure, List<MerchantServiceModel>>> fetchMerchantServices(
    PostFetchMerchantServices request,
  );

  /// Fetch merchant dashboard data by service ID
  Future<Either<Failure, MerchantServiceModel>>
  fetchMerchantServicesByServiceId(String serviceId);

  /// Fetch merchant dashboard data by service ID
  Future<Either<Failure, MerchantPlanAccessModel>> fetchMerchantPlanAccess({
    required FetchMerchantPlanAccessRequest request,
    bool forceRefresh = false, // Option to bypass cache
  });

  /// Validate service operation with advanced checks using PlanFeatureManager
  /// [OperationType] ('add', 'update', 'delete')
  Future<Either<Failure, ServiceValidationResponse>> validateServiceOperation(
    ValidateServiceOperationRequest request,
  );

  Future<Either<Failure, SubmitServiceResponse>> submitServiceRequest(
    SubmitServiceRequest request,
  );

  Future<Either<Failure, UploadImageResponse>> uploadServiceImages({
    required int merchantId,
    required File imageFile,
    required dynamic Function(int, int)? onSendProgress,
  });
  Future<Either<Failure, UploadVideoResponse>> uploadServiceVideo({
    required UploadMerchantServiceVideoRequest request,
    required dynamic Function(int, int)? onSendProgress,
  });
  Future<Either<Failure, bool>> uploadServiceVideos();
}
