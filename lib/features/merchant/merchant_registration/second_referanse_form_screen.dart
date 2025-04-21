// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

// import 'core/merchant_registration_view_model.dart';

// class MerchantRegistrationScreen extends StatefulWidget {
//   const MerchantRegistrationScreen({super.key});

//   @override
//   State<MerchantRegistrationScreen> createState() => _MerchantRegistrationScreenState();
// }

// class _MerchantRegistrationScreenState extends State<MerchantRegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _nextStep(BuildContext context, MerchantRegistrationViewModel viewModel) {
//     if (_formKey.currentState!.validate()) {
//       if (viewModel.currentStep < 3) {
//         _pageController.nextPage(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//         viewModel.currentStep++;
//       }
//     }
//   }

//   void _previousStep(BuildContext context, MerchantRegistrationViewModel viewModel) {
//     if (viewModel.currentStep > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       viewModel.currentStep--;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MerchantRegistrationViewModel>(
//       builder: (context, viewModel, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () {
//                 if (viewModel.currentStep > 0) {
//                   _previousStep(context, viewModel);
//                 } else {
//                   context.pop();
//                 }
//               },
//             ),
//             title: Text(
//               'Merchant Registration',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             centerTitle: true,
//           ),
//           body: SafeArea(
//             child: Column(
//               children: [
//                 _buildProgressIndicator(viewModel),
//                 Expanded(
//                   child: Form(
//                     key: _formKey,
//                     child: PageView(
//                       controller: _pageController,
//                       physics: const NeverScrollableScrollPhysics(),
//                       children: [
//                         _PersonalInfoStep(formKey: _formKey),
//                         _BusinessDetailsStep(formKey: _formKey),
//                         _AddressStep(formKey: _formKey),
//                         _AccountStep(formKey: _formKey),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _buildNavigationButtons(context, viewModel),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProgressIndicator(MerchantRegistrationViewModel viewModel) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: List.generate(4, (index) {
//           return Expanded(
//             child: Container(
//               height: 4,
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               decoration: BoxDecoration(
//                 color: index <= viewModel.currentStep
//                     ? Colors.blue[700]
//                     : Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildNavigationButtons(
//       BuildContext context,
//       MerchantRegistrationViewModel viewModel
//       ) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           if (viewModel.currentStep > 0)
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _previousStep(context, viewModel),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.blue[700],
//                   side: BorderSide(color: Colors.blue[700]!),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Previous'),
//               ),
//             ),
//           if (viewModel.currentStep > 0) const SizedBox(width: 16),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: viewModel.currentStep == 3
//                   ? () => viewModel.merchantRegistration(context)
//                   : () => _nextStep(context, viewModel),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[700],
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(viewModel.currentStep == 3 ? 'Submit' : 'Next'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PersonalInfoStep extends StatelessWidget {
//   final GlobalKey<FormState> formKey;

//   const _PersonalInfoStep({required this.formKey});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.read<MerchantRegistrationViewModel>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Personal Information',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[700],
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: viewModel.nameController,
//             decoration: _inputDecoration('Full Name', Icons.person),
//             validator: (value) =>
//             value == null || value.isEmpty ? 'Please enter your name' : null,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: viewModel.emailController,
//             decoration: _inputDecoration('Email Address', Icons.email),
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value == null || value.isEmpty) return 'Please enter an email';
//               final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//               return !emailRegex.hasMatch(value)
//                   ? 'Please enter a valid email'
//                   : null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: viewModel.mobileController,
//             decoration: _inputDecoration('Mobile Number', Icons.phone),
//             keyboardType: TextInputType.phone,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(10),
//             ],
//             validator: (value) {
//               if (value == null || value.isEmpty) return 'Please enter mobile number';
//               return value.length != 10 ? 'Mobile number must be 10 digits' : null;
//             },
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Gender',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           Row(
//             children: ['Male', 'Female'].map((gender) {
//               return Expanded(
//                 child: RadioListTile<String>(
//                   title: Text(gender),
//                   value: gender,
//                   groupValue: viewModel.gender,
//                   onChanged: (value) {
//                     if (value != null) viewModel.gender = value;
//                   },
//                   activeColor: Colors.blue[700],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon, color: Colors.blue[700]),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.blue[700]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey[400]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
//       ),
//     );
//   }
// }

// // You would create similar classes for _BusinessDetailsStep, _AddressStep, and _AccountStep
// // Following the same pattern as _PersonalInfoStep, with appropriate form fields and validations

// class _BusinessDetailsStep extends StatelessWidget {
//   final GlobalKey<FormState> formKey;

//   const _BusinessDetailsStep({required this.formKey});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.read<MerchantRegistrationViewModel>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Business Details',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[700],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Add business details form fields similar to Personal Info Step
//           // Include shop name, business start year, business location, etc.
//           // Use similar styling and validation approach
//         ],
//       ),
//     );
//   }
// }

// class _AddressStep extends StatelessWidget {
//   final GlobalKey<FormState> formKey;

//   const _AddressStep({required this.formKey});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.read<MerchantRegistrationViewModel>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Business Address',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[700],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Add address form fields
//           // Include full address, pincode, state dropdown, etc.
//           // Use similar styling and validation approach
//         ],
//       ),
//     );
//   }
// }

// class _AccountStep extends StatelessWidget {
//   final GlobalKey<FormState> formKey;

//   const _AccountStep({required this.formKey});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.read<MerchantRegistrationViewModel>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Account Setup',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[700],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Add account setup form fields
//           // Include password, confirm password, referral code, etc.
//           // Use similar styling and validation approach
//         ],
//       ),
//     );
//   }
// }