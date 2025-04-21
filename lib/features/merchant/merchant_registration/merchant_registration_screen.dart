import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'body/navigation_buttons.dart';
import 'body/timeline_widget.dart';
import 'body/personal_info_step.dart';
import 'body/business_details_step.dart';
import 'body/address_step.dart';
import 'body/account_step.dart';
import 'core/merchant_registration_view_model.dart';
import 'core/registration_form_state.dart';
import 'core/registration_theme.dart';

class MerchantRegistrationScreen extends StatefulWidget {
  const MerchantRegistrationScreen({super.key});

  @override
  State<MerchantRegistrationScreen> createState() =>
      _MerchantRegistrationScreenState();
}

class _MerchantRegistrationScreenState
    extends State<MerchantRegistrationScreen> {
  // final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  // final GlobalKey<FormState> _businessDetailsFormKey = GlobalKey<FormState>();
  // final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  // final GlobalKey<FormState> _accountFormKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;

  // late final RegistrationFormState _formState;

  @override
  void initState() {
    super.initState();
    // _formState = RegistrationFormState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MerchantRegistrationViewModel>(
        context,
        listen: false,
      );
      viewModel.initializeRegistration();
    });
  }

  // @override
  // void dispose() {
  //   // _formState.dispose();
  //   super.dispose();
  // }

  bool _validateCurrentStep() {
    final viewModel = Provider.of<MerchantRegistrationViewModel>(
      context,
      listen: false,
    );

    return viewModel.validateCurrentStep();
  }
  // switch (_currentStep) {
  //   case 0:
  //     return _personalInfoFormKey.currentState?.validate() ?? false;
  //   case 1:
  //     return _businessDetailsFormKey.currentState?.validate() ?? false;
  //   case 2:
  //     return _addressFormKey.currentState?.validate() ?? false;
  //   case 3:
  //     return _accountFormKey.currentState?.validate() ?? false;
  //   default:
  //     return false;
  // }
  // }

  void _goToNextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < 3) {
          _currentStep++;
        }
      });
    }
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _submitRegistration() async {
    if (_validateCurrentStep()) {
      setState(() {
        _isLoading = true;
      });

      final viewModel = Provider.of<MerchantRegistrationViewModel>(
        context,
        listen: false,
      );
      dev.log("hello");

      await viewModel.merchantRegistration(context);

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Registration Successful'),
            content: const Text(
              'Your merchant account has been created successfully. You can now login to access your dashboard.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Login'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantRegistrationViewModel>(
      builder: (context, viewModel, _) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Merchant Registration'),
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
                  TimelineWidget(
                    currentStep: _currentStep,
                    totalSteps: 4,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  _buildCurrentStep(viewModel),
                  const SizedBox(height: 24),
                  NavigationButtons(
                    currentStep: _currentStep,
                    onPrevious: _goToPreviousStep,
                    onNext: _goToNextStep,
                    onSubmit: _submitRegistration,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep(MerchantRegistrationViewModel viewModel) {
    switch (_currentStep) {
      case 0:
        return PersonalInfoStep(
          formKey: viewModel.formState.personalInfoFormKey,
          nameController: viewModel.formState.nameController,
          emailController: viewModel.formState.emailController,
          mobileController: viewModel.formState.mobileController,
          selectedGender: viewModel.selectedGender,
          onGenderChanged: (gender) {
            if (gender != null) {
              setState(() {
                viewModel.selectedGender = gender;
              });
            }
          },
          onPhoneVerified: (number) => viewModel.verifyMobile(),
        ).animate().fadeIn(duration: 300.ms);

      case 1:
        return BusinessDetailsStep(
          formKey: viewModel.formState.businessDetailsFormKey,
          shopNameController: viewModel.formState.shopNameController,
          startYearController: viewModel.formState.startYearController,
          businessLocationController:
              viewModel.formState.businessLocationController,
          panCardController: viewModel.formState.panCardController,
          gstinController: viewModel.formState.gstinController,
        ).animate().fadeIn(duration: 300.ms);

      case 2:
        return AddressStep(
          formKey: viewModel.formState.addressFormKey,
          addressController: viewModel.formState.addressController,
          pincodeController: viewModel.formState.pincodeController,
          selectedState: viewModel.selectedState,
          onStateChanged: (state) {
            if (state != null) {
              setState(() {
                viewModel.selectedState = state;
              });
            }
          },
          states: viewModel.states,
        ).animate().fadeIn(duration: 300.ms);

      case 3:
        return AccountStep(
          formKey: viewModel.formState.accountFormKey,
          passwordController: viewModel.formState.passwordController,
          confirmPasswordController:
              viewModel.formState.confirmPasswordController,
          referralController: viewModel.formState.referralController,
          selectedPlan: viewModel.selectedPlan,
          onPlanChanged: (plan) {
            if (plan != null) {
              setState(() {
                viewModel.selectedPlan = plan;
              });
            }
          },
          plans: viewModel.plans,
        ).animate().fadeIn(duration: 300.ms);

      default:
        return const SizedBox.shrink();
    }
  }
}
