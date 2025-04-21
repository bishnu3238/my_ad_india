import 'dart:developer' as dev;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/core/services/merchant_auth_service.dart';
import 'package:my_ad/features/merchant/merchant_registration/core/merchant_registration_view_model.dart';
import 'package:provider/provider.dart';
import '../core/registration_theme.dart';

class TimelineWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final Function(int)? onStepTapped;

  const TimelineWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Wrap the Row in a SingleChildScrollView to prevent overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, 'Personal', CupertinoIcons.person_fill),
                _buildConnector(0),
                _buildStepIndicator(
                  1,
                  'Business',
                  CupertinoIcons.building_2_fill,
                ),
                _buildConnector(1),
                _buildStepIndicator(2, 'Address', CupertinoIcons.location_fill),
                _buildConnector(2),
                _buildStepIndicator(
                  3,
                  'Account',
                  CupertinoIcons.creditcard_fill,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            minHeight: 6,
            backgroundColor: RegistrationTheme.primaryColor.withValues(
              alpha: 0.1,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              RegistrationTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            dev.log("hello ram");
            DependencyInjector.get<MerchantAuthService>().verifyPhoneNo(
              '9231665466',
            );
          },
          child: Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14,
              fontFamily: 'roboto',
              color: RegistrationTheme.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final bool isActive = currentStep >= step;
    final bool isCurrent = currentStep == step;

    return GestureDetector(
      onTap:
          isActive && !isCurrent && !isLoading && onStepTapped != null
              ? () => onStepTapped!(step)
              : null,
      child: Column(
        children: [
          Container(
            width: 36, // Slightly smaller to save space
            height: 36, // Slightly smaller to save space
            decoration: BoxDecoration(
              color:
                  isActive
                      ? RegistrationTheme.primaryColor
                      : RegistrationTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isCurrent
                        ? RegistrationTheme.primaryColor
                        : Colors.transparent,
                width: 2,
              ),
              boxShadow:
                  isCurrent
                      ? [
                        BoxShadow(
                          color: RegistrationTheme.primaryColor.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child: Icon(
                icon,
                color: isActive ? Colors.white : RegistrationTheme.primaryColor,
                size: 18, // Slightly smaller to save space
              ),
            ),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12, // Smaller font size
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color:
                  isCurrent
                      ? RegistrationTheme.primaryColor
                      : RegistrationTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int step) {
    final bool isActive = currentStep > step;

    return Container(
      width: 20, // Shorter connector to save space
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4), // Reduced margin
      decoration: BoxDecoration(
        color:
            isActive
                ? RegistrationTheme.primaryColor
                : RegistrationTheme.dividerColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
