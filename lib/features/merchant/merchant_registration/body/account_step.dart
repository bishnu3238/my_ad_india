import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:my_ad/core/services/service.dart';
import 'package:my_ad/features/terms/core/terms_and_conditiaons_route.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import '../../../../core/data/model/model.dart';
import '../core/form_validators.dart';
import '../core/merchant_registration_view_model.dart';
import '../core/registration_theme.dart';

class AccountStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController referralController;
  final String selectedPlan;
  final Function(String?) onPlanChanged;
  final List<SubscriptionPlanModel> plans;
  final bool isTermsAccepted;
  final void Function(bool?) onTermsAcceptedChanged;

  // Tell which plan to show initially (by id)
  final String primaryPlanId;

  const AccountStep({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.referralController,
    required this.selectedPlan,
    required this.onPlanChanged,
    required this.plans,
    required this.isTermsAccepted,
    required this.onTermsAcceptedChanged,
    required this.primaryPlanId, // <-- new
  });

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showAllPlans = false;

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
          _buildPlanSelector(context),
          const SizedBox(height: 24),
          _buildTermsAndConditionsCheckbox(),
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
                    onTap:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
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
                    onTap:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
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

  /// Display either only the primary plan or all plans after clicking 'View More'
  Widget _buildPlanSelector(BuildContext context) {
    final showError = widget.selectedPlan.isEmpty && widget.plans.isNotEmpty;

    List<SubscriptionPlanModel> sortedPlans = List.from(widget.plans);
    sortedPlans.sort((a, b) => a.planName.compareTo(b.planName));

    final primaryPlan = sortedPlans.firstWhere(
      (plan) => plan.id == widget.primaryPlanId,
      orElse:
          () =>
              sortedPlans.isNotEmpty
                  ? sortedPlans[0]
                  : SubscriptionPlanModel.empty(),
    );

    List<SubscriptionPlanModel> displayedPlans =
        (_showAllPlans || sortedPlans.length <= 1)
            ? sortedPlans
            : (primaryPlan.isValid ? [primaryPlan] : []);

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
        else ...[
          for (final plan in displayedPlans) _buildPlanOption(context, plan),

          /// TODO: Uncomment it when clint is ready to show all the plans in this app;
          // if (sortedPlans.length > 1 && !_showAllPlans)
          //   Container(
          //     alignment: Alignment.centerLeft,
          //     child: Padding(
          //       padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
          //       child: TextButton.icon(
          //         icon: const Icon(CupertinoIcons.eye, size: 19),
          //         label: const Text(
          //           'View More',
          //           style: TextStyle(fontWeight: FontWeight.w600),
          //         ),
          //         onPressed: () {
          //           setState(() {
          //             _showAllPlans = true;
          //           });
          //         },
          //       ),
          //     ),
          //   ),
        ],
        if (showError)
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

  /// Enhanced single plan option widget with new design requirements and details modal.
  Widget _buildPlanOption(BuildContext context, SubscriptionPlanModel plan) {
    final isSelected = widget.selectedPlan == plan.id;
    context.read<MerchantRegistrationViewModel>().formState.selectedPlan =
        plan.id; // Update the selected plan in the form state

    return GestureDetector(
      onTap: () => widget.onPlanChanged(plan.id),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: isSelected ? 2 : 0,
        color:
            isSelected
                ? context.colorScheme.primaryFixed
                : CupertinoColors.systemGrey6,
        child: Container(
          margin: 12.bottom,
          // Main visual box
          padding: 16.symmetricHV(18),
          decoration: BoxDecoration(
            borderRadius: 12.circular,
            border: Border.all(
              color:
                  isSelected
                      ? RegistrationTheme.primaryColor
                      : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio circle icon
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 22,
                  height: 22,
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
                            size: 15,
                            color: CupertinoColors.white,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 16),
              // Plan infos
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.planName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,

                            color:
                                isSelected
                                    ? RegistrationTheme.primaryColor
                                    : RegistrationTheme.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AutoSizeText.rich(
                          TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text:
                                    plan.offer == '0'
                                        ? 'Free '
                                        : '\u20b9${plan.offer} ',
                                style: GoogleFonts.monda(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plan.planRate.toString() !=
                                  plan.offer.toString())
                                TextSpan(
                                  text: '\u20b9${plan.planRate}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          style: GoogleFonts.poppins(),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.offer == '0'
                              ? 'Validity: ${plan.validity} days +  free offer 30 days'
                              : 'Validity: ${plan.validity} days',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtils().getFontSize(12),
                          ),
                        ),
                      ],
                    ),

                    // Professional View button
                    Positioned(
                      right: 10,
                      top: 0,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: OutlinedButton.icon(
                          icon: const Icon(CupertinoIcons.eye, size: 15),
                          label: const Text(
                            'View',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RegistrationTheme.primaryColor,
                            side: BorderSide(
                              color: RegistrationTheme.primaryColor,
                              width: 1.3,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () => _showPlanDetailsModal(context, plan),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal Sheet for Plan Details
  Future<void> _showPlanDetailsModal(
    BuildContext context,
    SubscriptionPlanModel plan,
  ) async {
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 27),
            child: SingleChildScrollView(child: _PlanDetailsView(plan: plan)),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to show plan details.')),
      );
    }
  }

  Widget _buildTermsAndConditionsCheckbox() {
    return Material(
      borderRadius: 12.circular,
      child: Row(
        children: [
          Checkbox(
            value: widget.isTermsAccepted,
            onChanged: widget.onTermsAcceptedChanged,
          ),
          const Expanded(child: Text("I accept the Terms and Conditions.")),
          IconButton(
            onPressed: () => context.push(TermsRoute.merchantRegistrationTerms),
            icon: Icon(FontAwesomeIcons.circleQuestion),
          ),
        ],
      ),
    );
  }
}

// ---- PLAN DETAILS MODULAR WIDGET ----
class _PlanDetailsView extends StatelessWidget {
  final SubscriptionPlanModel plan;
  const _PlanDetailsView({required this.plan});

  @override
  Widget build(BuildContext context) {
    // Fallback/edge cases for data
    final shopPhoto =
        'true'; // plan.shopPhotoUrl ?? plan.individualPhotoUrl ?? '';
    final hasReview = true; //(plan.review ?? '').isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        Text(
          'Plan Benefits',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        const SizedBox(height: 13),
        const Divider(thickness: 1.25),
        const SizedBox(height: 11),
        ..._buildBullets(context, plan, shopPhoto, hasReview),
      ],
    );
  }

  List<Widget> _buildBullets(
    BuildContext context,
    SubscriptionPlanModel plan,
    String shopPhoto,
    bool hasReview,
  ) {
    List<Widget> items = [
      _bullet(
        context,
        'Plan Name : ${plan.planName}',
        style: GoogleFonts.poppins(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        showBullet: false,
        trailing: ClipRRect(
          borderRadius: 50.circular,
          child: ImageView(
            source: ImageSource.network,
            path: plan.fullImageUrl,
            shape: ImageShape.circle,
            height: 40,
            width: 40,
          ),
        ),
      ),
      _bullet(context, "Service details", trailing: Container()),
      _bullet(
        context,
        "Show PhoneNo to user ${context.read<MerchantRegistrationViewModel>().formState.mobileController.text}",
      ),
      _bullet(
        context,
        "Show Address to user ${context.read<MerchantRegistrationViewModel>().formState.addressController.text}",
      ),
      _bullet(context, "Write description (30 Characters)"),
      if (shopPhoto.isNotEmpty)
        _bullet(
          context,
          "Upload Shop (1) & Individual Photo (1)",
          trailing: CircleAvatar(
            radius: 23,
            backgroundColor: Colors.grey[100],
            backgroundImage: NetworkImage(shopPhoto),
            child: const Icon(Icons.image, size: 22),
          ),
        ),
      // For bullet count: review (1 maximum shown)
      // if (hasReview)
      _bullet(
        context,
        plan.offer == '0'
            ? 'Validity: ${plan.validity} days +  free offer 30 days'
            : 'Validity: ${plan.validity} days',
      ),
      // _bullet(
      //   context,
      //   "Description: ${plan.description.length > 30 ? '${plan.description.substring(0, 30)}...' : (plan.description)}",
      // ),
    ];
    return items;
  }

  Widget _bullet(
    BuildContext context,
    String text, {
    bool showBullet = true,
    TextStyle? style,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showBullet
              ? Text(
                "\u2022 ",
                style: TextStyle(
                  fontSize: 21,
                  color: Colors.black87,
                  height: 1.21,
                ),
              )
              : const SizedBox(),
          Expanded(
            child: Text(
              text,
              style:
                  style ??
                  GoogleFonts.poppins(
                    fontSize: 15.2,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
