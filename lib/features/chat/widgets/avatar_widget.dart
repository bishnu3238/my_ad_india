import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 18,
    this.fallbackIcon = Icons.business,
    this.fallbackColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      child: imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            fallbackIcon,
            size: radius,
            color: Theme.of(context).primaryColor,
          ),
        ),
      )
          : Icon(
        fallbackIcon,
        size: radius,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}