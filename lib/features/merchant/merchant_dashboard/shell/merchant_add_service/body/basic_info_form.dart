// import 'package:flutter/material.dart';
// import 'package:my_ad/core/data/model/model.dart';
// import 'package:pack/pack.dart';
// import 'package:provider/provider.dart';
// import '../../../../../../core/domain/data_store/data_store.dart';
// import '../core/merchant_add_service_provider.dart';
// import 'other_components.dart';
//
// class BasicInfoForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MerchantAddServiceProvider>(
//       builder: (context, provider, _) {
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Basic Information',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 FormLabel(label: 'Category'),
//                 _buildCategoryDropdown(context, provider),
//                 const SizedBox(height: 16),
//                 FormLabel(label: 'Subcategory'),
//                 _buildSubcategoryDropdown(context, provider),
//                 const SizedBox(height: 16),
//                 FormLabel(label: 'Service Type'),
//                 _buildServiceTypeDropdown(context, provider),
//                 const SizedBox(height: 16),
//                 FormLabel(label: 'Service Name'),
//                 TextFormField(
//                   controller: provider.serviceNameController,
//                   decoration: _inputDecoration('Enter your service name'),
//                   validator: (value) => value!.isEmpty ? 'Please enter service name' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 FormLabel(label: 'Rate (INR)'),
//                 TextFormField(
//                   controller: provider.rateController,
//                   keyboardType: TextInputType.number,
//                   decoration: _inputDecoration('Enter your rate', prefix: Currency.rupeeSymbol),
//                   validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Invalid rate' : null,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCategoryDropdown(BuildContext context, MerchantAddServiceProvider provider) {
//     return Consumer<CategoryStore>(
//       builder: (context, store, _) {
//         return CustomDropdownField<String>(
//           hint: 'Select a category',
//           // value: provider.selectedCategory.isEmpty ? null : provider.selectedCategory,
//           items: store.items.map((e) => e.id).toList(),
//           itemBuilder: (ctx, id) => DropdownMenuItem(
//             value: id,
//             child: Text(store.items.firstWhere((cat) => cat.id == id, orElse: ()=>CategoryModel.empty()).category,),
//           ),
//           onChanged: (value) => provider.selectedCategory = value!,
//           label: '',
//         );
//       },
//     );
//   }
//
//   Widget _buildSubcategoryDropdown(BuildContext context, MerchantAddServiceProvider provider) {
//     return Consumer<SubCategoryStore>(
//       builder: (context, store, _) {
//         final subcategories = store.items.where((e) => e.categoryId == provider.selectedCategory).toList();
//         return CustomDropdownField<String>(
//           hint: 'Select a subcategory',
//           // value: provider.selectedSubCategory.isEmpty ? null : provider.selectedSubCategory,
//           items: subcategories.map((e) => e.id).toList(),
//           itemBuilder: (ctx, id) => DropdownMenuItem(
//             value: id,
//             child: Text(subcategories.firstWhere((sub) => sub.id == id).name),
//           ),
//           onChanged: (value) => provider.selectedSubCategory = value ?? '',
//           label: '',
//         );
//       },
//     );
//   }
//
//   Widget _buildServiceTypeDropdown(BuildContext context, MerchantAddServiceProvider provider) {
//     return Consumer<ServiceStore>(
//       builder: (context, store, _) {
//         final services = store.items.where((e) => '${e.subcategoryId}' == provider.selectedSubCategory).toList();
//         return CustomDropdownField<String>(
//           hint: 'Select a service',
//           // value: provider.selectedService.isEmpty ? null : provider.selectedService,
//           items: services.map((e) => e.id).toList(),
//           itemBuilder: (ctx, id) => DropdownMenuItem(
//             value: id,
//             child: Text(services.firstWhere((srv) => srv.id == id).displayName),
//           ),
//           onChanged: (value) => provider.selectedService = value ?? '',
//           label: '',
//         );
//       },
//     );
//   }
//
//   InputDecoration _inputDecoration(String hint, {String? prefix}) {
//     return InputDecoration(
//       hintText: hint,
//       prefixText: prefix,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//     );
//   }
// }