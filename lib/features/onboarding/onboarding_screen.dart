import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/data/model/onboarding_page_model.dart';
import 'body/onboarding_background.dart';
import 'body/onboarding_items.dart';
import 'core/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, child) {
          return Stack(
            children: [
              // PageView for Onboarding Pages
              PageView.builder(
                controller: _pageController,
                itemCount: OnboardingPageModel.pages.length,
                onPageChanged: (index) {
                  onboardingProvider.setCurrentPage(index);
                },
                itemBuilder: (context, index) {
                  final page = OnboardingPageModel.pages[index];
                  return OnboardingPage(page: page);
                },
              ),

              // Top Right Skip Button
              Positioned(
                top: 50,
                right: 20,
                child: TextButton(
                  onPressed: () => _completeOnboarding(context),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                  ),
                ),
              ),
              OnboardingBackground(),

              // Bottom Navigation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: OnboardingPageModel.pages.length,
                        effect: const WormEffect(
                          dotColor: Colors.grey,
                          activeDotColor: Color(0xFFFF5722),
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                      ),

                      // Next/Done Button
                      ElevatedButton(
                        onPressed:
                            () =>
                                _handleNextOrDone(context, onboardingProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          onboardingProvider.currentPage ==
                                  OnboardingPageModel.pages.length - 1
                              ? 'Done'
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleNextOrDone(BuildContext context, OnboardingProvider provider) {
    if (provider.currentPage == OnboardingPageModel.pages.length - 1) {
      _completeOnboarding(context);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding(BuildContext context) {
    final onboardingProvider = context.read<OnboardingProvider>();
    onboardingProvider.completeOnboarding();
    context.go('/home');
  }
}
