import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_ad/core/constant/image.dart';

import '../../../../core/theme/app_color_palette.dart';

List<Widget> listOfPositions = [
  Positioned(
    top: -100,
    left: -50,
    child: Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    ),
  ),
  Positioned(
    bottom: -100,
    right: -50,
    child: Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
    ),
  ),

];
