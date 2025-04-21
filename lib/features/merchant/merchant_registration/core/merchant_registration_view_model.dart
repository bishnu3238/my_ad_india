 import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/services/failure/src/network_failure.dart';
import 'package:pack/services/local_notification/local_notification.dart';
import 'package:pack/services/snack_bar_service/notify_service.dart';

import '../../../../core/data/model/model.dart';
import '../../../../core/domain/data_store/state_store.dart';
import '../../../../core/domain/data_store/subscription_plan_store.dart';
import '../../../../core/domain/use_cases/api_call_use_cases.dart';
import '../../../../core/services/service.dart';
import '../../core/merchant_navigation.dart';
import 'registration_form_state.dart';

class MerchantRegistrationViewModel extends ChangeNotifier {
  final MerchantAuthService _authService;
  final ApiCallUseCase _apiCallUseCase;
  final StateStore _stateStore;
  final SubscriptionPlanStore _planStore;

  // Form state
  late final RegistrationFormState formState;
  String selectedGender = '';
  String selectedState = '';
  String selectedPlan = '';

  // Data
  List<StateModel> states = [];
  List<SubscriptionPlanModel> plans = [];

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? mobileAvailabilityMessage = '';
  bool _isMobileVerifying = false;
  bool get isMobileVerifying => _isMobileVerifying;
  set isMobileVerifying(bool value) {
    _isMobileVerifying = value;
    notifyListeners();
  }

  bool _isMobileVerified = false;
  bool get isMobileVerified => _isMobileVerified;
  set isMobileVerified(bool value) {
    _isMobileVerified = value;
    notifyListeners();
  }

  // Animation state
  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;
  set isAnimating(bool value) {
    _isAnimating = value;
    notifyListeners();
  }

  // Current step
  int _currentStep = 0;
  int get currentStep => _currentStep;
  set currentStep(int value) {
    _currentStep = value;
    notifyListeners();
  }

  MerchantRegistrationViewModel(
    this._authService,
    this._apiCallUseCase,
    this._stateStore,
    this._planStore,
  ) {
    formState = RegistrationFormState();

    // Initialize with default values if available
    if (_stateStore.items.isNotEmpty) {
      selectedState = _stateStore.items.first.id;
    }

    if (_planStore.items.isNotEmpty) {
      selectedPlan = _planStore.items.first.id;
    }
  }

  @override
  void dispose() {
    formState.dispose();
    super.dispose();
  }

