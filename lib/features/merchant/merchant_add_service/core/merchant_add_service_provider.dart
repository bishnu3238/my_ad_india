import 'dart:developer' as dev;
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/domain/data_store/data_store.dart';
import '../../../../core/services/service.dart';

enum ServiceFormStep {
  basicInfo,
  // details,
  media,
  review,
}

enum ImageUploadType { business, service }

class MerchantAddServiceProvider extends ChangeNotifier {
  final MerchantDashboardStore store;
  final MerchantDashboardService service;

  MerchantAddServiceProvider({required this.store, required this.service}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  initializeData(BuildContext context) {
    _categoryId = store.entity!.merchantData.serviceDetails.categoryId.toInt;
    dev.log(
      'CATEGORY: ${store.entity?.merchantData.serviceDetails.subCategoryId}',
    );

    _serviceTypeId = store.entity?.merchantData.serviceDetails.serviceId.toInt;
    dev.log('CATEGORY: $_categoryId, SERVICE ID: $_serviceTypeId');
    _selectedCategory =
        context.read<CategoryStore>().getById('$_categoryId').category;
    // _selectedSubCategory =
    //     context.read<SubCategoryStore>().getById('$_subcategoryId').name;
    _selectedService =
        context.read<ServiceStore>().getById('$_serviceTypeId').serviceName;
    serviceNameController.text =
        store.entity?.merchantData.merchant.companyName ?? '';
    addressController.text =
        store.entity!.merchantData.merchant.businessLocation ?? '';
  }

  /// Initialize merchant plan details and there restrictions;
  Future<void> _initializeProvider() async {
    _setLoading(true);
    try {
      // Fetch merchant plan access
      final planAccessResult = await service.fetchMerchantPlanAccess();

      planAccessResult.fold(
        (failure) {
          _errorMessage = failure.message;
          _planAccess = store.entity?.planAccess;
          if (planAccess != null) {
            _featureManager = PlanFeatureManager(_planAccess!);
          }
        },
        (planAccess) {
          _planAccess = planAccess;
          _featureManager = PlanFeatureManager(planAccess);

          // Check if subscription is valid
          if (!isSubscriptionValid) {
            _errorMessage =
                'Your subscription has expired. Please renew to add services.';
          }

          // Check if merchant can add more services
          if (!canAddMoreServices) {
            _errorMessage =
                'You have reached the maximum number of services allowed by your plan.';
          }
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  String get serviceName => store.entity!.merchantData.merchant.companyName;
  // Form controllers
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController offersController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();

  // Form state
  ServiceFormStep _currentStep = ServiceFormStep.basicInfo;
  ServiceFormStep get currentStep => _currentStep;

  int get merchantId => store.entity?.merchantData.merchant.id ?? 0;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedSubCategory;
  String? get selectedSubCategory => _selectedSubCategory;

  String? _selectedService;
  String? get selectedService => _selectedService;

  bool _showPhoneNumber = false;
  bool get showPhoneNumber => _showPhoneNumber;

  bool _enableChat = false;
  bool get enableChat => _enableChat;

  List<String> _servicePhotos = [];
  List<String> get servicePhotos => _servicePhotos;

  String profilePhoto = '';

  String? _videoPath;
  String? get videoPath => _videoPath;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  // Plan restrictions
  MerchantPlanAccessModel? _planAccess;
  MerchantPlanAccessModel? get planAccess => _planAccess;

  PlanFeatureManager? _featureManager;
  PlanFeatureManager? get featureManager => _featureManager;

  int? _categoryId;
  int? _serviceTypeId;

  int get categoryId => _categoryId ?? 1;
  int get serviceTypeId => _serviceTypeId ?? 1;

  // Getters for plan restrictions
  int get maxPhotoCount => _featureManager?.maxPhotoCount ?? 0;
  bool get isVideoAllowed => _featureManager?.isVideoAllowed ?? false;
  int get maxVideoLength => _featureManager?.maxVideoLength ?? 0;
  int get maxDescriptionLength => _featureManager?.maxDescriptionLength ?? 0;
  int get maxOfferLength => _featureManager?.maxOfferLength ?? 0;
  bool get canWriteDescription => _featureManager?.canWriteDescription ?? false;
  bool get canAddMoreServices => _featureManager?.canAddMoreServices ?? false;
  bool get canShowPhoneNumber => _featureManager?.canShowPhoneNumber ?? false;
  bool get canShowOffers => _featureManager?.canShowOffers ?? false;
  bool get isSubscriptionValid => _featureManager?.isSubscriptionValid ?? false;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Form navigation methods
  void nextStep(BuildContext context) {
    if (!validateCurrentStep(context)) {
      return;
    }

    switch (_currentStep) {
      case ServiceFormStep.basicInfo:
        _currentStep = ServiceFormStep.media;
        break;
      // case ServiceFormStep.details:
      //   _currentStep = ServiceFormStep.media;
      //   break;
      case ServiceFormStep.media:
        _currentStep = ServiceFormStep.review;
        break;
      case ServiceFormStep.review:
        // This is handled by the submit method
        break;
    }
    notifyListeners();
  }

  void previousStep() {
    switch (_currentStep) {
      case ServiceFormStep.basicInfo:
        // This is the first step, so we don't go back
        break;
      // case ServiceFormStep.details:
      //   _currentStep = ServiceFormStep.basicInfo;
      //   break;
      case ServiceFormStep.media:
        _currentStep = ServiceFormStep.basicInfo;
        break;
      case ServiceFormStep.review:
        _currentStep = ServiceFormStep.media;
        break;
    }
    notifyListeners();
  }

  bool validateCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case ServiceFormStep.basicInfo:
        // if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Please select a category',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        // if (_selectedSubCategory == null || _selectedSubCategory!.isEmpty) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Please select a subcategory',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        // if (_selectedService == null || _selectedService!.isEmpty) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Please select a service type',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        // if (serviceNameController.text.isEmpty) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Please enter a service name',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        // if (rateController.text.isEmpty) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Please enter a rate',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        // try {
        //   double.parse(rateController.text);
        // } catch (e) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Please enter a valid rate',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        return true;

      // case ServiceFormStep.details:
      //   if (descriptionController.text.isNotEmpty &&
      //       maxDescriptionLength > 0 &&
      //       descriptionController.text.length > maxDescriptionLength) {
      //     NotifyService.snackbar(
      //       context: context,
      //       message:
      //           'Description exceeds maximum length of $maxDescriptionLength characters',
      //       type: NotificationType.error,
      //     );
      //     return false;
      //   }
      //   if (offersController.text.isNotEmpty &&
      //       maxOfferLength > 0 &&
      //       offersController.text.length > maxOfferLength) {
      //     NotifyService.snackbar(
      //       context: context,
      //       message:
      //           'Offers exceed maximum length of $maxOfferLength characters',
      //       type: NotificationType.error,
      //     );
      //     return false;
      //   }
      //   return true;

      case ServiceFormStep.media:
        if (servicePhotos.length > maxPhotoCount) {
          NotifyService.snackbar(
            context: context,
            message: 'Maximum $maxPhotoCount photos allowed',
            type: NotificationType.error,
          );
          return false;
        }
        // if (videoPath != null && !isVideoAllowed) {
        //   NotifyService.snackbar(
        //     context: context,
        //     message: 'Videos are not allowed in your current plan',
        //     type: NotificationType.error,
        //   );
        //   return false;
        // }
        return true;

      case ServiceFormStep.review:
        return true;
    }
  }

  // Form data setters
  void setCategory(String category, int id) {
    _selectedCategory = category;
    _categoryId = id;
    // Reset dependent fields
    _selectedSubCategory = null;
    _selectedService = null;
    notifyListeners();
  }

  void setSubCategory(String subCategory, int id) {
    _selectedSubCategory = subCategory;
    // Reset dependent fields
    _selectedService = null;
    notifyListeners();
  }

  void setService(String service, int id) {
    _selectedService = service;
    _serviceTypeId = id;
    notifyListeners();
  }

  void setShowPhoneNumber(bool value) {
    _showPhoneNumber = value;
    notifyListeners();
  }

  void setEnableChat(bool value) {
    _enableChat = value;
    notifyListeners();
  }

  // Media handling methods
  Future<Either<Failure, bool>> pickImage(
    ImageSource source,
    BuildContext context, [
    ImageUploadType type = ImageUploadType.service,
  ]) async {
    if (servicePhotos.length >= maxPhotoCount) {
      NotifyService.snackbar(
        context: context,
        message: 'Maximum $maxPhotoCount photos allowed',
        type: NotificationType.warning,
      );
      return left(
        OperationFailure(message: 'Maximum $maxPhotoCount photos allowed'),
      );
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        if (type == ImageUploadType.service) {
          return _uploadImage(File(image.path), context);
        }
        return await _uploadBusinessImage(File(image.path), context);
      } else {
        // User canceled the picker
        return right(false);
      }
    } catch (e) {
      dev.log('Error picking image: $e');
      NotifyService.snackbar(
        context: context,
        message: 'Failed to pick image: $e',
        type: NotificationType.error,
      );
      return left(UnexpectedFailure(message: 'Failed to pick image: $e'));
    }
  }

  Future<Either<Failure, bool>> _uploadImage(
    File imageFile,
    BuildContext context,
  ) async {
    if (servicePhotos.length >= maxPhotoCount) {
      return left(
        ValidationFailure(message: 'Maximum $maxPhotoCount photos allowed'),
      );
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // Use the repository to upload the image
      final result = await service.uploadServiceImages(
        merchantId: merchantId,
        imageFile: imageFile,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      return result.fold(
        (failure) {
          if (context.mounted) {
            NotifyService.snackbar(
              context: context,
              message: failure.message,
              type: NotificationType.error,
            );
          }
          return left(failure);
        },
        (imageUrl) {
          // Add the image URL to the list of service photos
          servicePhotos.add('${imageUrl.imageUrl}');

          if (context.mounted) {
            NotifyService.snackbar(
              context: context,
              message: 'Image uploaded successfully',
              type: NotificationType.success,
            );
          }
          return right(true);
        },
      );
    } catch (e) {
      dev.log('Error uploading image: $e');
      if (context.mounted) {
        NotifyService.snackbar(
          context: context,
          message: 'Failed to upload image: $e',
          type: NotificationType.error,
        );
      }
      return left(UnexpectedFailure(message: 'Failed to upload image: $e'));
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<Either<Failure, bool>> _uploadBusinessImage(
    File imageFile,
    BuildContext context,
  ) async {
    if (profilePhoto.length > 1) {
      return left(
        ValidationFailure(message: 'Maximum $maxPhotoCount photos allowed'),
      );
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // Use the repository to upload the image
      final result = await service.uploadMerchantBusinessImage(
        merchantId: merchantId,
        imageFile: imageFile,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      return result.fold(
        (failure) {
          if (context.mounted) {
            NotifyService.snackbar(
              context: context,
              message: failure.message,
              type: NotificationType.error,
            );
          }
          return left(failure);
        },
        (imageUrl) {
          // Add the image URL to the list of service photos
          profilePhoto = imageUrl.imageUrl!;
          notifyListeners();

          if (context.mounted) {
            NotifyService.snackbar(
              context: context,
              message: 'Image uploaded successfully',
              type: NotificationType.success,
            );
          }
          return right(true);
        },
      );
    } catch (e) {
      dev.log('Error uploading image: $e');
      if (context.mounted) {
        NotifyService.snackbar(
          context: context,
          message: 'Failed to upload image: $e',
          type: NotificationType.error,
        );
      }
      return left(UnexpectedFailure(message: 'Failed to upload image: $e'));
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _servicePhotos.length) {
      _servicePhotos.removeAt(index);
      notifyListeners();
    }
  }

  void removeBusinessImage() {
    profilePhoto = '';
    notifyListeners();
  }

  Future<void> pickVideo(ImageSource source, BuildContext context) async {
    if (!isVideoAllowed) {
      NotifyService.snackbar(
        context: context,
        message: 'Video uploads are not available in your current plan',
        type: NotificationType.error,
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: Duration(
          seconds: maxVideoLength > 0 ? maxVideoLength : 30,
        ),
      );

      if (video != null) {
        // Validate video duration
        final videoFile = File(video.path);
        final videoPlayerController = VideoPlayerController.file(videoFile);
        await videoPlayerController.initialize();

        final duration = videoPlayerController.value.duration.inSeconds;
        await videoPlayerController.dispose();

        if (maxVideoLength > 0 && duration > maxVideoLength) {
          NotifyService.snackbar(
            context: context,
            message: 'Maximum video length is $maxVideoLength seconds',
            type: NotificationType.error,
          );
          return;
        }

        await _uploadVideo(videoFile, context);
      }
    } catch (e) {
      NotifyService.snackbar(
        context: context,
        message: 'Failed to pick video: $e',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _uploadVideo(File videoFile, BuildContext context) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final request = UploadMerchantServiceVideoRequest(
        merchantId: merchantId,
        videoFile: videoFile,
      );

      await service
          .uploadServiceVideo(request, (sent, total) {
            _uploadProgress = sent / total;
            notifyListeners();
          })
          .then(
            (value) => value.fold(
              (failure) {
                _errorMessage = failure.message;
                notifyListeners();
              },
              (result) {
                if (context.mounted) {
                  NotifyService.snackbar(
                    context: context,
                    message: 'Video uploaded successfully',
                    type: NotificationType.success,
                  );
                }
              },
            ),
          );
    } catch (e) {
      NotifyService.snackbar(
        context: context,
        message: 'Failed to upload video: $e',
        type: NotificationType.error,
      );
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  void removeVideo() {
    _videoPath = null;
    videoUrlController.clear();
    notifyListeners();
  }

  // Form submission
  Future<Either<Failure, String>> submitService(BuildContext context) async {
    if (!validateCurrentStep(context)) {
      return left(OperationFailure(message: 'Fields are not validate'));
    }

    if (!canAddMoreServices) {
      return left(
        OperationFailure(
          message:
              'You have reached the maximum number of services allowed by your plan',
        ),
      );
    }

    _setLoading(true);
    try {
      // Create service model from form data
      final requestService = MerchantServiceModel(
        merchantId: merchantId,
        categoryId:
            store
                .entity!
                .merchantData
                .serviceDetails
                .categoryId
                .toInt, // _categoryId ?? 0,
        subcategoryId: 0, // int.parse(
        // store.entity!.merchantData.serviceDetails.subCategoryId ?? '0',
        // ), //_subcategoryId ?? 0,
        serviceTypeId:
            store
                .entity!
                .merchantData
                .serviceDetails
                .serviceId
                .toInt, //_serviceTypeId ?? 0,
        serviceName: serviceNameController.text,
        videoUrl: _videoPath,
        quantity: 1,
        description: descriptionController.text,
        offers: offersController.text,
        offerStatus: offersController.text.isNotEmpty,
        planRate: double.tryParse(rateController.text) ?? 0.0,
        cityName:
            store
                .entity!
                .merchantData
                .merchant
                .businessLocation, // This can be populated from user's location if needed
        address: addressController.text,
        latitude:
            store.entity!.merchantData.merchant.latitude
                .toString(), // This can be populated from user's location if needed
        longitude:
            store.entity!.merchantData.merchant.longitude
                .toString(), // This can be populated from user's location if needed
        status: 0,
        updateLimits: 0,
        videoStatus: _videoPath != null && _videoPath!.isNotEmpty ? 1 : 0,
        businessPartnerApprove: 0,
        servicePhotos: _servicePhotos,
        merchantPhoto: profilePhoto,
      );

      dev.log('Service: $service');
      //
      // // Validate service against plan restrictions
      // final validationError = _featureManager?.validateService(service);
      // if (validationError != null) {
      //   return false;
      // }

      final request = SubmitServiceRequest(
        merchantId: '$merchantId',
        requestType: ServiceRequestType.add,
        service: requestService,
        serviceId: _serviceTypeId,
        // validateFirst: true,
      );
      final submitResult = await service.submitServiceRequest(request);

      return submitResult.fold(
        (failure) {
          _setLoading(false);
          dev.log('Error: ${failure.message}');
          return left(OperationFailure(message: failure.message));
        },
        (response) {
          dev.log('Submit Service Response: $response');
          _setLoading(false);
          return right('Service added successfully');
        },
      );
    } catch (e) {
      dev.log('Error submitting service: $e');
      _setLoading(false);

      return left(NetworkFailure(message: 'Error Submitting service $e'));
    } finally {
      _setLoading(false);
    }
  }

  // Reset form
  void resetForm() {
    _currentStep = ServiceFormStep.basicInfo;
    _selectedCategory = null;
    _selectedSubCategory = null;
    _selectedService = null;
    _showPhoneNumber = false;
    _enableChat = false;
    _servicePhotos = [];
    _videoPath = null;
    _categoryId = null;
    _serviceTypeId = null;

    serviceNameController.clear();
    rateController.clear();
    descriptionController.clear();
    offersController.clear();
    addressController.clear();
    videoUrlController.clear();

    notifyListeners();
  }

  // Back Navigation Alert
  void confirmExit(BuildContext parentContext) {
    showCupertinoDialog(
      context: parentContext,
      builder:
          (dialogContext) => CupertinoAlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text(
              'Going back will terminate the process and clear all data. Are you sure?',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => dialogContext.pop(),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Confirm'),
                onPressed: () {
                  resetForm();
                  dialogContext.pop();
                  parentContext.pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    rateController.dispose();
    descriptionController.dispose();
    offersController.dispose();
    addressController.dispose();
    videoUrlController.dispose();
    super.dispose();
  }

  // Factory method to create provider from context
  static MerchantAddServiceProvider of(BuildContext context) {
    return Provider.of<MerchantAddServiceProvider>(context, listen: false);
  }

  MerchantAddServiceProvider updateStore(MerchantDashboardStore store) {
    // Update any necessary state from dashboardStore
    if (store.entity != store.entity) {
      store.setEntity(store.entity);
      _initializeProvider();
    }
    return this;
  }
}
