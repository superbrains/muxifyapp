import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/otp_text_field.dart';

class VerifyEmailForPasswordResetScreen extends StatefulWidget {
  final String email;

  const VerifyEmailForPasswordResetScreen({super.key, required this.email});

  @override
  State<VerifyEmailForPasswordResetScreen> createState() =>
      _VerifyEmailForPasswordResetScreenState();
}

class _VerifyEmailForPasswordResetScreenState
    extends State<VerifyEmailForPasswordResetScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              24.column,
              Align(alignment: Alignment.centerLeft, child: _buildBackButton()),
              40.column,
              _buildTitle(),
              8.column,
              _buildSubtitle(),
              40.column,
              _buildOtpFields(),
              30.column,
              _buildResendCode(),
              250.column,
              _buildResetPasswordButton(),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
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

  Widget _buildTitle() {
    return Text(
      'Verify Email',
      style: AppTextStyles.heading1.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'An verification code has sent to ${widget.email}',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.text.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOtpFields() {
    return OtpTextField(
      controller: _otpController,
      otpLength: 5,
      onOtpCompleted: (otp) {
        HapticFeedback.lightImpact();
      },
    );
  }

  Widget _buildResendCode() {
    return Column(
      children: [
        Text(
          'Didn\'t get code?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text.withValues(alpha: 0.7),
          ),
        ),
        16.column,
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.padding,
              vertical: 12.padding,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassyDark,
              borderRadius: BorderRadius.circular(50.radius),
            ),
            child: Text(
              'Resend Code',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordButton() {
    return CustomButton.signUp(
      text: 'Verify Code',
      width: double.infinity,
      onPressed: () {
        HapticFeedback.lightImpact();
        if (_otpController.text.length == 5) {
          context.push('${AppRouter.createNewPassword}?email=${widget.email}');
        }
      },
    );
  }
}
