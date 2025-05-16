import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:pack/pack.dart';

import '../../../../../core/data/model/merchant/merchant_model.dart';
import '../../../../../core/injector/dependency_injection.dart';

class MerchantProfileProvider extends ChangeNotifier {
  MerchantModel? profile;
  bool isLoading = false;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      // Replace with actual store/provider fetch
      final store = DependencyInjector.get<MerchantDashboardStore>();
      profile = store.entity?.merchantData.merchant;
      if (profile == null) throw Exception('Profile not found');
    } catch (e) {
      error = 'Failed to load profile';
    }
    isLoading = false;
    notifyListeners();
  }

  void onEditProfile() {
    // TODO: Implement edit profile navigation
  }

  void onAccountSettings() {
    // TODO: Implement account settings navigation
  }

  void onBusinessInfo() {
    // TODO: Implement business info navigation
  }

  void onSubscription() {
    // TODO: Implement subscription navigation
  }

  void onNotifications() {
    // TODO: Implement notifications navigation
  }

  void onHelp() {
    // TODO: Implement help navigation
  }

  void onPrivacy() {
    // TODO: Implement privacy navigation
  }

  void onLogout() {
    // TODO: Implement logout logic
  }
}
