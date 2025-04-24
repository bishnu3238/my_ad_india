import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/provider_state/location_provider.dart';
import 'package:pack/extensions/contextx.dart';
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
      formState.selectedState = _stateStore.items.first.id;
    }

    if (_planStore.items.isNotEmpty) {
      formState.selectedPlan = _planStore.items.first.id;
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
      await getUserLocation();
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

  // get user location
  Future<void> getUserLocation() async {
    await DependencyInjector.get<LocationProvider>().detectUserLocation().then((
      value,
    ) {
      dev.log("LOCATION => $value");
      if (value.isEmpty) return;

      formState.lat = value.latitude;
      formState.long = value.longitude;
      formState.selectedCity = value.city;
      notifyListeners();
    });
  }

  // Verify mobile number
  Future<bool> verifyMobile() async {
    if (formState.mobileController.text.isEmpty ||
        formState.mobileController.text.length != 10) {
      return formState.isMobileVerified = false;
    }

    formState.isVerifyingMobile = true;
    formState.isMobileVerified = false;
    notifyListeners();
    try {
      // Implement mobile verification logic here
      return await _authService
          .verifyPhoneNo(formState.mobileController.text)
          .then(
            (value) => value.fold(
              (failure) {
                return formState.isMobileVerified = false;
              },
              (right) {
                formState.isMobileVerified = right;
                if (right) {
                  formState.mobileAvailabilityMessage = '';
                } else {
                  formState.mobileAvailabilityMessage =
                      'Mobile number already registered,';
                }
                notifyListeners();
                return formState.isMobileVerified;
              },
            ),
          );
    } catch (e) {
      dev.log('Error verifying mobile: $e');
      formState.isMobileVerified = false;
      formState.mobileAvailabilityMessage = 'Mobile number already registered,';
      return formState.isMobileVerified;
    } finally {
      formState.isVerifyingMobile = false;
      notifyListeners();
    }
  }

  // Validate current step
  bool validateCurrentStep() => formState.validateCurrentStep(_currentStep);

  void goToNextStep(BuildContext context) {
    if (validateCurrentStep()) {
      if (_currentStep < 4) {
        _currentStep++;
      }
      notifyListeners();
      return;
    }
  }

  void goToPreviousStep() {
    if (_currentStep > 0) {
      _currentStep--;
    }
    notifyListeners();
  }

  // Submit registration
  Future<Either<NetworkFailure, MerchantRegistrationResponse>>
  submitRegistration(BuildContext context) async {
    isLoading = true;

    try {
      // Get selected plan details
      final selectedPlanModel = plans.firstWhere(
        (plan) => plan.id == formState.selectedPlan,
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
      final merchantRegistrationRequest = MerchantRegistrationPayload(
        username: formState.nameController.text.trim(),
        email: formState.emailController.text.trim(),
        mobile: formState.mobileController.text.trim(),
        state: formState.selectedState.trim(),
        pinCode: formState.pincodeController.text.trim(),
        password: formState.passwordController.text.trim(),
        address: formState.addressController.text.trim(),
        gender: formState.gender.toLowerCase(),

        /// TODO: comment this portions as of clint request.
        businessStartYear: '2020', //formState.startYearController.text.trim(),
        mobileStatus: formState.mobileStatus.toLowerCase(),
        receiveOptions: formState.notificationStatus.toLowerCase().trim(),
        businessLocation: formState.businessLocationController.text.trim(),
        companyName: formState.shopNameController.text.trim(),
        gstIn: formState.gstinController.text.trim(),
        pan: formState.panCardController.text.trim(),
        city: formState.selectedCity.trim(),
        companyLogo: null,
        kyc: 0,
        latitude: formState.lat,
        longitude: formState.long,
        planId: selectedPlanModel.id,
        planName: selectedPlanModel.planName.trim(),
        gst: gst.toStringAsFixed(2),
        amount: amount.toStringAsFixed(2),
        startDate: startDateStr,
        endDate: endDateStr,
        validity: selectedPlanModel.validity,
        categoryId: formState.selectedCategory,
        serviceId: formState.selectedService,
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
    var cont = context;
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
      dev.log("hello Onw");
      final response = await submitRegistration(context);

      response.fold(
        (failure) {
          if (cont.mounted) {
            cont.showSnackBarX('Registration failed');
            NotifyService.snackbar(
              context: context,
              message: 'Registration failed. Please try again.',
              type: NotificationType.error,
            );
          }
        },
        (data) {
          data.fold(
            onError: (message) {
              NotifyService.snackbar(
                context: context,
                message: message,
                type: NotificationType.success,
              );
            },

            onOtpRequired: (data, otp, merchant, sub, ser) {
              _showOtpNotification(otp ?? '111111');
              formState.clear();
              if (context.mounted) {
                route.push(
                  '${MerchantRoute.merchantOtp}/${merchant!.id}/${merchant.mobile}',
                );
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
