import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:my_ad/core/domain/repository/user_repository.dart';
import 'package:pack/auth/custom_auth.dart';

import '../../../core/data/model/model.dart';
import '../../../core/data/repository/user_repository/user_repository_requests.dart';

enum ProfileUpdateStatus { initial, loading, success, error }

class ProfileProviderModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _user;
  String? _errorMessage;
  ProfileUpdateStatus _status = ProfileUpdateStatus.initial;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  ProfileUpdateStatus get status => _status;

  ProfileProviderModel(this._userRepository) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _user = (await CustomAuth.getCurrentUser<UserModel>())!;
      notifyListeners();
    } catch (e) {
      dev.log('Error initializing profile provider: $e');
      _errorMessage = 'Failed to load user profile';
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? additionalData,
  }) async {
    _status = ProfileUpdateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userRepository.updateProfile(
        request: UpdateProfileRequest(
          name: name,
          email: email,
          phone: phone,
          additionalData: additionalData,
        ),
      );

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _status = ProfileUpdateStatus.error;
        },
        (updatedUser) {
          _user = updatedUser;
          _status = ProfileUpdateStatus.success;
        },
      );
    } catch (e) {
      dev.log('Error updating profile: $e');
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _status = ProfileUpdateStatus.error;
    }

    notifyListeners();
  }

  Future<void> updateProfilePicture(String imagePath) async {
    _status = ProfileUpdateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userRepository.updateProfilePicture(imagePath);

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _status = ProfileUpdateStatus.error;
        },
        (updatedUser) {
          _user = updatedUser;
          _status = ProfileUpdateStatus.success;
        },
      );
    } catch (e) {
      dev.log('Error updating profile picture: $e');
      _errorMessage = 'Failed to update profile picture: ${e.toString()}';
      _status = ProfileUpdateStatus.error;
    }

    notifyListeners();
  }

  void resetStatus() {
    _status = ProfileUpdateStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
