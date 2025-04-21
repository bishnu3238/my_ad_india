import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/services/service.dart';

import '../../../core/data/model/model.dart';
import '../../../core/data/model/response/referral_response.dart';
 import 'package:my_ad/features/home/core/home_navigator.dart';

import '../../../core/domain/use_cases/api_call_use_cases.dart';

class ReferAndEarnProvider with ChangeNotifier {
  final AuthProviderModel<UserModel> _authProvider;
  final ApiCallUseCase _apiCallUseCase;

  ReferAndEarnProvider(this._authProvider, this._apiCallUseCase);

  // User Data
  UserModel? get user => _authProvider.user;

  bool _isLoading = false;
  String? _errorMessage;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Referral Submission Logic
  Future<void> submitReferral({
    required String name,
    required String phone,
    String? email,
    required BuildContext context, // Add context here
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);
    setErrorMessage(null); // Clear any previous error message

    try {
      await _submitReferralToBackend(
        context,
        name: name,
        phone: phone,
        email: email,
      );
    } catch (e) {
      setErrorMessage(e.toString());
      _showErrorDialog(context, e.toString()); // Pass context and error message
    } finally {
      setLoading(false);
    }
  }

  // Mock Backend Submission (Replace with actual API call)
  Future<void> _submitReferralToBackend(
    BuildContext context, {
    required String name,
    required String phone,
    String? email,
  }) async {
    final request = PostReferralRequest(
      name: name,
      email: email ?? '',
      phone: phone,
    );
    await _apiCallUseCase
        .submitReferralRequest(request)
        .then(
          (value) => value.fold(
            (failure) => NotifyService.snackbar(
              context: context,
              message: failure.message,
            ),
            (result) {
              if (result.type == ReferralResponseType.success) {
                NotifyService.snackbar(
                  context: context,
                  message: result.message,
                  type: NotificationType.success
                );
                _showSuccessDialog(context); // Pass context here
              } else {
                _showErrorDialog(context, result.message);
              }
            },
          ),
        );
  }

  // Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Referral Submitted'),
            content: const Text(
              'Thank you for becoming an agent! We will contact you soon.',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  context.pop();
                  context.go(HomeRoute.home);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Error Dialog
  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Submission Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Try Again'),
              ),
            ],
          ),
    );
  }
}
