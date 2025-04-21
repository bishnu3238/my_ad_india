// import 'dart:developer' as dev;
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pack/services/service.dart';
// import '../../../../../../core/data/api/api_config.dart';
// import '../../../../../../core/data/model/model.dart';
// import '../../../../../../core/domain/data_store/data_store.dart';
// import '../../../../../../core/services/service.dart';
// import '../../../../core/merchant_auth_provider.dart';
// import 'package:dio/dio.dart';
//
// class MerchantAddServiceProvider extends BaseProviderModel {
//   MerchantDashboardStore merchantStore;
//   final MerchantDashboardService merchantDashboardService;
//   final Dio _dio; // For file uploads
//
//   MerchantAddServiceProvider({
//     required this.merchantStore,
//     required this.merchantDashboardService,
//     Dio? dio,
//   }) : _dio = dio ?? Dio() {
//     initial();
//   }
//
//   MerchantModel get merchant => merchantStore.entity!.merchantData.merchant;
//
//   late MerchantSubscriptionModel _subscriptionModel;
//   MerchantSubscriptionModel get subscriptionModel => _subscriptionModel;
//   set subscriptionModel(MerchantSubscriptionModel value) {
//     _subscriptionModel = value;
//     notifyListeners();
//   }
//
//   // Form key
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState>? get formKey => _formKey;
//
//   // Form Controllers
//   final TextEditingController _serviceNameController = TextEditingController();
//   final TextEditingController _rateController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _videoUrlController = TextEditingController();
//   final TextEditingController _offersController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//
//   TextEditingController get serviceNameController => _serviceNameController;
//   TextEditingController get rateController => _rateController;
//   TextEditingController get descriptionController => _descriptionController;
//   TextEditingController get videoUrlController => _videoUrlController;
//   TextEditingController get offersController => _offersController;
//   TextEditingController get addressController => _addressController;
//
//   // Form State
//   String _selectedCategory = '';
//   String _selectedSubCategory = '';
//   String _selectedService = '';
//   bool _showPhoneNumber = false;
//   bool _enableChat = false;
//   int _currentStep = 0;
//   List<File> _servicePhotos = []; // Changed to File for local images
//   String? _videoPath; // Local video file path
//   bool _isUploading = false;
//
//   String get selectedCategory => _selectedCategory;
//   String get selectedSubCategory => _selectedSubCategory;
//   String get selectedService => _selectedService;
//   bool get showPhoneNumber => _showPhoneNumber;
//   bool get enableChat => _enableChat;
//   int get currentStep => _currentStep;
//   List<File> get servicePhotos => _servicePhotos;
//   String? get videoPath => _videoPath;
//   bool get isUploading => _isUploading;
//
//   set selectedCategory(String value) {
//     _selectedCategory = value;
//     _selectedSubCategory = '';
//     _selectedService = '';
//     notifyListeners();
//   }
//
//   set selectedSubCategory(String value) {
//     _selectedSubCategory = value;
//     _selectedService = '';
//     notifyListeners();
//   }
//
//   set selectedService(String value) {
//     _selectedService = value;
//     notifyListeners();
//   }
//
//   set showPhoneNumber(bool value) {
//     _showPhoneNumber = value;
//     notifyListeners();
//   }
//
//   set enableChat(bool value) {
//     _enableChat = value;
//     notifyListeners();
//   }
//
//   set currentStep(int value) {
//     _currentStep = value;
//     notifyListeners();
//   }
//
//   set isUploading(bool value) {
//     _isUploading = value;
//     notifyListeners();
//   }
//
//   // Plan Restrictions
//   MerchantPlanAccessModel? _planAccess;
//   PlanFeatureManager? _featureManager;
//
//   MerchantPlanAccessModel? get planAccess => _planAccess;
//   PlanFeatureManager? get featureManager => _featureManager;
//
//   int get maxDescriptionLength => _featureManager?.maxDescriptionLength ?? 0;
//   int get maxPhotoCount => _featureManager?.maxPhotoCount ?? 0;
//   bool get isVideoAllowed => _featureManager?.isVideoAllowed ?? false;
//   int get maxVideoLength => _featureManager?.maxVideoLength ?? 0;
//   int get maxOfferLength => _featureManager?.maxOfferLength ?? 0;
//   bool get canAddMoreServices => _featureManager?.canAddMoreServices ?? false;
//   bool get canShowPhoneNumber => _featureManager?.canShowPhoneNumber ?? false;
//   bool get canShowOffers => _featureManager?.canShowOffers ?? false;
//
//   // Initialize Plan Access
//   Future<void> initial() async {
//     dev.log('Fetching plan access... ${merchantStore.entity!.planAccess}');
//     _planAccess = merchantStore.entity!.planAccess;
//     _featureManager = PlanFeatureManager(_planAccess!);
//     notifyListeners();
//   }
//
//   // Form Methods
//   void setDescription(String value) {
//     if (maxDescriptionLength == 0 || value.length <= maxDescriptionLength) {
//       _descriptionController.text = value;
//       notifyListeners();
//     }
//   }
//
//   Future<void> pickImage(BuildContext context) async {
//     if (_isUploading || _servicePhotos.length >= maxPhotoCount) {
//       NotifyService.snackbar(
//         message:
//             _isUploading
//                 ? 'Upload in progress'
//                 : 'Max photos reached ($maxPhotoCount)',
//         context: context,
//         type: NotificationType.error,
//       );
//       return;
//     }
//
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       _servicePhotos.add(file);
//       notifyListeners();
//       await _uploadImage(context, file);
//     }
//   }
//
//   Future<void> _uploadImage(BuildContext context, File image) async {
//     try {
//       isUploading = true;
//       final formData = FormData.fromMap({
//         'image': await MultipartFile.fromFile(
//           image.path,
//           filename: 'service_${DateTime.now().millisecondsSinceEpoch}.jpg',
//         ),
//         'merchant_id': merchant.id,
//       });
//
//       final response = await _dio.post(
//         '${ApiConfig.baseUrl}/upload_image.php', // New endpoint
//         data: formData,
//         onSendProgress: (sent, total) {
//           NotifyService.snackbar(
//             message:
//                 'Uploading image: ${(sent / total * 100).toStringAsFixed(0)}%',
//             context: context,
//           );
//         },
//       );
//
//       if (response.data['success']) {
//         _servicePhotos[_servicePhotos.indexOf(image)] = File(
//           response.data['image_url'],
//         );
//         NotifyService.snackbar(
//           message: 'Image uploaded successfully',
//           context: context,
//           type: NotificationType.success,
//         );
//       } else {
//         _servicePhotos.remove(image);
//         NotifyService.snackbar(
//           message: response.data['message'] ?? 'Image upload failed',
//           context: context,
//           type: NotificationType.error,
//         );
//       }
//     } catch (e) {
//       _servicePhotos.remove(image);
//       NotifyService.snackbar(
//         message: 'Error uploading image: $e',
//         context: context,
//         type: NotificationType.error,
//       );
//     } finally {
//       isUploading = false;
//     }
//   }
//
//   void removePhoto(int index) {
//     if (index >= 0 && index < _servicePhotos.length) {
//       _servicePhotos.removeAt(index);
//       notifyListeners();
//     }
//   }
//
//   Future<void> pickVideo(BuildContext context) async {
//     if (_isUploading || !isVideoAllowed) {
//       NotifyService.snackbar(
//         message:
//             _isUploading
//                 ? 'Upload in progress'
//                 : 'Video not allowed in your plan',
//         context: context,
//         type: NotificationType.error,
//       );
//       return;
//     }
//
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       // Check video duration
//       final duration = await _getVideoDuration(file);
//       if (duration > maxVideoLength) {
//         NotifyService.snackbar(
//           message: 'Video exceeds max duration ($maxVideoLength seconds)',
//           context: context,
//           type: NotificationType.error,
//         );
//         return;
//       }
//       _videoPath = file.path;
//       notifyListeners();
//       await _uploadVideo(context, file);
//     }
//   }
//
//   Future<int> _getVideoDuration(File video) async {
//     // Simplified; use video_player to get duration
//     return 30; // Mock duration; implement actual logic
//   }
//
//   Future<void> _uploadVideo(BuildContext context, File video) async {
//     try {
//       isUploading = true;
//       final formData = FormData.fromMap({
//         'video': await MultipartFile.fromFile(
//           video.path,
//           filename:
//               'service_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
//         ),
//         'merchant_id': merchant.id,
//       });
//
//       final response = await _dio.post(
//         '${ApiConfig.baseUrl}/upload_video.php', // New endpoint
//         data: formData,
//         onSendProgress: (sent, total) {
//           NotifyService.snackbar(
//             message:
//                 'Uploading video: ${(sent / total * 100).toStringAsFixed(0)}%',
//             context: context,
//           );
//         },
//       );
//
//       if (response.data['success']) {
//         _videoUrlController.text = response.data['video_url'];
//         _videoPath = response.data['video_url'];
//         NotifyService.snackbar(
//           message: 'Video uploaded successfully',
//           context: context,
//           type: NotificationType.success,
//         );
//       } else {
//         _videoPath = null;
//         NotifyService.snackbar(
//           message: response.data['message'] ?? 'Video upload failed',
//           context: context,
//           type: NotificationType.error,
//         );
//       }
//     } catch (e) {
//       _videoPath = null;
//       NotifyService.snackbar(
//         message: 'Error uploading video: $e',
//         context: context,
//         type: NotificationType.error,
//       );
//     } finally {
//       isUploading = false;
//     }
//   }
//
//   bool validateCurrentStep() {
//     switch (_currentStep) {
//       case 0: // Basic Info
//         return _selectedCategory.isNotEmpty &&
//             _selectedSubCategory.isNotEmpty &&
//             _selectedService.isNotEmpty &&
//             _serviceNameController.text.isNotEmpty &&
//             _rateController.text.isNotEmpty &&
//             double.tryParse(_rateController.text) != null;
//       case 1: // Details
//         if (maxDescriptionLength > 0 &&
//             _descriptionController.text.length > maxDescriptionLength) {
//           return false;
//         }
//         if (canShowOffers && _offersController.text.length > maxOfferLength) {
//           return false;
//         }
//         return true;
//       case 2: // Media
//         if (isVideoAllowed &&
//             _videoUrlController.text.isNotEmpty &&
//             !Uri.parse(_videoUrlController.text).isAbsolute) {
//           return false;
//         }
//         return true;
//       case 3: // Review
//         return true;
//       default:
//         return false;
//     }
//   }
//
//   void nextStep() {
//     if (_currentStep < 3 && validateCurrentStep()) {
//       _currentStep++;
//       notifyListeners();
//     }
//   }
//
//   void previousStep() {
//     if (_currentStep > 0) {
//       _currentStep--;
//       notifyListeners();
//     }
//   }
//
//   Future<void> submitService(BuildContext context) async {
//     if (!canAddMoreServices) {
//       NotifyService.snackbar(
//         message: 'Service limit exceeded for this plan',
//         context: context,
//       );
//       return;
//     }
//
//     final service = MerchantServiceModel(
//       id: null,
//       merchantId: merchant.id!,
//       categoryId: int.parse(_selectedCategory),
//       subcategoryId: int.parse(_selectedSubCategory),
//       serviceTypeId: int.parse(_selectedService),
//       serviceName: _serviceNameController.text,
//       quantity: 1,
//       description: _descriptionController.text,
//       offers: _offersController.text,
//       offerStatus: _offersController.text.isNotEmpty ? true : false,
//       planRate: double.parse(_rateController.text),
//       cityName: merchant.businessLocation,
//       address: _addressController.text,
//       latitude: '',
//       longitude: '',
//       status: 1,
//       updateLimits: 0,
//       videoStatus: _videoUrlController.text.isNotEmpty ? 1 : 0,
//       businessPartnerApprove: 0,
//       servicePhotos: _servicePhotos.map((file) => file.path).toList(),
//       videoUrl: _videoUrlController.text,
//     );
//
//     final validationError = _featureManager?.validateService(service);
//     if (validationError != null) {
//       NotifyService.snackbar(
//         context: context,
//         message: validationError,
//         type: NotificationType.error,
//       );
//       return;
//     }
//
//     final request = SubmitServiceRequest(
//       merchantId: '${merchant.id}',
//       requestType: 'add',
//       service: service,
//     );
//
//     await merchantDashboardService.submitServiceRequest(request);
//     resetForm();
//   }
//
//   void resetForm() {
//     _currentStep = 0;
//     _selectedCategory = '';
//     _selectedSubCategory = '';
//     _selectedService = '';
//     _showPhoneNumber = false;
//     _enableChat = false;
//     _servicePhotos.clear();
//     _videoPath = null;
//     _serviceNameController.clear();
//     _rateController.clear();
//     _descriptionController.clear();
//     _videoUrlController.clear();
//     _offersController.clear();
//     _addressController.clear();
//     notifyListeners();
//   }
//
//   MerchantAddServiceProvider updateStore(MerchantDashboardStore store) {
//     // Update any necessary state from dashboardStore
//     if (store.entity != merchantStore.entity) {
//       merchantStore.setEntity(store.entity);
//       initial();
//     }
//     return this;
//   }
//
//   @override
//   void dispose() {
//     _serviceNameController.dispose();
//     _rateController.dispose();
//     _descriptionController.dispose();
//     _videoUrlController.dispose();
//     _offersController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
// }
//
// //  MerchantAddServiceProvider updateStore(MerchantDashboardStore store) {
// //     // Update any necessary state from dashboardStore
// //     if (store.entity != merchantStore.entity) {
// //       merchantStore.setEntity(store.entity);
// //       initial();
// //     }
// //     return this;
// //   }
