import 'dart:developer' as dev;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_ad/core/data/model/product/category_model.dart';
import 'package:my_ad/core/data/model/product/service_model.dart';
import 'package:my_ad/core/data/model/product/sub_category_model.dart';
import 'package:my_ad/core/domain/data_store/category_store.dart';
import 'package:my_ad/core/domain/data_store/service_store.dart';
import 'package:my_ad/core/domain/data_store/sub_category_store.dart';
import 'package:my_ad/features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:provider/provider.dart';

import 'details_form.dart';

class BasicInfoForm extends StatelessWidget {
  const BasicInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Consumer<MerchantAddServiceProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context).colorScheme;
        final provider = Provider.of<MerchantAddServiceProvider>(context);
        final canAddMoreServices = provider.canAddMoreServices;
        final maxDescriptionLength = provider.maxDescriptionLength;
        final canWriteDescription = provider.canWriteDescription;
        final maxOfferLength = provider.maxOfferLength;
        final canShowOffers = provider.canShowOffers;
        final canShowPhoneNumber = provider.canShowPhoneNumber;
        // final categoryStore = Provider.of<CategoryStore>(context);
        // final subCategoryStore = Provider.of<SubCategoryStore>(context);
        // final serviceStore = Provider.of<ServiceStore>(context);
        // final canAddMoreServices = provider.canAddMoreServices;
        // dev.log('Category Id${provider.selectedCategory!}');
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                // _buildLabel('Category *'),
                // _buildDropdown<CategoryModel>(
                //   context: context,
                //   items: categoryStore.items,
                //   value: provider.selectedCategory,
                //   hint: 'Select Category',
                //   onChanged:
                //       canAddMoreServices
                //           ? (value) {
                //             if (value != null) {
                //               final category = categoryStore.items.firstWhere(
                //                 (cat) => cat.category == value,
                //                 orElse: () => categoryStore.items.first,
                //               );
                //               provider.setCategory(
                //                 category.category,
                //                 int.parse(category.id),
                //               );
                //             }
                //           }
                //           : null,
                //   getDisplayValue: (item) => item.category,
                // ),
                // const SizedBox(height: 16),
                //
                // // Subcategory Dropdown
                // _buildLabel('Subcategory *'),
                // _buildDropdown<SubCategoryModel>(
                //   context: context,
                //   items:
                //       subCategoryStore.items
                //           .where(
                //             (e) => e.categoryId == '${provider.categoryId}',
                //           )
                //           .toList(),
                //   value: provider.selectedSubCategory,
                //   hint: 'Select Subcategory',
                //   onChanged:
                //       canAddMoreServices && provider.selectedCategory != null
                //           ? (value) {
                //             if (value != null) {
                //               final subCategory = subCategoryStore.items
                //                   .firstWhere(
                //                     (sub) => sub.name == value,
                //                     orElse: () => subCategoryStore.items.first,
                //                   );
                //               provider.setSubCategory(
                //                 subCategory.name,
                //                 int.parse(subCategory.id),
                //               );
                //             }
                //           }
                //           : null,
                //   getDisplayValue: (item) => item.name,
                // ),
                // const SizedBox(height: 16),
                //
                // // Service Type Dropdown
                // _buildLabel('Service Type *'),
                // _buildDropdown<ServiceModel>(
                //   context: context,
                //   items:
                //       serviceStore.items
                //           .where(
                //             (e) =>
                //                 e.subcategoryId == provider.subCategoryId &&
                //                 e.categoryId == provider.categoryId,
                //           )
                //           .toList(),
                //   value: provider.selectedService,
                //   hint: 'Select Service Type',
                //   onChanged:
                //       canAddMoreServices && provider.selectedSubCategory != null
                //           ? (value) {
                //             if (value != null) {
                //               final service = serviceStore.items.firstWhere(
                //                 (service) => service.serviceName == value,
                //                 orElse: () => serviceStore.items.first,
                //               );
                //               provider.setService(
                //                 service.serviceName,
                //                 int.parse(service.id),
                //               );
                //             }
                //           }
                //           : null,
                //   getDisplayValue: (item) => item.serviceName,
                // ),
                // const SizedBox(height: 16),

                // Service Name TextField
                _buildLabel('Service Name *'),
                CupertinoTextField(
                  controller: provider.serviceNameController,
                  placeholder: 'Enter service name',
                  padding: 16.symmetricHV(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  // enabled: canAddMoreServices,
                ),
                const SizedBox(height: 16),

                // Rate TextField
                _buildLabel('Rate (₹) '),
                CupertinoTextField(
                  controller: provider.rateController,
                  placeholder: 'Enter rate',
                  padding: 16.symmetricHV(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefix: Padding(
                    padding: 16.left,
                    child: Text(
                      '₹',
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // enabled: canAddMoreServices,
                ),

                //
                _buildLabel(
                  'Description ${() {
                    return maxDescriptionLength > 30 ? '$maxDescriptionLength characters max' : '(30 characters max)';
                  }()}',
                ),
                buildTextArea(
                  controller: provider.descriptionController,
                  placeholder: 'Enter service description',
                  maxLength:
                      maxDescriptionLength > 0 ? maxDescriptionLength : null,
                  // enabled: canAddMoreServices,
                  semanticsLabel: 'Description input field',
                ),
                const SizedBox(height: 24),

                buildToggleOption(
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
                buildToggleOption(
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

                // if (!canAddMoreServices)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 16),
                //     child: Container(
                //       padding: const EdgeInsets.all(12),
                //       decoration: BoxDecoration(
                //         color: CupertinoColors.systemRed.withOpacity(0.1),
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Row(
                //         children: [
                //           const Icon(
                //             CupertinoIcons.exclamationmark_triangle,
                //             color: CupertinoColors.systemRed,
                //           ),
                //           const SizedBox(width: 8),
                //           Expanded(
                //             child: Text(
                //               'You have reached the maximum number of services allowed by your plan. Please upgrade to add more services.',
                //               style: TextStyle(
                //                 color: CupertinoColors.systemRed,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                const SizedBox(height: 24),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () => provider.nextStep(context),
                    // canAddMoreServices
                    //     ? () => provider.nextStep(context)
                    //     : null,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required List<T> items,
    required String? value,
    required String hint,
    required ValueChanged<String?>? onChanged,
    required String Function(T) getDisplayValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
        ),
        icon: const Icon(Icons.arrow_drop_down),
        style: const TextStyle(color: Colors.black, fontSize: 16),
        onChanged: onChanged,
        items:
            items.map<DropdownMenuItem<String>>((T item) {
              return DropdownMenuItem<String>(
                value: getDisplayValue(item),
                child: Text(getDisplayValue(item)),
              );
            }).toList(),
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }
}
