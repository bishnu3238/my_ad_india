import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_ad/features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';
import 'package:provider/provider.dart';

class DetailsForm extends StatelessWidget {
  const DetailsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme =  Theme.of(context).colorScheme;
    final provider = Provider.of<MerchantAddServiceProvider>(context);
    final canAddMoreServices = provider.canAddMoreServices;
    final maxDescriptionLength = provider.maxDescriptionLength;
    final canWriteDescription = provider.canWriteDescription;
    final maxOfferLength = provider.maxOfferLength;
    final canShowOffers = provider.canShowOffers;
    final canShowPhoneNumber = provider.canShowPhoneNumber;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              semanticsLabel: 'Service Details Form',
            ),
            const SizedBox(height: 16),

            // Description TextField
            if (canWriteDescription) ...[
              _buildLabel(
                'Description',
                maxDescriptionLength > 0
                    ? '$maxDescriptionLength characters max'
                    : null,
              ),
              _buildTextArea(
                controller: provider.descriptionController,
                placeholder: 'Enter service description',
                maxLength:
                    maxDescriptionLength > 0 ? maxDescriptionLength : null,
                enabled: canAddMoreServices,
                semanticsLabel: 'Description input field',
              ),
            ],
            const SizedBox(height: 16),

            // Offers TextField (conditional)
            if (canShowOffers) ...[
              _buildLabel(
                'Special Offers',
                maxOfferLength > 0 ? '$maxOfferLength characters max' : null,
              ),
              _buildTextArea(
                controller: provider.offersController,
                placeholder: 'Enter special offers or discounts',
                maxLength: maxOfferLength > 0 ? maxOfferLength : null,
                enabled: canAddMoreServices,
                semanticsLabel: 'Offers input field',
              ),
              const SizedBox(height: 16),
            ],

            // Address TextField
            _buildLabel('Address'),
            CupertinoTextField(
              controller: provider.addressController,
              placeholder: 'Enter service address',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              enabled: canAddMoreServices,
              // semanticsLabel: 'Address input field',
            ),
            const SizedBox(height: 16),

            // Show Phone Number Toggle (conditional)
            if (canShowPhoneNumber)
              _buildToggleOption(
                label: 'Show Phone Number',
                value: provider.showPhoneNumber,
                onChanged:
                    canAddMoreServices
                        ? (value) => provider.setShowPhoneNumber(value)
                        : null,
                description: 'Allow customers to see your phone number',
                semanticsLabel: 'Show phone number toggle',
              ),

            // Enable Chat Toggle
            _buildToggleOption(
              label: 'Enable Chat',
              value: provider.enableChat,
              onChanged:
                  canAddMoreServices
                      ? (value) => provider.setEnableChat(value)
                      : null,
              description: 'Allow customers to chat with you',
              semanticsLabel: 'Enable chat toggle',
            ),

            const SizedBox(height: 24),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () => provider.previousStep(),
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                    onPressed:
                        canAddMoreServices
                            ? () => provider.nextStep(context)
                            : null,
                    child:   Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        color:  theme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, [String? helperText]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (helperText != null)
            Text(
              helperText,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String placeholder,
    int? maxLength,
    bool enabled = true,
    required String semanticsLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          maxLines: 5,
          minLines: 3,
          maxLength: maxLength,
          enabled: enabled,
          // semanticsLabel: semanticsLabel,
        ),
        if (maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${controller.text.length}/$maxLength',
              style: TextStyle(
                fontSize: 12,
                color:
                    controller.text.length > maxLength
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemGrey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required String description,
    required String semanticsLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: CupertinoColors.activeBlue,
            // semanticsLabel: semanticsLabel,
          ),
        ],
      ),
    );
  }
}
