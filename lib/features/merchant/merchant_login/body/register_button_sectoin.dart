import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color_palette.dart';
import '../../core/merchant_navigation.dart';

class RegisterButtonSections extends StatelessWidget {
  const RegisterButtonSections({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            context.push(MerchantRoute.merchantRegister);
          },
          child: Text(
            'Register',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.5, end: 0, duration: 500.ms);
  }
}
