import 'package:go_router/go_router.dart';
import 'package:my_ad/core/constant/image.dart';
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
  static const String forgotPasswordOtp = '/forgot-password-otp';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';

  static List<GoRoute> pages() => [
    GoRoute(
      path: login,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: LoginScreen<UserModel>(
              logoAsset: AppImage.logo,

              // backgroundImage: AppImage.loginBackground,
              useGlassmorphism: false,
              accentColor: context.colorScheme.primary,
              animationStyle: AnimationStyle.scale,
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
              onSignupSuccess: (SignupSuccessResult userId) {
                dev.log(userId.otp);

                return context.pushNamed(
                  '/OTP',
                  pathParameters: {
                    'userID': userId.id,
                    'userName': userId.name,
                    'phoneNo': userId.phone,
                    'otp': userId.otp,
                  },
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
              onOtpSent:
                  (String identifier) =>
                      context.push('$forgotPasswordOtp/$identifier'),
            ),
          ),
      routes: [
        GoRoute(
          path: '$forgotPasswordOtp:/identifier',
          builder: (ctx, state) {
            final identifier = state.pathParameters['identifier']!;
            return OTPVerificationScreen(identifier: identifier);
          },
        ),
      ],
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
      path: '$otp/:userID/:userName/:phoneNo/:otp',
      name: otp.toUpperCase(),
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: OTPScreen<UserModel>(
              userId: state.pathParameters['userID']!,
              otp: state.pathParameters['otp']!,
              phoneNo: state.pathParameters['phoneNo']!,
              userName: state.pathParameters['userName']!,
              onVerifySuccess: () {
                dev.log('OTP verified successfully');
                context.go(HomeRoute.home);
              },
            ),
          ),
    ),
  ];
}