  // Initialize registration data
  Future<void> initializeRegistration() async {
    isLoading = true;

    try {
      // Fetch states
      await _apiCallUseCase.fetchState();
      await _apiCallUseCase.fetchPlans();
    } catch (e) {
      debugPrint('Error initializing registration: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Stores
  List<StateModel> get storedStates => _stateStore.items;
  List<SubscriptionPlanModel> get storedPlans => _planStore.items;

  // Verify mobile number
  Future<bool> verifyMobile() async {
    if (formState.mobileController.text.isEmpty ||
        formState.mobileController.text.length != 10) {
      return isMobileVerified = false;
    }

    isMobileVerifying = true;
    isMobileVerified = false;
    try {
      // Implement mobile verification logic here
      return await _authService
          .verifyPhoneNo(formState.mobileController.text)
          .then(
            (value) => value.fold(
              (failure) {
                isMobileVerified = false;
                return isMobileVerified = false;
              },
              (right) {
                isMobileVerified = right;
                if (right) {
                  mobileAvailabilityMessage = '';
                } else {
                  mobileAvailabilityMessage =
                      'Mobile number already registered,';
                }
                notifyListeners();
                return isMobileVerified;
              },
            ),
          );
    } catch (e) {
      dev.log('Error verifying mobile: $e');
      isMobileVerified = false;
      mobileAvailabilityMessage = 'Mobile number already registered,';
      return isMobileVerified;
    } finally {
      isMobileVerifying = false;
      notifyListeners();
    }
  }

  // Validate current step
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateBusinessDetails();
      case 2:
        return _validateAddress();
      case 3:
        return _validateAccount();
      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    return formState.nameController.text.isNotEmpty &&
        // formState.emailController.text.isNotEmpty &&
        formState.mobileController.text.isNotEmpty &&
        selectedGender.isNotEmpty;
  }

  bool _validateBusinessDetails() {
    return formState.shopNameController.text.isNotEmpty &&
        formState.startYearController.text.isNotEmpty &&
        formState.businessLocationController.text.isNotEmpty;
  }

  bool _validateAddress() {
    return formState.addressController.text.isNotEmpty &&
        formState.pincodeController.text.isNotEmpty &&
        selectedState.isNotEmpty;
  }

  bool _validateAccount() {
    return formState.passwordController.text.isNotEmpty &&
        formState.confirmPasswordController.text.isNotEmpty &&
        formState.passwordController.text ==
            formState.confirmPasswordController.text &&
        selectedPlan.isNotEmpty;
  }

  // Submit registration
  Future<Either<NetworkFailure, MerchantRegistrationResponse>>
  submitRegistration(BuildContext context) async {
    isLoading = true;

    try {
      // Get selected plan details
      final selectedPlanModel = plans.firstWhere(
        (plan) => plan.id == selectedPlan,
        orElse: () => plans.first,
      );

      // Calculate plan dates
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: selectedPlanModel.validity));

      final startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final amount = selectedPlanModel.planRate;
      final gst = amount * 0.18;
      final merchantRegistrationRequest = PostMerchantRegistration(
        username: formState.nameController.text.trim(),
        email: formState.emailController.text.trim(),
        mobile: formState.mobileController.text.trim(),
        state: selectedState.trim(),
        pincode: formState.pincodeController.text.trim(),
        password: formState.passwordController.text.trim(),
        address: formState.addressController.text.trim(),
        gender: formState.gender.toLowerCase(),
        businessStartYear: formState.startYearController.text.trim(),
        mobileStatus: formState.mobileStatus.toLowerCase(),
        receiveOptions: formState.notificationStatus.toLowerCase().trim(),
        businessLocation: formState.businessLocationController.text.trim(),
        companyName: formState.shopNameController.text.trim(),
        gstin: formState.gstinController.text.trim(),
        pan: formState.panCardController.text.trim(),
        city: null,
        companyLogo: null,
        kyc: 0,
        latitude: null,
        longitude: null,
        planId: selectedPlanModel.id,
        planName: selectedPlanModel.planName.trim(),
        gst: gst.toStringAsFixed(2),
        amount: amount.toStringAsFixed(2),
        startDate: startDateStr,
        endDate: endDateStr,
        validity: selectedPlanModel.validity,
      );

      // Call API
      return await _apiCallUseCase.merchantRegistration(
        merchantRegistrationRequest,
      );
    } catch (e) {
      dev.log('Error during registration: $e');
      return left(NetworkFailure(message: '$e'));
    } finally {
      isLoading = false;
    }
  }

  // Show OTP notification
  void _showOtpNotification(String otp) {
    final notificationService = LocalNotificationService();
    notificationService.showOTPNotification(
      title: 'MyAd Verification',
      subtitle: 'Your OTP for merchant registration',
      otp: otp,
      expiryMinutes: 10,
    );
  }

  Future<void> merchantRegistration(BuildContext context) async {
    if (!validateCurrentStep()) {
      NotifyService.snackbar(
        context: context,
        message: 'Please fill all required fields correctly',
        type: NotificationType.error,
      );
      return;
    }

    isLoading = true;
    final route = GoRouter.of(context);

    try {
      final response = await submitRegistration(context);

      response.fold(
        (failure) {
          NotifyService.snackbar(
            context: context,
            message: 'Registration failed. Please try again.',
            type: NotificationType.error,
          );
        },
        (data) {
          data.fold(
            onError: (message) {
              NotifyService.snackbar(
                context: context,
                message: message,
                type: NotificationType.error,
              );
            },

            onOtpRequired: (data, otp, merchant) {
              _showOtpNotification(otp ?? '111111');

              if (context.mounted) {
                route.go('${MerchantRoute.merchantOtp}/${merchant!.id}');
              }
            },
          );
        },
      );
    } catch (e) {
      dev.log('Error => $e');
      if (context.mounted) {
        NotifyService.snackbar(
          context: context,
          message: 'An error occurred: ${e.toString()}',
          type: NotificationType.error,
        );
      }
    } finally {
      isLoading = false;
    }
  }

  MerchantRegistrationViewModel updateStore(
    StateStore store,
    SubscriptionPlanStore plans,
  ) {
    // Update any necessary state from dashboardStore

    states = store.items;
    this.plans = plans.items;
    return this;
  }
}
