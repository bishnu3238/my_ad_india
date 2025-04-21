import 'package:flutter/material.dart';
import '../../../core/constant/image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pack/pack.dart';
import '../../../core/theme/app_color_palette.dart';
import '../core/intro_provider.dart';
import 'package:provider/provider.dart';

class IntroBody extends StatelessWidget {
  const IntroBody({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Logo
          Hero(
            tag: 'app_logo',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: screenSize.width * 0.1,
                child: ImageView(
                  source: ImageSource.asset,
                  path: AppImage.logo,
                  width: screenSize.width * 0.3,
                ),
              ),
            ).animate().fadeIn(duration: 800.ms).scale(duration: 800.ms),
          ),

          SizedBox(height: screenSize.height * 0.03),

          // Tagline
          Text(
                'Connect, Discover, Advertise',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.purpleDeep,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 800.ms)
              .slideY(begin: 0.5, end: 0, duration: 800.ms),

          SizedBox(height: screenSize.height * 0.05),

          // Get Started Button
          _buildGetStartedButton(context, theme),
        ],
      ),
    );
  }
}

Widget _buildGetStartedButton(BuildContext context, ThemeData theme) {
  return Consumer<IntroProvider>(
    builder: (context, introProvider, _) {
      return SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 60,
            child:
                introProvider.isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                    )
                    : ElevatedButton(
                      onPressed:
                          () => introProvider.navigateAfterFetch(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          )
          .animate()
          .fadeIn(delay: 1000.ms, duration: 800.ms)
          .scale(duration: 800.ms);
    },
  );
}
