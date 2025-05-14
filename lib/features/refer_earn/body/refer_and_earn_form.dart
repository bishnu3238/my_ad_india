import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/terms/core/terms_and_conditions_route.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/data/model/model.dart';
import '../core/refer_and_earn_provider.dart';

class ReferAndEarnForm extends StatefulWidget {
  const ReferAndEarnForm({super.key});

  @override
  State<ReferAndEarnForm> createState() => _ReferAndEarnFormState();
}

class _ReferAndEarnFormState extends State<ReferAndEarnForm> {
  bool _agreeToTerms = false;

  late ReferAndEarnProvider provider;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    provider = context.read<ReferAndEarnProvider>();
    _initializeControllers();
  }

  void _initializeControllers() {
    // final user = provider.user;

    _nameController = TextEditingController(text: provider.user?.name ?? '');
    _phoneController = TextEditingController(
      text: provider.user?.metadata![UserMetadata.phoneNo.name] ?? '',
    );
    _emailController = TextEditingController(text: provider.user?.email ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Form(
        key: provider.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Become an Agent',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: CupertinoIcons.person_fill,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Phone Number Field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: CupertinoIcons.phone_fill,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Email Field (Optional)
            _buildTextField(
              controller: _emailController,
              label: 'Email (Optional)',
              icon: CupertinoIcons.mail_solid,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  CupertinoCheckbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value!;
                      });
                    },
                  ),
                  SizedBox(width: 5),
                  Text('I agree to the terms and conditions'),
                  IconButton(
                    onPressed: () => context.push(TermsRoute.termsAndConditions),
                    icon: Icon(FontAwesomeIcons.circleInfo),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Submit Button
            SizedBox(
              height: 50,
              child: Consumer<ReferAndEarnProvider>(
                builder:
                    (context, provider, child) => ElevatedButton(
                      onPressed:
                          _agreeToTerms
                              ? provider.isLoading
                                  ? null
                                  : () {
                                    provider.submitReferral(
                                      name: _nameController.text,
                                      phone: _phoneController.text,
                                      email:
                                          _emailController.text.isNotEmpty
                                              ? _emailController.text
                                              : null,
                                      context: context, // Pass context here
                                    );
                                  }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3192),
                        disabledBackgroundColor: Color(0xFF98779E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          provider.isLoading
                              ? CupertinoActivityIndicator(color: Colors.white)
                              : Text(
                                'Submit Application',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E3192)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2E3192)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
