import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/services/merchant_auth_service.dart';
import 'package:pack/services/snack_bar_service/notify_service.dart';

import '../../../../core/services/merchant_dashboard_service.dart';
import '../../../home/core/home_navigator.dart';
import '../../core/merchant_auth_provider.dart';

class MerchantDashboardShellProvider extends ChangeNotifier {
  final MerchantAuthService _authService;
  final MerchantDashboardService merchantDashboardService;
  late final StatefulNavigationShell _shell;

  MerchantDashboardShellProvider(
    this._authService,
    this.merchantDashboardService, {

    required StatefulNavigationShell shell,
  }) {
    _shell = shell;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  StatefulNavigationShell get  shell =>_shell;


  onLogout(BuildContext context) async {
    final route = GoRouter.of(context);
    isLoading = true;
    if (context.mounted) route.pop();
    await Future.delayed(const Duration(seconds: 1), () async {
      await _authService.logout();
      isLoading = false;
      route.go(HomeRoute.home);
      notifyListeners();
    });
  }
}
