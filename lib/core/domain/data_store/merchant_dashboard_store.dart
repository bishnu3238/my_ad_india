import 'package:pack/services/base_services/base_service.dart';
import 'package:pack/services/service.dart';
import '../../data/model/merchant/merchant.dart';

class MerchantDashboardStore extends EntityStore<MerchantDashboardModel>
    with LocalStorageMixin<MerchantDashboardModel> {
  MerchantDashboardStore() : super(initialEntity: MerchantDashboardModel.empty);

  bool get isLoggedIn => entity!.isAuthenticated && !entity!.merchantData.isEmpty;

  bool get isTokenExpired {
    final expiry = entity?.tokenExpiry;
    return expiry == null || DateTime.now().isAfter(expiry);
  }





  // // Fetch all merchants (mocked or API-based)
  // @override
  // Future<StoreResult<List<MerchantServiceModel>>> fetchData({
  //   int? page,
  //   bool append = false,
  // }) async {
  //   setLoadingState(LoadingEver.loading);
  //
  //   return await _planService
  //       .fetchMerchantServices(
  //         GetMerchantProducts(
  //           merchantId: merchant!.id.toString(),
  //         ).toJson(),
  //       )
  //       .then(
  //         (value) => value.fold(
  //           (failure) {
  //             setLoadingState(LoadingEver.error);
  //             return StoreResult.error(failure);
  //           },
  //           (result) {
  //             if (result.services.isEmpty) {
  //               setLoadingState(LoadingEver.error);
  //               return StoreResult.error(
  //                 NetworkFailure(
  //                   message: 'No Services found for the merchant.',
  //                 ),
  //               );
  //             }
  //             return safeOperation(() async {
  //               setItems(result.services, append: append);
  //               setLoadingState(LoadingEver.success);
  //               return StoreResult.success(result.services);
  //             }, operationName: 'fetchMerchants');
  //           },
  //         ),
  //       );
  // }
  //
  // Future<Either<NetworkFailure, MerchantServiceResponse>>
  // fetchMerchantServices({required String merchantId}) async {
  //   return await _planService
  //       .fetchMerchantServices(
  //         GetMerchantProducts(merchantId: merchantId).toJson(),
  //       )
  //       .then(
  //         (value) => value.fold((failure) => left(failure), (result) {
  //           if (result.services.isEmpty) {
  //             return left(
  //               NetworkFailure(message: 'No services found for the merchant.'),
  //             );
  //           }
  //           return right(result);
  //         }),
  //       );
  // }
  //
  // // Fetch merchant plan access
  // Future<StoreResult<MerchantPlanAccessModel>> fetchMerchantPlanAccess(
  //   int merchantId,
  // ) async {
  //   if (_merchantPlanCache.containsKey(merchantId)) {
  //     return StoreResult.success(_merchantPlanCache[merchantId]);
  //   }
  //
  //   return safeOperation(() async {
  //     final result = await _planService.getMerchantPlanAccess(
  //       merchantId: '$merchantId',
  //     );
  //     return result.fold((failure) => StoreResult.error(failure), (planAccess) {
  //       _merchantPlanCache[merchantId] = planAccess;
  //       return StoreResult.success(planAccess);
  //     });
  //   }, operationName: 'fetchMerchantPlanAccess');
  // }
  //
  // // Add a new merchant service with plan restriction checks
  // Future<StoreResult<MerchantServiceModel>> addMerchantService(
  //   int merchantId,
  //   MerchantServiceModel service,
  // ) async {
  //   return safeOperation(() async {
  //     setLoadingState(LoadingEver.processing);
  //
  //     // Fetch plan access
  //     final planResult = await fetchMerchantPlanAccess(merchantId);
  //     if (planResult.isError) return StoreResult.error(planResult.error!);
  //
  //     final planAccess = planResult.data!;
  //     if (!planAccess.canAddMoreServices()) {
  //       return StoreResult.error(
  //         NetworkFailure(message: 'Service limit exceeded for this plan'),
  //       );
  //     }
  //
  //     // Validate service based on plan activities
  //     final validationError = _validateServiceAgainstPlan(service, planAccess);
  //     if (validationError != null) {
  //       return StoreResult.error(NetworkFailure(message: validationError));
  //     }
  //
  //     // Submit service request
  //     final submitResult = await _planService.submitServiceRequest(
  //       merchantId: '$merchantId',
  //       requestType: 'add',
  //       service: service,
  //     );
  //
  //     return submitResult.fold((failure) => StoreResult.error(failure), (
  //       response,
  //     ) {
  //       final serviceId = response.requestId as int;
  //       final newService = service.copyWith(id: serviceId);
  //       setLoadingState(LoadingEver.success);
  //       _updatePlanCacheAfterAdd(merchantId); // Update remaining services
  //       return StoreResult.success(
  //         newService,
  //         message: 'Service added successfully',
  //       );
  //     });
  //   }, operationName: 'addMerchantService');
  // }
  //
  // // Update an existing merchant service with plan restriction checks
  // Future<StoreResult<MerchantServiceModel>> updateMerchantService(
  //   int merchantId,
  //   MerchantServiceModel service,
  // ) async {
  //   if (service.id == null) {
  //     return StoreResult.error(
  //       NetworkFailure(message: 'Service ID is required for update'),
  //     );
  //   }
  //
  //   return safeOperation(() async {
  //     setLoadingState(LoadingEver.processing);
  //
  //     // Fetch plan access
  //     final planResult = await fetchMerchantPlanAccess(merchantId);
  //     if (planResult.isError) return StoreResult.error(planResult.error!);
  //
  //     final planAccess = planResult.data!;
  //     if (!planAccess.canUpdateService()) {
  //       return StoreResult.error(
  //         NetworkFailure(message: 'Update limit exceeded for this plan'),
  //       );
  //     }
  //
  //     // Validate service based on plan activities
  //     final validationError = _validateServiceAgainstPlan(service, planAccess);
  //     if (validationError != null) {
  //       return StoreResult.error(NetworkFailure(message: validationError));
  //     }
  //
  //     // Submit update request
  //     final submitResult = await _planService.submitServiceRequest(
  //       merchantId: '$merchantId',
  //       requestType: 'update',
  //       service: service,
  //       serviceId: service.id,
  //     );
  //
  //     return submitResult.fold((failure) => StoreResult.error(failure), (_) {
  //       setLoadingState(LoadingEver.success);
  //       _updatePlanCacheAfterUpdate(merchantId); // Update remaining updates
  //       return StoreResult.success(
  //         service,
  //         message: 'Service updated successfully',
  //       );
  //     });
  //   }, operationName: 'updateMerchantService');
  // }
  //
  // // Delete a merchant service
  // Future<StoreResult<void>> deleteMerchantService(
  //   int merchantId,
  //   int serviceId,
  // ) async {
  //   return safeOperation(() async {
  //     setLoadingState(LoadingEver.processing);
  //
  //     final result = await _planService.submitServiceRequest(
  //       merchantId: '$merchantId',
  //       requestType: 'delete',
  //       service: const MerchantServiceModel.empty(),
  //       serviceId: serviceId,
  //     );
  //
  //     return result.fold((failure) => StoreResult.error(failure), (_) {
  //       setLoadingState(LoadingEver.success);
  //       _updatePlanCacheAfterDelete(merchantId); // Update remaining services
  //       return StoreResult.success(
  //         null,
  //         message: 'Service deleted successfully',
  //       );
  //     });
  //   }, operationName: 'deleteMerchantService');
  // }
  //
  // // Validate service against plan restrictions
  // String? _validateServiceAgainstPlan(
  //   MerchantServiceModel service,
  //   MerchantPlanAccessModel planAccess,
  // ) {
  //   // Check description length
  //   final descActivity = planAccess.accessibleFeatures.firstWhere(
  //     (a) =>
  //         a.id == 12 ||
  //         a.id == 17 ||
  //         a.id == 20 ||
  //         a.id == 23 ||
  //         a.id == 26 ||
  //         a.id == 27,
  //     orElse:
  //         () => const PlanActivityModel(
  //           id: 0,
  //           activities: '',
  //           accessType: '',
  //           length: '0',
  //           activityType: '',
  //           demo: '',
  //         ),
  //   );
  //   final descLimit = int.tryParse(descActivity.length) ?? 0;
  //   if (descLimit > 0 && service.description.length > descLimit) {
  //     return 'Description exceeds allowed length of $descLimit characters';
  //   }
  //
  //   // Check photo count
  //   final photoActivity = planAccess.accessibleFeatures.firstWhere(
  //     (a) => a.id == 4 || a.id == 5 || a.id == 6 || a.id == 16,
  //     orElse:
  //         () => const PlanActivityModel(
  //           id: 0,
  //           activities: '',
  //           accessType: '',
  //           length: '0',
  //           activityType: '',
  //           demo: '',
  //         ),
  //   );
  //   final photoLimit = int.tryParse(photoActivity.length) ?? 0;
  //   if (photoLimit == 0 && service.servicePhotos.isNotEmpty) {
  //     return 'Photos not allowed in this plan';
  //   } else if (photoLimit > 0 && service.servicePhotos.length > photoLimit) {
  //     return 'Photo limit exceeded ($photoLimit)';
  //   }
  //
  //   // Check video
  //   final videoActivity = planAccess.accessibleFeatures.firstWhere(
  //     (a) => a.id == 2 || a.id == 21,
  //     orElse:
  //         () => const PlanActivityModel(
  //           id: 0,
  //           activities: '',
  //           accessType: '',
  //           length: '0',
  //           activityType: '',
  //           demo: '',
  //         ),
  //   );
  //   if (videoActivity.id == 0 &&
  //       service.videoUrl != null &&
  //       service.videoUrl!.isNotEmpty) {
  //     return 'Videos not allowed in this plan';
  //   }
  //
  //   return null;
  // }
  //
  // // Update plan cache after operations
  // void _updatePlanCacheAfterAdd(int merchantId) {
  //   if (_merchantPlanCache.containsKey(merchantId)) {
  //     final updated = _merchantPlanCache[merchantId]!.copyWith(
  //       remainingServices:
  //           _merchantPlanCache[merchantId]!.remainingServices - 1,
  //     );
  //     _merchantPlanCache[merchantId] = updated;
  //   }
  // }
  //
  // void _updatePlanCacheAfterUpdate(int merchantId) {
  //   if (_merchantPlanCache.containsKey(merchantId)) {
  //     final updated = _merchantPlanCache[merchantId]!.copyWith(
  //       remainingUpdates: _merchantPlanCache[merchantId]!.remainingUpdates - 1,
  //     );
  //     _merchantPlanCache[merchantId] = updated;
  //   }
  // }
  //
  // void _updatePlanCacheAfterDelete(int merchantId) {
  //   if (_merchantPlanCache.containsKey(merchantId)) {
  //     final updated = _merchantPlanCache[merchantId]!.copyWith(
  //       remainingServices:
  //           _merchantPlanCache[merchantId]!.remainingServices + 1,
  //     );
  //     _merchantPlanCache[merchantId] = updated;
  //   }
  // }
}
