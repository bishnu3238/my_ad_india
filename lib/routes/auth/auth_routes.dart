import 'package:go_router/go_router.dart';
import '../../features/home/core/home_navigator.dart';
import 'dart:developer' as dev;
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/pack.dart';

import '../../core/data/model/user/user_model.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';

  static List<GoRoute> pages() => [
    GoRoute(
      path: login,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: LoginScreen<UserModel>(
              onLoginSuccess: () async {
                await getIt<AuthProviderModel<UserModel>>().initialize();
                if (context.mounted) context.go('/home');
              },
              onCreateAccountTap: () => context.push(register),
              onForgotPasswordTap: () => context.push(forgotPassword),
            ),
          ),
    ),
    GoRoute(
      path: register,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(),
            child: SignupScreen<UserModel>(
              onSignupSuccess: (String userId) {
                dev.log(userId);

                return context.pushNamed(
                  '/OTP',
                  pathParameters: {'userID': userId},
                );
              },
              onLoginTap: () => context.push(login),
            ),
          ),
    ),
    GoRoute(
      path: forgotPassword,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: ForgotPasswordScreen<UserModel>(
              onResetSuccess: () {
                context.go('/login');
              },
            ),
          ),
    ),
    GoRoute(
      path: resetPassword,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: ChangePasswordScreen<UserModel>(
              onPasswordChanged: () {
                context.go('/home');
              },
            ),
          ),
    ),
    GoRoute(
      path: '$otp/:userID',
      name: otp.toUpperCase(),
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: OTPScreen<UserModel>(
              userId: state.pathParameters['userID']!,
              otp: 'OTP',
              phoneNo: 'PHONE',
              userName: 'USERNAME',
              onVerifySuccess: () {
                dev.log('OTP verified successfully');
                context.go(HomeRoute.home);
              },
            ),
          ),
    ),
  ];
}
