import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'body/merchant_login_form.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/image.dart';
import '../../../core/theme/app_color_palette.dart';
import 'body/list_of_positions.dart';
import 'core/merchant_login_viewmodel.dart';

class MerchantLoginScreen extends StatelessWidget {
  const MerchantLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Abstract Background Shapes
          ...listOfPositions,
          Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: SvgPicture.string(
              AppImage.quiteStreetSvg,
              width: MediaQuery.of(context).size.width,
              height: 100,
              // colorFilter: ColorFilter.mode(Colors.red, BlendMode.src),
            ),
          ),

          // Main Content
          MerchantLoginForm(),
        ],
      ),
    );
  }
}
