import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/validators.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    final email = _emailController.text.trim();
    final ok = await auth.requestPasswordReset(email);
    if (!mounted || !ok) return;
    context.push(
      '${AppRouter.verifyEmailForPasswordReset}?email=${Uri.encodeComponent(email)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                24.column,
                _buildHeader(),
                40.column,
                _buildTitle(),
                8.column,
                _buildSubtitle(),
                40.column,
                _buildEmailField(),
                const Spacer(),
                CustomButton.signUp(
                  text: 'Reset Password',
                  width: double.infinity,
                  isLoading: auth.isForgotPasswordLoading,
                  onPressed: () => _submit(auth),
                ),
                32.column,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
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
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.buttonColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999.radius),
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.buttonColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Reset Password',
      style: AppTextStyles.heading1.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter the email address on your account. We will send reset instructions if an account exists.',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.text.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email address',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.column,
        CustomInputField(
          controller: _emailController,
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          borderRadius: 12.radius,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 16.padding,
          ),
          validator: Validators.email,
        ),
      ],
    );
  }
}
