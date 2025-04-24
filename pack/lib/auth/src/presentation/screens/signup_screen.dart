// src/presentation/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'login_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'login_screen.dart';

class SignupSuccessResult {
  final String id, name, phone, otp;
  SignupSuccessResult({
    required this.id,
    required this.name,
    required this.phone,
    this.otp = '',
  });
}

class SignupScreen<T extends UserEntity> extends StatefulWidget {
  final bool enableSocialLogin;
  final String? logoAsset;
  final String title;
  final String subtitle;
  final Function(SignupSuccessResult)? onSignupSuccess;
  final VoidCallback? onLoginTap;
  final bool requireName;

  const SignupScreen({
    super.key,
    this.enableSocialLogin = false,
    this.logoAsset,
    this.title = 'Create Account',
    this.subtitle = 'Sign up to get started',
    this.onSignupSuccess,
    this.onLoginTap,
    this.requireName = true,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState<T>();
}

class _SignupScreenState<T extends UserEntity> extends State<SignupScreen<T>> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(
        SignupEvent(
          name: widget.requireName ? _nameController.text.trim() : null,
          email: _emailController.text.trim(),
          phone: _phoneController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _socialLogin(SocialLoginProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Social signup with ${provider.name} is not implemented yet',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is OTPSentState<T>) {
            final result = SignupSuccessResult(
              id: state.userId,
              name: _nameController.text,
              phone: _phoneController.text,
              otp: state.otp,
            );

            widget.onSignupSuccess?.call(result);
          }
          if (state is AuthenticatedState<T>) {
            widget.onSignupSuccess?.call(
              SignupSuccessResult(
                id: state.authResponse.user!.id,
                name: state.authResponse.user!.name,
                phone: '',
              ),
            );
          } else if (state is AuthErrorState<T>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.logoAsset != null) ...[
                      Image.asset(widget.logoAsset!, width: 120, height: 120),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (widget.requireName) ...[
                      AuthTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          _phoneFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    AuthTextField(
                      label: 'Phone no',
                      hint: 'Enter your phone no',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,

                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone no';
                        }
                        return null;
                      },

                      focusNode: _phoneFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _emailFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter your email';
                      //   }
                      //   if (!RegExp(
                      //     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      //   ).hasMatch(value)) {
                      //     return 'Please enter a valid email';
                      //   }
                      //   return null;
                      // },
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _passwordFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 3) {
                          return 'Password must be at least 3 characters';
                        }
                        return null;
                      },
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _confirmPasswordFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      focusNode: _confirmPasswordFocusNode,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _signup,
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc<T>, AuthState<T>>(
                      builder: (context, state) {
                        return AuthButton(
                          text: 'Sign Up',
                          onPressed: _signup,
                          isLoading: state is AuthLoadingState,
                          icon: Icons.app_registration,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (widget.enableSocialLogin) ...[
                      const AuthDivider(),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        provider: SocialLoginProvider.google,
                        onPressed:
                            () => _socialLogin(SocialLoginProvider.google),
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        provider: SocialLoginProvider.facebook,
                        onPressed:
                            () => _socialLogin(SocialLoginProvider.facebook),
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        provider: SocialLoginProvider.twitter,
                        onPressed:
                            () => _socialLogin(SocialLoginProvider.twitter),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed:
                              widget.onLoginTap ??
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
