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
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen<T extends UserEntity> extends StatefulWidget {
  final bool enableSocialLogin;
  final String? logoAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onCreateAccountTap;
  final VoidCallback? onForgotPasswordTap;

  const LoginScreen({
    super.key,
    this.enableSocialLogin = false,
    this.logoAsset,
    this.title = 'Welcome Back',
    this.subtitle = 'Sign in to your account',
    this.onLoginSuccess,
    this.onCreateAccountTap,
    this.onForgotPasswordTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState<T>();
}

class _LoginScreenState<T extends UserEntity> extends State<LoginScreen<T>> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use the correct generic type T for AuthBloc
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(
        LoginEvent(
          emailOrUsername: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _socialLogin(SocialLoginProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Social login with ${provider.name} is not implemented yet',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is AuthenticatedState<T>) {
            widget.onLoginSuccess?.call();
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
                    AuthTextField(
                      label: 'Email or Username',
                      hint: 'Enter your email or username',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or username';
                        }
                        return null;
                      },
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _login,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPasswordTap,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc<T>, AuthState<T>>(
                      builder: (context, state) {
                        return AuthButton(
                          text: 'Sign In',
                          onPressed: _login,
                          isLoading: state is AuthLoadingState,
                          icon: Icons.login,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (widget.enableSocialLogin) ...[
                      const AuthDivider(),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        provider: SocialLoginProvider.google,
                        onPressed: () => _socialLogin(SocialLoginProvider.google),
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        provider: SocialLoginProvider.facebook,
                        onPressed: () => _socialLogin(SocialLoginProvider.facebook),
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        provider: SocialLoginProvider.twitter,
                        onPressed: () => _socialLogin(SocialLoginProvider.twitter),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: widget.onCreateAccountTap ??
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                          child: const Text('Create Account'),
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