import 'package:go_router/go_router.dart';
import 'package:my_ad/core/data/model/merchant/merchant.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/core/merchant_dashboard_route.dart';
import '../merchant_registration/merchant_registration_screen.dart';
import '../merchant_login/merchant_login_screen.dart';
import '../merchant_otp/merchant_otp_verification_screen.dart';
import '../merchant_dashboard/merchant_dashboard_shell.dart';
import 'dart:developer' as dev;

class MerchantRoute {
  static String merchantLogin = '/merchant-login';
  static String merchantOtp = '/otp-verify';
  static String merchantDashboard = '/merchant-dashboard';
  static String merchantRegister = '/merchant-register';

  /// params
  static String otpParam1MerchantId = '/:merchantId';

  static List<GoRoute> pages() {
    return [
      GoRoute(
        path: merchantLogin,
        builder: (context, state) => MerchantLoginScreen(),
      ),
      GoRoute(
        path: merchantRegister,
        builder: (ctx, state) => MerchantRegistrationScreen(),
      ),
      GoRoute(
        path: '$merchantOtp/:merchantId/:mobile',
        builder:
            (context, state) => OTPVerificationScreen(
              merchantId: state.pathParameters['merchantId']!,
              mobile:  state.pathParameters['mobile']!,
            ),
      ),

      // GoRoute(
      //   path: merchantDashboard,
      //   builder: (context, state) => MerchantDashboardScreen(),
      // ),
    ];
  }
}
