import 'package:flutter/material.dart';
import 'package:my_ad/core/constant/image.dart';
import 'package:my_ad/core/theme/app_color_palette.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pack/pack.dart';

class MerchantLoginHeader extends StatelessWidget {
  const MerchantLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceLight,
                  AppColors.primaryOrange.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ImageView(
              source: ImageSource.asset,
              path: AppImage.logo,
              width: 50,
              height: 50,
            ),

            // Center(
            //   child: Icon(
            //     Icons.storefront,
            //     color: Colors.white,
            //     size: 50,
            //   ),
            // ),
          ).animate().scale(duration: 600.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
                'Merchant Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 500.ms)
              .fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}
