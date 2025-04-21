// drawer_provider.dart
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:pack/auth/custom_auth.dart';
import '../../core/data/model/model.dart';

class DrawerProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  DrawerProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check authentication status
      _isAuthenticated = await CustomAuth.isAuthenticated<UserModel>();

      if (_isAuthenticated) {
        // Get current user if authenticated
        _user = await CustomAuth.getCurrentUser<UserModel>();
      }
    } catch (e) {
      dev.log('Error initializing drawer provider: $e');
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Listen to auth changes
  void setupAuthListener() {
    // Set up a stream subscription to the AuthBloc if needed
    // You could subscribe to a stream from your AuthProviderModel
  }

  // Handle logout
  Future<bool> logout() async {
    try {
      bool success = await CustomAuth.logout<UserModel>();

      if (success) {
        _user = null;
        _isAuthenticated = false;
        notifyListeners();
      }

      return success;
    } catch (e) {
      dev.log('Error logging out: $e');
      return false;
    }
  }

  // Method to refresh user data after login or profile update
  Future<void> refreshUserData() async {
    try {
      _isAuthenticated = await CustomAuth.isAuthenticated<UserModel>();

      if (_isAuthenticated) {
        _user = await CustomAuth.getCurrentUser<UserModel>();
      } else {
        _user = null;
      }

      notifyListeners();
    } catch (e) {
      dev.log('Error refreshing user data: $e');
    }
  }
}

