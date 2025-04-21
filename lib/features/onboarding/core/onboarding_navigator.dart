import 'package:go_router/go_router.dart';

import '../onboarding_screen.dart';

class OnboardingRoute{

  static const String onBoarding = "/onboarding";

  static GoRoute page() => GoRoute(
    path: onBoarding,
    pageBuilder: (context, state) => NoTransitionPage(
      child: OnboardingScreen(),
    ),
  );
}