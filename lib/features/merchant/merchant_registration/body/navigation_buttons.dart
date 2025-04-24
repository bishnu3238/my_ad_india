import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/registration_theme.dart';

class NavigationButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onSubmit;
  final bool isLoading;

  const NavigationButtons({
    super.key,
    required this.currentStep,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            _buildBackButton()
          else
            const SizedBox(width: 100),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // color: RegistrationTheme.secondaryButtonColor,
      borderRadius: BorderRadius.circular(12),
      onPressed: isLoading ? null : onPrevious,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.arrow_left,
            // color: RegistrationTheme.primaryTextColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Back',
            style: TextStyle(
              color: RegistrationTheme.primaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final bool isLastStep = currentStep == 4;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: RegistrationTheme.primaryColor,
      borderRadius: BorderRadius.circular(12),
      onPressed: isLoading ? null : (isLastStep ? onSubmit : onNext),
      child:
          isLoading
              ? const CupertinoActivityIndicator(color: Colors.white)
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastStep ? 'Submit' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (!isLastStep) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ],
              ),
    );
  }
}
