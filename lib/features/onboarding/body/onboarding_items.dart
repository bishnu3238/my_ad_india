import 'package:flutter/material.dart';
import 'package:pack/pack.dart';
import '../../../core/data/model/onboarding_page_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;

  const OnboardingPage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageView(
          source: ImageSource.asset,
          path: page.illustrationPath,
          package: 'pack',
        ).animate().fadeIn(duration: 600.ms).scale(begin: Offset(0.7, 0)),

        const SizedBox(height: 40),

        Text(
              page.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                // color: Colors.white,
              ),
            )
            .animate()
            .slideY(begin: 0.5, end: 0)
            .fadeIn(duration: 600.ms, delay: 300.ms),

        const SizedBox(height: 20),

        Text(
              page.description,
              // style: TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            )
            .animate()
            .slideY(begin: 0.5, end: 0)
            .fadeIn(duration: 600.ms, delay: 600.ms),
      ],
    );
  }
}
