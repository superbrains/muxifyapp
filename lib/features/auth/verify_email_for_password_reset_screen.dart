import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/shared/widgets/custom_button.dart';

/// Shown after `POST /api/v1/auth/forgot-password` succeeds. Reset completes on
/// [CreateNewPasswordScreen] with `POST /api/v1/auth/reset-password` (token from email).
class VerifyEmailForPasswordResetScreen extends StatelessWidget {
  const VerifyEmailForPasswordResetScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              24.column,
              Align(alignment: Alignment.centerLeft, child: _buildBackButton(context)),
              40.column,
              Text(
                'Check your email',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 28.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.column,
              Text(
                'If an account exists for ${email.trim()}, you will receive a message with a link or token to set a new password.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.text.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              40.column,
              CustomButton.outlined(
                text: 'Resend email',
                width: double.infinity,
                isLoading: auth.isForgotPasswordLoading,
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await auth.requestPasswordReset(email);
                },
              ),
              16.column,
              CustomButton.signUp(
                text: 'Enter new password',
                width: double.infinity,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final trimmed = email.trim();
                  final qp = <String, String>{
                    if (trimmed.isNotEmpty) 'email': trimmed,
                  };
                  context.push(
                    Uri(path: AppRouter.createNewPassword, queryParameters: qp)
                        .toString(),
                  );
                },
              ),
              24.column,
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go(AppRouter.login);
                },
                child: Text(
                  'Back to login',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.buttonColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.text,
          size: 18,
        ),
      ),
    );
  }
}
