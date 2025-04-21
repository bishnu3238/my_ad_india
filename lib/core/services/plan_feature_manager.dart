import 'package:my_ad/core/data/model/model.dart';

/// Manages feature restrictions based on merchant subscription plan
class PlanFeatureManager {
  final MerchantPlanAccessModel planAccess;
  
  PlanFeatureManager(this.planAccess);
  
  // Text content restrictions
  int get maxDescriptionLength => _getTextLimit([12, 17, 20, 23, 26, 27]);
  int get maxOfferLength => _getTextLimit([17, 20, 23]);
  
  // Media restrictions
  bool get canAddPhotos => _hasFeature([4, 5, 6, 16]);
  int get maxPhotoCount => _getMediaLimit([4, 5, 6, 16]);
  int get maxVideoLength => _getVideoLength([2, 21]); // in seconds
  bool get isVideoAllowed => _hasFeature([2, 21]);
  
  // Service limits
  int get maxServices => planAccess.numberOfServices;
  int get remainingServices => planAccess.remainingServices;
  int get remainingUpdates => planAccess.remainingUpdates;
  bool get isSubscriptionValid => planAccess.isSubscriptionValid();
  bool get canAddMoreServices => planAccess.canAddMoreServices();
  
  // Feature access checks
  bool get canShowPhoneNumber => _hasFeature([8]);
  bool get canShowEmail => _hasFeature([14]);
  bool get canShowLocation => _hasFeature([9]);
  bool get canShowReviews => _hasFeature([19]);
  bool get canShowOffers => _hasFeature([17, 20, 23]);

  get canWriteDescription => maxDescriptionLength > 0;
  
  // Helper methods
  int _getTextLimit(List<int> featureIds) {
    final feature = _findFeature(featureIds);
    return int.tryParse(feature?.length ?? '0') ?? 0;
  }
  
  int _getMediaLimit(List<int> featureIds) {
    final feature = _findFeature(featureIds);
    return int.tryParse(feature?.length ?? '0') ?? 0;
  }
  
  int _getVideoLength(List<int> featureIds) {
    final feature = _findFeature(featureIds);
    return int.tryParse(feature?.length ?? '0') ?? 0;
  }
  
  bool _hasFeature(List<int> featureIds) {
    return _findFeature(featureIds) != null;
  }
  
  PlanActivityModel? _findFeature(List<int> featureIds) {
    if (planAccess.accessibleFeatures.isEmpty) return null;
    
    try {
      return planAccess.accessibleFeatures.firstWhere(
        (a) => featureIds.contains(a.id),
      );
    } catch (_) {
      return null;
    }
  }
  
  /// Validates a service against plan restrictions
  /// Returns error message if validation fails, null otherwise
  String? validateService(MerchantServiceModel service) {
    // Check if subscription is valid
    if (!isSubscriptionValid) {
      return 'Your subscription has expired. Please renew to continue.';
    }
    
    // Check if merchant can add more services
    if (!canAddMoreServices) {
      return 'You have reached the maximum number of services allowed by your plan.';
    }
    
    // Check description length
    if (maxDescriptionLength > 0 && service.description.length > maxDescriptionLength) {
      return 'Description exceeds allowed length of $maxDescriptionLength characters';
    }
    
    // Check photo count
    if (maxPhotoCount == 0 && service.servicePhotos.isNotEmpty) {
      return 'Photos not allowed in your current plan';
    } else if (service.servicePhotos.length > maxPhotoCount) {
      return 'Photo limit exceeded (max: $maxPhotoCount)';
    }
    
    // Check video
    if (!isVideoAllowed && service.videoUrl != null && service.videoUrl!.isNotEmpty) {
      return 'Videos not allowed in your current plan';
    }
    
    // Add more validations as needed
    
    return null; // No validation errors
  }
}
