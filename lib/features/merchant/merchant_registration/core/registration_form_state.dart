import 'package:flutter/material.dart';

/// A dedicated class to manage form state for merchant registration
class RegistrationFormState {
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

  // Mobile verification status
  bool _isMobileVerified;
  bool _isVerifyingMobile;

  RegistrationFormState({
    String initialGender = 'Male',
    String initialState = '24',
    String initialPlan = '1',
    String initialMobileStatus = 'Private',
    String initialNotificationStatus = 'Chat',
  })  : nameController = TextEditingController(),
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
        _isMobileVerified = false,
        _isVerifyingMobile = false;

  // Getters
  String get gender => _gender;
  String get selectedState => _selectedState;
  String get selectedPlan => _selectedPlan;
  String get mobileStatus => _mobileStatus;
  String get notificationStatus => _notificationStatus;
  bool get passwordVisible => _passwordVisible;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  bool get isMobileVerified => _isMobileVerified;
  bool get isVerifyingMobile => _isVerifyingMobile;

  // Setters
  set gender(String value) {
    _gender = value;
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

  // Validation methods
  bool validatePersonalInfo() {
    return personalInfoFormKey.currentState?.validate() ?? false;
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
        return validatePersonalInfo();
      case 1:
        return validateBusinessDetails();
      case 2:
        return validateAddress();
      case 3:
        return validateAccount();
      default:
        return false;
    }
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
    _selectedPlan = '1';
    _mobileStatus = 'Private';
    _notificationStatus = 'Chat';
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
