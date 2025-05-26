import 'package:flutter/material.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cupertino-inspired colors
    const primaryGradientStart = Color(0xFF64B5F6);
    const primaryGradientEnd = Color(0xFF1976D2);
    const secondaryColor = Color(0xFFE0F7FA);
    const inactiveColor = Color(0xFF90A4AE);
    const shadowColor = Color(0x1A000000);

    return Container(
      height: kBottomNavigationBarHeight + 10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                0,
                SvgIcons.dashboardIcon,
                'Home',
                primaryGradientStart,
                primaryGradientEnd,
                secondaryColor,
                inactiveColor,
              ),
              _buildNavItem(
                context,
                1,
                SvgIcons.reportChart,
                'Reviews',
                primaryGradientStart,
                primaryGradientEnd,
                secondaryColor,
                inactiveColor,
              ),
              _buildNavItem(
                context,
                2,
                SvgIcons.diamond,
                'Services',
                primaryGradientStart,
                primaryGradientEnd,
                secondaryColor,
                inactiveColor,
              ),
              _buildNavItem(
                context,
                3,
                SvgIcons.chatIcon,
                'Messages',
                primaryGradientStart,
                primaryGradientEnd,
                secondaryColor,
                inactiveColor,
              ),
              _buildNavItem(
                context,
                4,
                SvgIcons.userProfileCircleIcon,
                'Profile',
                primaryGradientStart,
                primaryGradientEnd,
                secondaryColor,
                inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String icon,
    String label,
    Color gradientStart,
    Color gradientEnd,
    Color secondaryColor,
    Color inactiveColor,
  ) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 50,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration:
            isSelected
                ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [gradientStart, gradientEnd],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientStart.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
                : BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIconWidget(
              iconPath: icon,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : inactiveColor,
                BlendMode.srcIn,
              ),
              package: 'pack',
              height: 22,
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
