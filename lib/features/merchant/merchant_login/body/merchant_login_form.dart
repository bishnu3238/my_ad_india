import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../core/merchant_login_viewmodel.dart';
import 'merchant_login_header.dart';
import 'register_button_sectoin.dart';
import '../../../../utils/handler/validation_handler.dart';
import 'package:provider/provider.dart';

class MerchantLoginForm extends StatelessWidget {
  const MerchantLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer<MerchantLoginScreenViewModel>(
            builder: (context, loginProvider, child) {
              return Form(
                key: loginProvider.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    MerchantLoginHeader(),
                    const SizedBox(height: 32),

                    // Email TextField
                    _buildAnimatedTextField(
                      controller: loginProvider.emailController,
                      labelText: 'Username or Phone or Email ',
                      prefixIcon: Icons.email,
                      // validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password TextField
                    _buildAnimatedTextField(
                      controller: loginProvider.passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      obscureText: loginProvider.obscurePassword,
                      // validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          loginProvider.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: loginProvider.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// TODO: uncomment this later when use forgot password.
                    // Forgot Password
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       Navigator.of(context).pushNamed('/forgot-password');
                    //     },
                    //     child: Text(
                    //       'Forgot Password?',
                    //       style: TextStyle(
                    //         color: AppColors.primaryBlue,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    // Login Button
                    _buildAnimatedButton(),
                    const SizedBox(height: 16),

                    // Register Link
                    RegisterButtonSections(context: context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: labelText,
              prefixIcon: Icon(prefixIcon, color: AppColors.primaryBlue),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
          ),
        )
        .animate()
        .fade(duration: 500.ms)
        .slideX(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildAnimatedButton() {
    return Consumer<MerchantLoginScreenViewModel>(
      builder: (context, loginViewModel, child) {
        return ElevatedButton(
          onPressed: () => loginViewModel.login(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              loginViewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        ).animate().scale(duration: 500.ms).fadeIn(duration: 500.ms);
      },
    );
  }
}
