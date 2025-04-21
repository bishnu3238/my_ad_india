import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIconWidget extends StatelessWidget {
  final String iconPath;
  final double height, width;
  final ColorFilter? colorFilter;
  final String package;
  final VoidCallback? onTap;

  const SvgIconWidget({
    super.key,
    required this.iconPath,
    this.height = 25,
    this.width = 25,
    this.colorFilter,
    this.package = 'pack',
    this.onTap ,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        height: height,
        width: width,
        colorFilter:
            colorFilter ?? ColorFilter.mode(theme.primary, BlendMode.srcIn),
        iconPath,
        package: package,
      ),
    );
  }
}
