import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/snack_bar_service/notify_service.dart';
import '../../../../core/data/model/model.dart';
import '../../../../core/services/service.dart';
import '../../core/merchant_navigation.dart';
import '../../merchant_dashboard/core/merchant_dashboard_route.dart';

class MerchantLoginScreenViewModel extends ChangeNotifier {
  final MerchantAuthService _authService;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  MerchantLoginScreenViewModel(this._authService) {
    emailController.addListener(_notifyChanges);
    passwordController.addListener(_notifyChanges);
  }

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Status
  NetworkCallStatus _status = NetworkCallStatus.initial;
  String _errorMessage = '';
  MerchantModel? _merchant;

  // Getters
  NetworkCallStatus get status => _status;
  String get errorMessage => _errorMessage;
  MerchantModel? get merchant => _merchant;

  void _notifyChanges() {
    notifyListeners();
  }

  // Form validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void login(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      setLoading(true);

      final request = PostMerchantLogin(
        username: emailController.text.trim(),
        password: passwordController.text,
      );

      final result = await _authService.login(request: request);

      result.fold(
        (failure) {
          setLoading(false);

          NotifyService.snackbar(
            context: context,
            message: failure.message,
            type: NotificationType.error,
          );
          return;
        },
        (merchant) {
          dev.log('MERCHANT-LOGIN-VIEW-MODEL:=> $merchant');
          setLoading(false);
          reset();
          if (merchant.type == MerchantLoginResponseType.otpRequired) {
            context.go(
              '${MerchantRoute.merchantOtp}/${merchant.data!['merchant_id']}/${merchant.data!['mobile']}',
            );
            return;
          } else {
            NotifyService.snackbar(
              context: context,
              message: merchant.message,
              type: NotificationType.success,
            );
            context.go(MerchantDashboardRoute.dashboard);
          }
        },
      );
    }
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
    _status = NetworkCallStatus.initial;
    _errorMessage = '';
    _merchant = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up controllers when provider is disposed
    emailController.removeListener(_notifyChanges);
    passwordController.removeListener(_notifyChanges);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
