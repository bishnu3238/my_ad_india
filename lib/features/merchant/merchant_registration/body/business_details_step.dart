import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pack/constant/constant.dart';
import 'package:showcaseview/showcaseview.dart';
import '../core/form_validators.dart';
import '../core/registration_theme.dart';

class BusinessDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController shopNameController;
  final TextEditingController startYearController;
  final TextEditingController businessLocationController;
  final TextEditingController panCardController;
  final TextEditingController gstInController;

  const BusinessDetailsStep({
    super.key,
    required this.formKey,
    required this.shopNameController,
    required this.startYearController,
    required this.businessLocationController,
    required this.panCardController,
    required this.gstInController,
  });

  @override
  State<BusinessDetailsStep> createState() => _BusinessDetailsStepState();
}

class _BusinessDetailsStepState extends State<BusinessDetailsStep> {
  final GlobalKey _shopNameKey = GlobalKey();
  final GlobalKey _businessLocationKey = GlobalKey();
  final GlobalKey _panCardKey = GlobalKey();
  final GlobalKey _gstInKey = GlobalKey();

  void _showFieldShowcase(GlobalKey key) {
    setState(() {});
    ShowCaseWidget.of(context).startShowCase([key]);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Showcase(
                  key: _shopNameKey,
                  description: 'Enter your shop or company name as registered.',
                  child: Tooltip(
                    message: 'Your registered shop or company name.',
                    child: _buildShopNameField(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Showcase(
                  key: _businessLocationKey,
                  description: 'Enter the location/address of your business.',
                  child: Tooltip(
                    message: 'Your business location or address.',
                    child: _buildBusinessLocationField(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Showcase(
                  key: _panCardKey,
                  description: 'Enter your PAN Card number (optional).',
                  child: Tooltip(
                    message: 'Your PAN Card number (optional).',
                    child: _buildPanCardField(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Showcase(
                  key: _gstInKey,
                  description: 'Enter your GSTIN number (optional).',
                  child: Tooltip(
                    message: 'Your GSTIN number (optional).',
                    child: _buildGstInField(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopNameField() {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          child: CupertinoFormRow(
            prefix: const Icon(
              CupertinoIcons.building_2_fill,
              color: RegistrationTheme.primaryColor,
            ),
            child: CupertinoTextFormFieldRow(
              controller: widget.shopNameController,
              placeholder: 'Shop/Company Name *',
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              validator: FormValidators.requiredValidator,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
        Positioned(
          right: 25,
          child: IconButton(
            padding: edgeInsets,
            constraints: BoxConstraints(maxHeight: 5, maxWidth: 10),
            icon: const Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 22,
            ),
            tooltip: 'What is Shop/Company Name?',
            onPressed: () => _showFieldShowcase(_shopNameKey),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessLocationField() {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          child: CupertinoFormRow(
            prefix: const Icon(
              CupertinoIcons.location_solid,
              color: RegistrationTheme.primaryColor,
            ),
            child: CupertinoTextFormFieldRow(
              controller: widget.businessLocationController,
              placeholder: 'Business Location *',
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              validator: FormValidators.requiredValidator,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
        Positioned(
          right: 25,
          child: IconButton(
            padding: edgeInsets,
            constraints: BoxConstraints(maxHeight: 5, maxWidth: 10),
            icon: const Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 22,
            ),
            tooltip: 'What is Business Location?',
            onPressed: () => _showFieldShowcase(_businessLocationKey),
          ),
        ),
      ],
    );
  }

  Widget _buildPanCardField() {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          child: CupertinoFormRow(
            prefix: const Icon(
              CupertinoIcons.doc_text,
              color: RegistrationTheme.primaryColor,
            ),
            child: CupertinoTextFormFieldRow(
              controller: widget.panCardController,
              placeholder: 'PAN Card No (Optional)',
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              validator: FormValidators.panCardValidator,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  widget.panCardController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: widget.panCardController.selection,
                  );
                }
              },
            ),
          ),
        ),
        Positioned(
          right: 25,
          child: IconButton(
            padding: edgeInsets,
            constraints: BoxConstraints(maxHeight: 5, maxWidth: 10),
            icon: const Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 22,
            ),
            tooltip: 'What is PAN Card?',
            onPressed: () => _showFieldShowcase(_panCardKey),
          ),
        ),
      ],
    );
  }

  Widget _buildGstInField() {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          child: CupertinoFormRow(
            prefix: const Icon(
              CupertinoIcons.doc_plaintext,
              color: RegistrationTheme.primaryColor,
            ),
            child: CupertinoTextFormFieldRow(
              controller: widget.gstInController,
              placeholder: 'GSTIN No (Optional)',
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              validator: FormValidators.gstinValidator,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  widget.gstInController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: widget.gstInController.selection,
                  );
                }
              },
            ),
          ),
        ),
        Positioned(
          right: 25,
          child: IconButton(
            padding: edgeInsets,
            constraints: BoxConstraints(maxHeight: 5, maxWidth: 10),
            icon: const Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 22,
            ),
            tooltip: 'What is GSTIN?',
            onPressed: () => _showFieldShowcase(_gstInKey),
          ),
        ),
      ],
    );
  }
}
