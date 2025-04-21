 import 'package:flutter/material.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/core/services/merchant_auth_service.dart';
import 'package:provider/provider.dart';
 import 'body/otp_verification_body.dart';
import 'core/merchant_otp_viewmodel.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String merchantId;

  const OTPVerificationScreen({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OTPProvider(DependencyInjector.get<MerchantAuthService>(),merchantId: merchantId),
      child: Scaffold(
        appBar: AppBar(title: const Text('OTP Verification')),
        body: const OTPVerificationBody(),
      ),
    );
  }
}

