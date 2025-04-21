import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_ad/core/constant/image.dart';
import 'package:my_ad/core/data/model/model.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      width: size.width,
      child: SvgPicture.string(
        AppImage.quiteStreetSvg,
        height: 85,
        width: size.width,
        // colorFilter: ColorFilter.mode(
        //   OnboardingPageModel.pages.first.endColor.withValues(
        //     blue: 0.6,
        //     alpha: 0.6,
        //   ),
        //   BlendMode.srcOut,
        // ),
      ),
    );
  }
}

