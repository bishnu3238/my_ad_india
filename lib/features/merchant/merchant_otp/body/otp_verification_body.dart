import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import 'otp_form.dart';
import '../core/merchant_otp_viewmodel.dart';

class OTPVerificationBody extends StatelessWidget {
  const OTPVerificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<OTPProvider>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header section
            const SizedBox(height: 16),
            Icon(
              CupertinoIcons.lock_shield_fill,
              size: 64,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Verify OTP', 
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter the 6-digit OTP sent to your mobile number',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              otpProvider.merchantId,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // OTP input section
            OTPForm(onComplete: (otp) => otpProvider.setOtp(otp)),
            const SizedBox(height: 16),

            // Error message section
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: otpProvider.errorMessage != null
                  ? ErrorMessageBox(
                      message: otpProvider.errorMessage!,
                      onDismiss: otpProvider.clearOtp,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            
            // Verify button
            Consumer<OTPProvider>(
              builder: (context, provider, _) => CustomButton(
                onPressed: () => provider.otpVerification(context),
                isLoading: provider.isLoading,
                text: 'Verify OTP',
                width: double.infinity,
                height: 50,
                borderRadius: 10,
              ),
            ),
            const SizedBox(height: 24),
            
            // Resend OTP section
            ResendOTPSection(
              otpProvider: otpProvider,
              onResend: () => otpProvider.resendOTP(context),
            ),
            
            // Additional help section
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Having trouble with your OTP?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: () => showHelpDialog(context),
              icon: const Icon(Icons.help_outline),
              label: const Text('Get Help'),
            ),
          ],
        ),
      ),
    );
  }

  void showHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: theme.primaryColor),
            const SizedBox(width: 8),
            const Text('OTP Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                '1. Check your Phone message section for the verification code',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '2. Make sure you enter the complete 6-digit code',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '3. If you don\'t receive the code, try the "Resend OTP" option',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '4. Check your spam folder or any other messaging apps',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '5. Contact support if you continue to have problems',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class ResendOTPSection extends StatelessWidget {
  final OTPProvider otpProvider;
  final VoidCallback onResend;

  const ResendOTPSection({
    super.key,
    required this.otpProvider,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Didn\'t receive the OTP?',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        if (otpProvider.canResendOtp)
          TextButton.icon(
            onPressed: onResend,
            icon: const Icon(Icons.refresh),
            label: const Text('Resend OTP'),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Resend available in ${otpProvider.remainingResendTime} seconds',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        if (otpProvider.otpAttempts > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Attempts: ${otpProvider.otpAttempts}/${OTPProvider.maxOtpAttempts}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: otpProvider.hasReachedMaxAttempts 
                    ? Colors.red 
                    : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}

class ErrorMessageBox extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const ErrorMessageBox({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDismiss,
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
