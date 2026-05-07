import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:muxify/shared/widgets/otp_text_field.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _verificationCode = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onOtpCompleted(String code) {
    setState(() {
      _verificationCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      40.column,
                      _buildTitle(),
                      8.column,
                      _buildInstructions(),
                      40.column,
                      _buildCodeInputFields(),
                      30.column,
                      _buildResendSection(),
                    ],
                  ),
                ),
              ),
              _buildVerifyButton(),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text('Verify Email', style: AppTextStyles.heading2.copyWith());
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        Text(
          'A verification code has sent to',
          style: AppTextStyles.bodyMedium.copyWith(),
        ),
        4.column,
        Text(widget.email, style: AppTextStyles.bodyMedium.copyWith()),
      ],
    );
  }

  Widget _buildCodeInputFields() {
    return OtpTextField(
      controller: _otpController,
      otpLength: 6,
      onOtpCompleted: _onOtpCompleted,
      filledColor: AppColors.glassyDark,
      borderColor: AppColors.text.withValues(alpha: 0.2),
      errorColor: AppColors.buttonColor,
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          "Didn't get code?",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text.withValues(alpha: 0.8),
          ),
        ),
        12.column,
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 32.padding,
              vertical: 12.padding,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassyDark,
              borderRadius: BorderRadius.circular(20.radius),
            ),
            child: Text(
              'Resend Code',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final ready = _verificationCode.length == 6;
        return CustomButton.signUp(
          text: 'Verify Email',
          width: double.infinity,
          isLoading: auth.isVerifyEmailLoading,
          onPressed: ready && !auth.isVerifyEmailLoading
              ? () async {
                  FocusScope.of(context).unfocus();
                  HapticFeedback.lightImpact();
                  final ok = await auth.verifyEmailCode(
                    _verificationCode.trim(),
                  );
                  if (!context.mounted || !ok) return;
                  context.push(AppRouter.createUsername);
                }
              : null,
        );
      },
    );
  }
}
