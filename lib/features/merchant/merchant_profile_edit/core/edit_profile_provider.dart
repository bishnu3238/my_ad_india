import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:pack/constant/enums.dart';
import 'package:path/path.dart' as path;

import '../../../../../core/data/model/merchant/merchant_model.dart';
import '../../../../../core/domain/data_store/data_store.dart';
import '../../../../../core/injector/dependency_injection.dart';
import '../../../../core/services/merchant_dashboard_service.dart';
import 'edit_profile_state.dart';

class EditProfileProvider extends ChangeNotifier {
  final MerchantDashboardService _dashboardService;
  final _merchantStore = DependencyInjector.get<MerchantDashboardStore>();
  final _dio = Dio();
  final _imagePicker = ImagePicker();

  EditProfileState _state = EditProfileState(merchant: MerchantModel.empty());

  EditProfileState get state => _state;

  File? _selectedImage;

  EditProfileProvider(this._dashboardService) {
    _initState();
  }

  Future<void> _initState() async {
    try {
      _state = _state.copyWith(status: EditProfileStatus.loading);
      notifyListeners();

      final merchant = _merchantStore.entity?.merchantData.merchant;
      if (merchant == null) {
        throw Exception('Profile not found');
      }

      _state = _state.copyWith(
        merchant: merchant,
        status: EditProfileStatus.success,
      );
    } catch (e) {
      dev.log('Error initializing edit profile: $e');
      _state = _state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Failed to load profile data',
      );
    } finally {
      notifyListeners();
    }
  }

  void updateUsername(String username) {
    if (username == _state.merchant.username) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(username: username),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateEmail(String email) {
    if (email == _state.merchant.email) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(email: email),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateMobile(String mobile) {
    if (mobile == _state.merchant.mobile) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(mobile: mobile),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateCompanyName(String companyName) {
    if (companyName == _state.merchant.companyName) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(companyName: companyName),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateGstin(String? gstin) {
    if (gstin == _state.merchant.gstin) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(gstin: gstin),
      isDirty: true,
    );
    notifyListeners();
  }

  void updatePan(String? pan) {
    if (pan == _state.merchant.pan) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(pan: pan),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateAddress(String address) {
    if (address == _state.merchant.address) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(address: address),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateBusinessLocation(String location) {
    if (location == _state.merchant.businessLocation) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(businessLocation: location),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateGender(Gender gender) {
    if (gender == _state.merchant.gender) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(gender: gender),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateBusinessStartYear(int year) {
    if (year == _state.merchant.businessStartYear) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(businessStartYear: year),
      isDirty: true,
    );
    notifyListeners();
  }

  void updateMobileStatus(MobileStatus status) {
    if (status == _state.merchant.mobileStatus) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(mobileStatus: status),
      isDirty: true,
    );
    notifyListeners();
  }

  void updatePincode(String pincode) {
    if (pincode == _state.merchant.pincode) return;
    _state = _state.copyWith(
      merchant: _state.merchant.copyWith(pincode: pincode),
      isDirty: true,
    );
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      _selectedImage = File(pickedImage.path);
      _state = _state.copyWith(isImageChanged: true, isDirty: true);
      notifyListeners();
    } catch (e) {
      dev.log('Error picking image: $e');
      _state = _state.copyWith(errorMessage: 'Failed to pick image');
      notifyListeners();
    }
  }

  Future<void> saveProfile() async {
    if (!_state.isDirty && !_state.isImageChanged) return;

    try {
      _state = _state.copyWith(isSubmitting: true);
      notifyListeners();

      final merchantId = _state.merchant.id;
      if (merchantId == null) {
        throw Exception('Merchant ID is missing');
      }

      final payload = EditProfilePayload(
        id: merchantId,
        username: _state.merchant.username,
        email: _state.merchant.email,
        mobile: _state.merchant.mobile,
        companyName: _state.merchant.companyName,
        gstin: _state.merchant.gstin,
        pan: _state.merchant.pan,
        address: _state.merchant.address,
        businessLocation: _state.merchant.businessLocation,
        gender: _state.merchant.gender,
        businessStartYear: _state.merchant.businessStartYear,
        mobileStatus: _state.merchant.mobileStatus,
        pincode: _state.merchant.pincode,
      );

      _dashboardService.editMerchantProfile(
        merchantId.toString(),
        payload.toMap(),
        _selectedImage!,
        (s, d) {},
      );
    } catch (e) {
      dev.log('Error saving profile: $e');
      _state = _state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'Failed to save profile: ${e.toString()}',
      );
    } finally {
      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
    }
  }

  // Reset form to original state
  void resetForm() {
    _initState();
    _selectedImage = null;
  }

  // Get image for display (either selected new image or existing logo URL)
  ImageProvider? getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_state.merchant.companyLogo != null &&
        _state.merchant.companyLogo!.isNotEmpty) {
      return NetworkImage(_state.merchant.companyLogo!);
    }
    return null;
  }
}

class EditProfilePayload {
  final int id;
  final String username;
  final String email;
  final String mobile;
  final String companyName;
  final String? gstin;
  final String? pan;
  final String address;
  final String businessLocation;
  final Gender gender;
  final int businessStartYear;
  final MobileStatus mobileStatus;
  final String pincode;

  EditProfilePayload({
    required this.id,
    required this.username,
    required this.email,
    required this.mobile,
    required this.companyName,
    this.gstin,
    this.pan,
    required this.address,
    required this.businessLocation,
    required this.gender,
    required this.businessStartYear,
    required this.mobileStatus,
    required this.pincode,
  });

  Map<String, String> toMap() {
    return {
      'id': id.toString(),
      'username': username,
      'email': email,
      'mobile': mobile,
      'company_name': companyName,
      if (gstin != null) 'gstin': gstin ?? '',
      if (pan != null) 'pan': pan ?? "",
      'address': address,
      'business_location': businessLocation,
      'gender': gender.name,
      'business_start_year': businessStartYear.toString(),
      'mobile_status': mobileStatus.name,
      'pincode': pincode,
    };
  }
}

class EditProfileResponse {
  final bool success;
  final String? message;
  final String? companyLogo;

  EditProfileResponse({required this.success, this.message, this.companyLogo});

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      success: json['status'] == 'success',
      message: json['message'],
      companyLogo: json['company_logo'],
    );
  }
}
