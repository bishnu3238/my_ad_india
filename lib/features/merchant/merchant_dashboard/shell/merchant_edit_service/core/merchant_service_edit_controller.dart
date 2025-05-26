import 'dart:io';
import 'package:dartz/dartz.dart';
 import 'package:pack/services/failure/failure.dart';
 import 'package:pack/services/service.dart';

import '../../../../../../core/data/model/merchant/service_request_model.dart';
import '../../../../../../core/data/model/payload/POST/submit_service_request.dart';
import '../../../../../../core/services/merchant_dashboard_service.dart';
import 'merchant_service_edit_state.dart';

class MerchantServiceEditController {
  final MerchantServiceEditState state;
  final MerchantDashboardService dashboardService;

  MerchantServiceEditController({
    required this.state,
    required this.dashboardService,
  });

  Future<Either<Failure, bool>> validateServiceOperation(
      String merchantId, String operationType) async {
    final serviceData = state.service.toJson();
    final request = SubmitServiceRequest(
      merchantId: merchantId,
      requestType: operationType == 'add'
          ? ServiceRequestType.add
          : ServiceRequestType.update,
      service: state.service,
      serviceId: state.service.id!.toInt(),
    );

    // Validate service operation with API
    final response = await dashboardService.submitServiceRequest(request);
    return response;
  }

  Future<Either<Failure, String>> uploadServiceImage(
      String merchantId, File imageFile) async {
    final response = await dashboardService.uploadServiceImages(
      merchantId: int.parse(merchantId),
      imageFile: imageFile,
      onSendProgress: (sent, total) {
        // Handle upload progress if needed
      },
    );

    return response.fold(
          (failure) => Left(failure),
          (uploadResponse) => Right(uploadResponse.imageUrl!),
    );
  }

  Future<Either<Failure, bool>> submitService(
      String merchantId, String operationType) async {
    state.setLoading(true);
    final response = await validateServiceOperation(merchantId, operationType);
    return response.fold(
          (failure) {
        state.setError(failure.message);
        return Left(failure);
      },
          (success) async {
        final submitRequest = SubmitServiceRequest(
          merchantId: merchantId,
          requestType: operationType == 'add'
              ? ServiceRequestType.add
              : ServiceRequestType.update,
          service: state.service,
          serviceId: state.service.id!.toInt(),
        );

        final submitResponse =
        await dashboardService.submitServiceRequest(submitRequest);
        return submitResponse.fold(
              (failure) {
            state.setError(failure.message);
            return Left(failure);
          },
              (success) {
            state.clearError();
            state.setLoading(false);
            return Right(true);
          },
        );
      },
    );
  }
}