import 'dart:developer' as dev;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pack/constant/duration.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:guide_bubble/guide_bubble.dart';
// Add shared_preferences for persistence
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/model/model.dart';
import 'body/category_and_service_step.dart';
import 'body/navigation_buttons.dart';
import 'body/timeline_widget.dart';
import 'body/personal_info_step.dart';
import 'body/business_details_step.dart';
import 'body/address_step.dart';
import 'body/account_step.dart';
import 'core/merchant_registration_view_model.dart';
import 'core/registration_theme.dart';

class MerchantRegistrationScreen extends StatefulWidget {
  const MerchantRegistrationScreen({super.key});

  @override
  State<MerchantRegistrationScreen> createState() =>
      _MerchantRegistrationScreenState();
}

class _MerchantRegistrationScreenState
    extends State<MerchantRegistrationScreen> {
  final GlobalKey _timelineKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _personalInfoKey = GlobalKey();
  final GlobalKey _businessKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _accountKey = GlobalKey();
  final GlobalKey _navButtonKey = GlobalKey();

  bool _showcaseStarted = false;
  bool _showcaseShouldStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<MerchantRegistrationViewModel>();
      viewModel.initializeRegistration();

      // Only set the flag here, do not call showShowCase(context)
      final prefs = await SharedPreferences.getInstance();
      final seenShowcase = prefs.getBool('seen_merchant_showcase') ?? false;
      if (!seenShowcase) {
        setState(() => _showcaseShouldStart = true);
        await prefs.setBool('seen_merchant_showcase', true);
      }
    });
  }

  void showShowCase(BuildContext ctx) {
    if (!_showcaseStarted) {
      setState(() => _showcaseStarted = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(ctx).startShowCase([_timelineKey, _navButtonKey]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (ctx) {
        // Start showcase only if needed and not already started, using ctx
        if (_showcaseShouldStart && !_showcaseStarted) {
          Future.delayed(twoSecond, () => showShowCase(ctx));
        }
        return Consumer<MerchantRegistrationViewModel>(
          builder: (context, viewModel, _) {
            Future.delayed(twoSecond, () => showShowCase(context));

            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: const Text('Merchant Registration'),

                backgroundColor: RegistrationTheme.primaryColor,
                brightness: Brightness.dark,
              ),
              backgroundColor: CupertinoColors.systemGroupedBackground,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Showcase(
                        key: _timelineKey,
                        description: 'See your progress.',
                        child: TimelineWidget(
                          currentStep: viewModel.currentStep,
                          totalSteps: 5,
                          isLoading: viewModel.isLoading,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCurrentStep(viewModel),
                      const SizedBox(height: 24),
                      Showcase(
                        key: _navButtonKey,
                        description: 'Complete your account setup and submit.',
                        child: NavigationButtons(
                          currentStep: viewModel.currentStep,
                          onPrevious: viewModel.goToPreviousStep,
                          onNext: () => viewModel.goToNextStep(context),
                          onSubmit:
                              !viewModel.formState.isTermsAccepted
                                  ? null
                                  : () =>
                                      viewModel.merchantRegistration(context),
                          isLoading: viewModel.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentStep(MerchantRegistrationViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return CategoryAndServicesStep(
          formKey: viewModel.formState.categoryAndServicesFormKey,
          selectedCategoryId: viewModel.formState.selectedCategory,
          selectedServiceId: viewModel.formState.selectedService,
          onCategorySelected: (CategoryModel? category) {
            if (category == null) return;
            viewModel.formState.selectCategory = category.id;
            viewModel.formState.selectService = '';
          },
          onServicesSelected: (ServiceModel? services) {
            if (services == null) return;
            viewModel.formState.selectService = services.id;
          },
          resetForm: () => viewModel.formState.clearCategoryAndServices(),
          // Add tooltips inside CategoryAndServicesStep for each field
        ).animate().fadeIn(duration: 300.ms);
      case 1:
        return PersonalInfoStep(
          formKey: viewModel.formState.personalInfoFormKey,
          nameController: viewModel.formState.nameController,
          emailController: viewModel.formState.emailController,
          mobileController: viewModel.formState.mobileController,
          selectedGender: viewModel.formState.gender,
          onGenderChanged: (gender) {
            if (gender != null) {
              setState(() {
                viewModel.formState.gender = gender;
              });
            }
          },
          onPhoneVerified: (number) => viewModel.verifyMobile(),
          // Add tooltips inside PersonalInfoStep for each field
        ).animate().fadeIn(duration: 300.ms);
      case 2:
        return BusinessDetailsStep(
          formKey: viewModel.formState.businessDetailsFormKey,
          shopNameController: viewModel.formState.shopNameController,
          startYearController: viewModel.formState.startYearController,
          businessLocationController:
              viewModel.formState.businessLocationController,
          panCardController: viewModel.formState.panCardController,
          gstInController: viewModel.formState.gstinController,
          // Add tooltips inside BusinessDetailsStep for each field
        ).animate().fadeIn(duration: 300.ms);
      case 3:
        return AddressStep(
          formKey: viewModel.formState.addressFormKey,
          addressController: viewModel.formState.addressController,
          pincodeController: viewModel.formState.pincodeController,
          selectedState: viewModel.formState.selectedState,
          onStateChanged: (state) {
            if (state != null) {
              setState(() {
                viewModel.formState.selectedState = state;
              });
            }
          },
          states: viewModel.states,
          // Add tooltips inside AddressStep for each field
        ).animate().fadeIn(duration: 300.ms);
      case 4:
        return AccountStep(
          formKey: viewModel.formState.accountFormKey,
          passwordController: viewModel.formState.passwordController,
          confirmPasswordController:
              viewModel.formState.confirmPasswordController,
          referralController: viewModel.formState.referralController,
          selectedPlan: viewModel.formState.selectedPlan,
          onPlanChanged: (plan) {
            if (plan != null) {
              setState(() => viewModel.formState.selectedPlan = plan);
            }
          },
          plans: viewModel.plans,
          isTermsAccepted: viewModel.formState.isTermsAccepted,
          onTermsAcceptedChanged: (val) {
            setState(() {
              viewModel.formState.isTermsAccepted = val ?? false;
            });
          },
          primaryPlanId: '4',
          // Add tooltips inside AccountStep for each field
        ).animate().fadeIn(duration: 300.ms);
      default:
        return const SizedBox.shrink();
    }
  }
}
