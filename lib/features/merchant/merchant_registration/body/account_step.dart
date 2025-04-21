import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/constant/constant.dart';
import '../../../../core/data/model/model.dart';
import '../core/form_validators.dart';
import '../core/registration_theme.dart';

class AccountStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController referralController;
  final String selectedPlan;
  final Function(String?) onPlanChanged;
  final List<SubscriptionPlanModel> plans;

  const AccountStep({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.referralController,
    required this.selectedPlan,
    required this.onPlanChanged,
    required this.plans,
  });

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 16),
          _buildReferralField(),
          const SizedBox(height: 24),
          _buildPlanSelector(),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              CupertinoIcons.lock,
              color: RegistrationTheme.primaryColor,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                CupertinoTextFormFieldRow(
                  controller: widget.passwordController,
                  placeholder: 'Password *',
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  validator: FormValidators.passwordValidator,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: RegistrationTheme.bodyMedium(context: context),
                ),
                Positioned(
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                      color: RegistrationTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              CupertinoIcons.lock_shield,
              color: RegistrationTheme.primaryColor,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                CupertinoTextFormFieldRow(
                  controller: widget.confirmPasswordController,
                  placeholder: 'Confirm Password *',
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  validator:
                      (value) => FormValidators.passwordMatchValidator(
                        value,
                        widget.passwordController.text,
                      ),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: RegistrationTheme.bodyMedium(context: context),
                ),
                Positioned(
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                      color: RegistrationTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralField() {
    return Material(
      borderRadius: BorderRadius.circular(10),

      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              CupertinoIcons.person_crop_circle_badge_plus,
              color: RegistrationTheme.primaryColor,
            ),
          ),
          Expanded(
            child: CupertinoTextFormFieldRow(
              controller: widget.referralController,
              placeholder: 'Referral Code (Optional)',
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide.none),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: RegistrationTheme.bodyMedium(context: context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Select Subscription Plan *',
            style: RegistrationTheme.bodyMedium(
              context: context,
              color: RegistrationTheme.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (widget.plans.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No subscription plans available',
                style: TextStyle(color: RegistrationTheme.secondaryTextColor),
              ),
            ),
          )
        else
          ...widget.plans.map((plan) => _buildPlanOption(plan)),

        if (widget.selectedPlan.isEmpty && widget.plans.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 4.0),
            child: Text(
              'Please select a subscription plan',
              style: TextStyle(
                color: RegistrationTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanOption(SubscriptionPlanModel plan) {
    final isSelected = widget.selectedPlan == plan.id;

    return GestureDetector(
      onTap: () => widget.onPlanChanged(plan.id),
      child: Material(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? RegistrationTheme.primaryColor.withValues(alpha: 0.1)
                    : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? RegistrationTheme.primaryColor
                      : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected
                          ? RegistrationTheme.primaryColor
                          : CupertinoColors.systemGrey5,
                  border: Border.all(
                    color:
                        isSelected
                            ? RegistrationTheme.primaryColor
                            : CupertinoColors.systemGrey3,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          CupertinoIcons.checkmark_alt,
                          size: 16,
                          color: CupertinoColors.white,
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.planName,
                      style: RegistrationTheme.titleMedium(
                        context,
                        isSelected
                            ? RegistrationTheme.primaryColor
                            : RegistrationTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${plan.validity} days',
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 2),
                    AutoSizeText.rich(
                      style: GoogleFonts.poppins(),

                      TextSpan(
                        text: 'Price:',
                        children: [
                          TextSpan(
                            text: '${Currency.rupeeSymbol}${plan.offer} ',
                          ),
                          TextSpan(
                            text: '₹${plan.planRate}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Services: ${plan.numberOfServices}',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color:
                    isSelected
                        ? RegistrationTheme.primaryColor
                        : RegistrationTheme.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
