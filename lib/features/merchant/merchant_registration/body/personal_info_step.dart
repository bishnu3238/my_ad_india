import 'dart:developer' as dev;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/extensions/contextx.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import '../core/form_validators.dart';
import '../core/merchant_registration_view_model.dart';
import '../core/registration_theme.dart';

class PersonalInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final String selectedGender;
  final Function(String?) onGenderChanged;
  final Function(String?) onPhoneVerified;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.mobileController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onPhoneVerified,
  });

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildMobileField(context),
          const SizedBox(height: 16),
          _buildGenderSelector(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.person_fill,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(

          controller: widget.nameController,
          placeholder: 'Full Name *',
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          validator: FormValidators.requiredValidator,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: RegistrationTheme.bodyMedium(context: context),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.mail_solid,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(
          controller: widget.emailController,
          placeholder: 'Email Address (optional)',
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          validator: FormValidators.emailValidator,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: RegistrationTheme.bodyMedium(context: context),
        ),
      ),
    );
  }

  Widget _buildMobileField(BuildContext context) {
    return Consumer<MerchantRegistrationViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Material(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Column(
                children: [
                  CupertinoFormRow(
                    prefix: const Icon(
                      CupertinoIcons.phone_fill,
                      color: RegistrationTheme.primaryColor,
                    ),
                    child: CupertinoTextFormFieldRow(
                      controller: widget.mobileController,
                      placeholder: 'Mobile Number *',
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      validator: FormValidators.mobileValidator,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: RegistrationTheme.bodyMedium(context: context),
                      prefix: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            color: RegistrationTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      onChanged: (value) {
                        if (value.length == 10) widget.onPhoneVerified(value);

                        if (value.length < 10) {
                          viewModel.formState.isMobileVerified = false;
                          viewModel.formState.isVerifyingMobile = false;
                          viewModel.formState.mobileAvailabilityMessage = '';
                        }
                        setState(() {});
                      },
                      onFieldSubmitted: widget.onPhoneVerified,

                      // onSaved: widget.onPhoneVerified,
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.formState.isVerifyingMobile)
              const Positioned(
                right: 25,
                top: 25,
                child: CupertinoActivityIndicator(
                  radius: 10,
                  color: RegistrationTheme.primaryColor,
                ),
              ),
            if (viewModel.formState.isMobileVerified &&
                !viewModel.formState.isVerifyingMobile)
              const Positioned(
                right: 25,
                top: 25,
                child: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: RegistrationTheme.accentColor,
                  size: 20,
                ),
              ),
            if (!viewModel.formState.isMobileVerified &&
                !viewModel.formState.isVerifyingMobile)
              const Positioned(
                right: 25,
                top: 25,
                child: Icon(
                  CupertinoIcons.info,
                  color: RegistrationTheme.errorColor,
                  size: 20,
                ),
              ),
            // Add a tooltip to the icon
            Positioned(
              right: 25,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: AutoSizeText(
                  widget.mobileController.text.length < 10
                      ? ''
                      : viewModel.formState.isVerifyingMobile
                      ? 'Phone no checking ...'
                      : viewModel.formState.isMobileVerified
                      ? ''
                      : 'Phone number is already exists*',
                  style: GoogleFonts.poppins(
                    fontSize: ScreenUtils().getFontSize(8),
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenderSelector() {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
            child: Text(
              'Select Gender *',
              style: RegistrationTheme.bodyMedium(
                context: context,
                color: RegistrationTheme.secondaryTextColor,
              ),
            ),
          ),
          // Use a segmented control for gender selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CupertinoSlidingSegmentedControl<String>(
              padding: EdgeInsets.symmetric(horizontal: 12),
              groupValue:
                  widget.selectedGender.isEmpty ? null : widget.selectedGender,
              children: {
                'Male': _buildSegmentContent(
                  'Male',
                  CupertinoIcons.person_fill,
                ),
                'Female': _buildSegmentContent(
                  'Female',
                  CupertinoIcons.person_fill,
                ),
                'Other': _buildSegmentContent(
                  'Other',
                  CupertinoIcons.person_2_fill,
                ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  widget.onGenderChanged(value);
                }
              },
              thumbColor: RegistrationTheme.primaryColor,
              backgroundColor: CupertinoColors.systemGrey6,
            ),
          ),
          // Display validation error if needed
          if (widget.selectedGender.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 4.0, bottom: 8),
              child: Text(
                'Please select a gender',
                style: TextStyle(
                  color: RegistrationTheme.errorColor,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentContent(String text, IconData icon) {
    final isSelected = widget.selectedGender == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? Colors.white
                    : RegistrationTheme.secondaryTextColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
                  isSelected
                      ? Colors.white
                      : RegistrationTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
