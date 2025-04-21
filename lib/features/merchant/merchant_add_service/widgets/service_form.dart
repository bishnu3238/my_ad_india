import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';
import 'package:my_ad/features/merchant/merchant_add_service/widgets/basic_info_form.dart';
import 'package:my_ad/features/merchant/merchant_add_service/widgets/details_form.dart';
import 'package:my_ad/features/merchant/merchant_add_service/widgets/header_card.dart';
import 'package:my_ad/features/merchant/merchant_add_service/widgets/media_form.dart';
import 'package:my_ad/features/merchant/merchant_add_service/widgets/progress_indicator.dart';
import 'package:my_ad/features/merchant/merchant_add_service/widgets/review_form.dart';
import 'package:provider/provider.dart';

class ServiceForm extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const ServiceForm({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MerchantAddServiceProvider>(context);
    final currentStep = provider.currentStep;
    final isLoading = provider.isLoading;
    final errorMessage = provider.errorMessage;
    final planAccess = provider.planAccess;
    final isSubscriptionValid = provider.isSubscriptionValid;
    final canAddMoreServices = provider.canAddMoreServices;

    // Show loading indicator while initializing
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    // Show error message if initialization failed
    if (errorMessage != null && planAccess == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: CupertinoColors.systemRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load plan details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 24),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              onPressed: onBackPressed,
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    // Show subscription expired message
    if (!isSubscriptionValid) {
      return _buildSubscriptionExpiredView(context);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic dys) async {
        var navigator = GoRouter.of(context);
        if (didPop) return;
        final shouldPop = await _onWillPop(context, provider);
        if (shouldPop) navigator.pop();
      },
      child: Column(
        children: [
          // Header
          HeaderCard(
            title: _getStepTitle(currentStep),
            subtitle: 'Add a new service to your profile',
            icon: CupertinoIcons.add_circled,
            iconColor: CupertinoColors.activeBlue,
            onBackPressed: onBackPressed,
          ),

          const SizedBox(height: 16),

          // Progress Indicator
          StepProgressIndicator(currentStep: currentStep),

          const SizedBox(height: 16),

          // Form Steps
          Expanded(
            child: SingleChildScrollView(child: _buildCurrentStep(currentStep)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(ServiceFormStep step) {
    switch (step) {
      case ServiceFormStep.basicInfo:
        return const BasicInfoForm();
      case ServiceFormStep.details:
        return const DetailsForm();
      case ServiceFormStep.media:
        return const MediaForm();
      case ServiceFormStep.review:
        return const ReviewForm();
    }
  }

  String _getStepTitle(ServiceFormStep step) {
    switch (step) {
      case ServiceFormStep.basicInfo:
        return 'Add Service';
      case ServiceFormStep.details:
        return 'Service Details';
      case ServiceFormStep.media:
        return 'Add Media';
      case ServiceFormStep.review:
        return 'Review & Submit';
    }
  }

  Widget _buildSubscriptionExpiredView(BuildContext context) {
    return Column(
      children: [
        HeaderCard(
          title: 'Subscription Expired',
          subtitle: 'Your subscription has expired',
          icon: CupertinoIcons.exclamationmark_circle,
          iconColor: CupertinoColors.systemRed,
          onBackPressed: onBackPressed,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.calendar_badge_minus,
                      color: CupertinoColors.systemRed,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Subscription Expired',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your subscription has expired. Please renew your subscription to add more services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(8),
                        onPressed: () {
                          // Navigate to subscription plans screen
                          // This should be implemented based on your app's navigation
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'View Subscription Plans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      onPressed: onBackPressed,
                      child: const Text('Go Back to Dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop(
    BuildContext context,
    MerchantAddServiceProvider provider,
  ) async {
    final route = GoRouter.of(context);
    if (provider.currentStep == ServiceFormStep.basicInfo) {
      final shouldPop =
          await showCupertinoDialog<bool>(
            barrierDismissible: true,
            useRootNavigator: false,
            context: context,
            builder:
                (context) => CupertinoAlertDialog(
                  title: const Text('Confirm Exit'),
                  content: const Text(
                    'Going back will terminate the process and clear all data. Are you sure?',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () => route.pop(false),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('Confirm'),
                      onPressed: () {
                        provider.resetForm();
                        route.pop(true);
                      },
                    ),
                  ],
                ),
          ) ??
          false;

      return shouldPop;
    } else {
      provider.previousStep();
      return false;
    }
  }
}
