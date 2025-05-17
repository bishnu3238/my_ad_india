import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/core/services/merchant_auth_service.dart';
import 'package:my_ad/features/merchant/merchant_notification/core/notification_route.dart';
import 'package:my_ad/features/terms/core/terms_and_conditions_route.dart';
import 'package:pack/pack.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../home/core/home_navigator.dart';
import '../../../merchant_profile_edit/core/edit_profile_navigator.dart';
import '../../../../../core/data/model/merchant/merchant_model.dart';
import '../../../../../core/injector/dependency_injection.dart';
import '../../core/merchant_dashboard_shell_provider.dart';

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

  void onEditProfile(BuildContext context) {
    context.push(EditMerchantProfileNavigator.editPath);
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

  void onNotifications(BuildContext context) {
    context.push(NotificationRoute.notification);
  }

  void onHelp(BuildContext context) {
    context.push(TermsRoute.help);
  }

  void onPrivacy(BuildContext context) {
    context.push(TermsRoute.privacyPolicy);
  }

  void onLogout(BuildContext context) async {
    final route = GoRouter.of(context);
    isLoading = true;
    if (context.mounted) {
      await Future.delayed(const Duration(seconds: 1), () async {
        await DependencyInjector.get<MerchantAuthService>().logout();
        isLoading = false;
        route.go(HomeRoute.home);
        notifyListeners();
      });
    }
  }
}
