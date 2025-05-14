import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/image.dart';
import '../../../core/theme/app_color_palette.dart';
import '../core/intro_provider.dart';

class IntroBody extends StatelessWidget {
  const IntroBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IntroProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoSection(context),
              const SizedBox(height: 40),
              _buildFeatureHighlights(context),
              const SizedBox(height: 60),
              _buildLocationIndicator(context),
              const SizedBox(height: 40),
              _buildGetStartedButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        // Logo with pulsing effect
        Hero(
          tag: 'app_logo',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  spreadRadius: 10,
                  blurRadius: 20,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: screenSize.width * 0.12,
              child: ImageView(
                source: ImageSource.asset,
                path: AppImage.logo,
                width: screenSize.width * 0.15,
              ),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 800.ms)
            .scale(duration: 1200.ms)
            .then()
            .shimmer(duration: 1800.ms, delay: 800.ms)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        ),

        const SizedBox(height: 24),

        // App name with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withValues(alpha:0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'ServiceLink',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

        const SizedBox(height: 12),

        // Tagline with typing animation
        Text(
          'Your bridge to quality local services',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha:0.9),
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.search_rounded,
          title: 'Find Nearby Providers',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.message_rounded,
          title: 'Direct Communication',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.verified_rounded,
          title: 'Verified Service Quality',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideX(
      begin: -0.2,
      end: 0,
      duration: 600.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildLocationIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Connecting you with local providers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1600.ms, duration: 800.ms);
  }

  Widget _buildGetStartedButton(BuildContext context, IntroProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: provider.isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : ElevatedButton(
        onPressed: () => provider.navigateAfterFetch(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryBlue,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha:0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1800.ms, duration: 800.ms).slideY(
      begin: 0.2,
      end: 0,
      duration: 800.ms,
      curve: Curves.easeOutQuad,
    );
  }
}