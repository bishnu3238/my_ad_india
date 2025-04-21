import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/core/merchant_navigation.dart';
import '../core/home_navigator.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../provider_state/scroll_visibility_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeFloatingButton extends StatelessWidget {
  const HomeFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Consumer<ScrollVisibilityProvider>(
      builder: (context, scrollProvider, child) {
        return AnimatedSlide(
          offset: scrollProvider.isVisible ? const Offset(0, 3) : Offset.zero,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: FloatingActionButton(
            backgroundColor: AppColors.yellow,
            shape: CircleBorder(),
            key: const ValueKey('visible'),
            onPressed: () => context.push(MerchantRoute.merchantRegister),
            child: Text(
              'POST\nAD',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: AppColors.textLight,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}
