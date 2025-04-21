import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/form_validators.dart';
import '../core/registration_theme.dart';

class BusinessDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController shopNameController;
  final TextEditingController startYearController;
  final TextEditingController businessLocationController;
  final TextEditingController panCardController;
  final TextEditingController gstinController;

  const BusinessDetailsStep({
    super.key,
    required this.formKey,
    required this.shopNameController,
    required this.startYearController,
    required this.businessLocationController,
    required this.panCardController,
    required this.gstinController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShopNameField(),
          const SizedBox(height: 16),
          _buildStartYearField(context),
          const SizedBox(height: 16),
          _buildBusinessLocationField(),
          const SizedBox(height: 16),
          _buildPanCardField(),
          const SizedBox(height: 16),
          _buildGstinField(),
        ],
      ),
    );
  }

  Widget _buildShopNameField() {
    return Material(
      borderRadius: BorderRadius.circular(10),

      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.building_2_fill,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(
          controller: shopNameController,
          placeholder: 'Shop/Company Name *',
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          validator: FormValidators.requiredValidator,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // style: RegistrationTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildStartYearField(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.calendar,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(
          controller: startYearController,
          placeholder: 'Business Start Year *',
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          validator: FormValidators.yearValidator,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          // style: RegistrationTheme.bodyMedium,
          prefix: GestureDetector(
            onTap: () => _showYearPicker(startYearController, context),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                CupertinoIcons.calendar_badge_plus,
                color: RegistrationTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showYearPicker(TextEditingController controller, BuildContext context) {
    final int currentYear = DateTime.now().year;
    final int initialYear = int.tryParse(controller.text) ?? currentYear;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: initialYear - 1900,
              ),
              onSelectedItemChanged: (int selectedItem) {
                final year = selectedItem + 1900;
                controller.text = year.toString();
              },
              children: List<Widget>.generate((currentYear - 1900) + 1, (
                int index,
              ) {
                return Center(
                  child: Text(
                    (1900 + index).toString(),
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBusinessLocationField() {
    return Material(
      borderRadius: BorderRadius.circular(10),

      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.location_solid,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(
          controller: businessLocationController,
          placeholder: 'Business Location *',
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          validator: FormValidators.requiredValidator,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // style: RegistrationThe0me.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildPanCardField() {
    return Material(
      borderRadius: BorderRadius.circular(10),

      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.doc_text,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(
          controller: panCardController,
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
          // style: RegistrationTheme.bodyMedium,
          onChanged: (value) {
            if (value.isNotEmpty) {
              panCardController.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: panCardController.selection,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGstinField() {
    return Material(
      borderRadius: BorderRadius.circular(10),

      child: CupertinoFormRow(
        prefix: const Icon(
          CupertinoIcons.doc_plaintext,
          color: RegistrationTheme.primaryColor,
        ),
        child: CupertinoTextFormFieldRow(
          controller: gstinController,
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
              gstinController.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: gstinController.selection,
              );
            }
          },
        ),
      ),
    );
  }
}
