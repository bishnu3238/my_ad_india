import 'package:flutter/material.dart';

/// A dedicated class to manage form state for merchant registration
class RegistrationFormState {
  String _selectedCategory = '';
  String _selectedServices = '';

  double _lat, _lang;

  String? _mobileAvailabilityMessage = '';

  // Personal Info
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  String _gender;

  // Business Details
  final TextEditingController shopNameController;
  final TextEditingController startYearController;
  final TextEditingController businessLocationController;
  final TextEditingController panCardController;
  final TextEditingController gstinController;

  // Address
  final TextEditingController addressController;
  final TextEditingController pincodeController;
  String _selectedState;
  String _selectedCity;

  // Account
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController referralController;

  String _selectedPlan;
  String _mobileStatus;
  String _notificationStatus;

  // Password visibility
  bool _passwordVisible;
  bool _confirmPasswordVisible;

  // Form keys for validation
  final GlobalKey<FormState> personalInfoFormKey;
  final GlobalKey<FormState> businessDetailsFormKey;
  final GlobalKey<FormState> addressFormKey;
  final GlobalKey<FormState> accountFormKey;
  final GlobalKey<FormState> categoryAndServicesFormKey;

  // Mobile verification status
  bool _isMobileVerified;
  bool _isVerifyingMobile;
  bool isTermsAccepted = false;

  RegistrationFormState({
    String initialGender = 'Male',
    String initialState = '24',
    String initialCity = '32',
    String initialPlan = '4',
    String initialMobileStatus = 'Private',
    String initialNotificationStatus = 'Chat',
  }) : nameController = TextEditingController(),
       emailController = TextEditingController(),
       mobileController = TextEditingController(),
       _gender = initialGender,
       shopNameController = TextEditingController(),
       startYearController = TextEditingController(),
       businessLocationController = TextEditingController(),
       panCardController = TextEditingController(),
       gstinController = TextEditingController(),
       addressController = TextEditingController(),
       pincodeController = TextEditingController(),
       _selectedCity = initialCity,
       _selectedState = initialState,
       passwordController = TextEditingController(),
       confirmPasswordController = TextEditingController(),
       referralController = TextEditingController(),
       _selectedPlan = initialPlan,
       _mobileStatus = initialMobileStatus,
       _notificationStatus = initialNotificationStatus,
       _passwordVisible = false,
       _confirmPasswordVisible = false,
       personalInfoFormKey = GlobalKey<FormState>(),
       businessDetailsFormKey = GlobalKey<FormState>(),
       addressFormKey = GlobalKey<FormState>(),
       accountFormKey = GlobalKey<FormState>(),
       categoryAndServicesFormKey = GlobalKey<FormState>(),
       _isMobileVerified = false,
       _isVerifyingMobile = false,
       _selectedCategory = '',
       _selectedServices = '',
       _lat = 0,
       _lang = 0,
       _mobileAvailabilityMessage = '';

  // Getters

  String get gender => _gender;
  double get lat => _lat;
  double get long => _lang;
  String get selectedCity => _selectedCity;
  String get selectedCategory => _selectedCategory;
  String get selectedService => _selectedServices;
  String get selectedState => _selectedState;
  String get selectedPlan => _selectedPlan;
  String get mobileStatus => _mobileStatus;
  String get notificationStatus => _notificationStatus;
  String get mobileAvailabilityMessage => _mobileAvailabilityMessage ?? '';

  bool get passwordVisible => _passwordVisible;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  bool get isMobileVerified => _isMobileVerified;
  bool get isVerifyingMobile => _isVerifyingMobile;

  // Setters

  set lat(double value) {
    _lat = value;
  }

  set long(double value) {
    _lang = value;
  }

  set gender(String value) {
    _gender = value;
  }

  set selectedCity(String value) {
    _selectedCity = value;
  }

  set selectedState(String value) {
    _selectedState = value;
  }

  set selectedPlan(String value) {
    _selectedPlan = value;
  }

  set mobileStatus(String value) {
    _mobileStatus = value;
  }

  set notificationStatus(String value) {
    _notificationStatus = value;
  }

  set passwordVisible(bool value) {
    _passwordVisible = value;
  }

  set confirmPasswordVisible(bool value) {
    _confirmPasswordVisible = value;
  }

  set isMobileVerified(bool value) {
    _isMobileVerified = value;
  }

  set isVerifyingMobile(bool value) {
    _isVerifyingMobile = value;
  }

  set selectCategory(String value) {
    _selectedCategory = value;
  }

  set selectService(String value) {
    _selectedServices = value;
  }

  set mobileAvailabilityMessage(String value) {
    _mobileAvailabilityMessage = value;
  }

  // Validation methods
  bool validateCategorySelectionInfo() {
    if (_selectedCategory.isNotEmpty && _selectedServices.isNotEmpty) {
      return categoryAndServicesFormKey.currentState?.validate() ?? false;
    }
    return false;
  }

  bool validatePersonalInfo() {
    if (personalInfoFormKey.currentState!.validate()) {
      if (isMobileVerified) return true;
      return false;
    }
    return false;
  }

  bool validateBusinessDetails() {
    return businessDetailsFormKey.currentState?.validate() ?? false;
  }

  bool validateAddress() {
    return addressFormKey.currentState?.validate() ?? false;
  }

  bool validateAccount() {
    return accountFormKey.currentState?.validate() ?? false;
  }

  // Validation for the current step
  bool validateCurrentStep(int step) {
    switch (step) {
      case 0:
        return validateCategorySelectionInfo();
      case 1:
        return validatePersonalInfo();
      case 2:
        return validateBusinessDetails();
      case 3:
        return validateAddress();
      case 4:
        return validateAccount();
      default:
        return false;
    }
  }

  // Add a method to clear this if needed
  void clearCategoryAndServices() {
    _selectedCategory = '';
    _selectedServices = '';
  }

  // Clear all form data
  void clear() {
    nameController.clear();
    emailController.clear();
    mobileController.clear();
    shopNameController.clear();
    startYearController.clear();
    businessLocationController.clear();
    panCardController.clear();
    gstinController.clear();
    addressController.clear();
    pincodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    referralController.clear();

    _gender = 'Male';
    _selectedState = '24';
    _selectedPlan = '4';
    _selectedCategory = '';
    _selectedServices = '';
    _mobileStatus = 'Private';
    _notificationStatus = 'Chat';

    lat = 0;
    long = 0;

    _passwordVisible = false;
    _confirmPasswordVisible = false;
    _isMobileVerified = false;
    _isVerifyingMobile = false;
  }

  // Dispose all controllers
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    shopNameController.dispose();
    startYearController.dispose();
    businessLocationController.dispose();
    panCardController.dispose();
    gstinController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralController.dispose();
  }
}
