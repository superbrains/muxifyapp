import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Login',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                32.column,
                _buildTitle(),
                8.column,
                _buildSubtitle(),
                40.column,
                _buildEmailField(),
                24.column,
                _buildPhoneField(),
                24.column,
                _buildPasswordField(),
                24.column,
                _buildTermsAgreement(),
                40.column,
                _buildSocialLogin(),
                40.column,
                _buildCreateAccountButton(),
                32.column,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Let's Get Started!",
      style: AppTextStyles.heading2.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Signup with valid information or use social login',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.text.withValues(alpha: 0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        8.column,
        CustomInputField(
          controller: _emailController,
          hintText: 'Email Address',
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        8.column,
        Row(
          children: [
            Container(
              height: 48.buttonHeight,
              padding: EdgeInsets.symmetric(horizontal: 12.padding),
              decoration: BoxDecoration(
                color: AppColors.glassyDark,
                borderRadius: BorderRadius.circular(12.radius),
                border: Border.all(
                  color: AppColors.text.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2.radius),
                    ),
                    child: const Center(
                      child: Text('🇳🇬', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  8.row,
                  Text('+234', style: AppTextStyles.bodyMedium),
                  4.row,
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.text,
                    size: 16,
                  ),
                ],
              ),
            ),
            12.row,
            Expanded(
              child: CustomInputField(
                controller: _phoneController,
                hintText: 'e.g 90 345 6789',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        8.column,
        CustomInputField(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.text.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreeToTerms ? AppColors.buttonColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4.radius),
              border: Border.all(
                color: _agreeToTerms
                    ? AppColors.buttonColor
                    : AppColors.text.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check, color: AppColors.text, size: 14)
                : null,
          ),
        ),
        12.row,
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.text.withValues(alpha: 0.8),
              ),
              children: [
                const TextSpan(text: 'By Signing up, you agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Text(
          'Social login',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
        24.column,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata, () {}),
            24.row,
            _buildSocialButton(Icons.apple, () {}),
            24.row,
            _buildSocialButton(Icons.facebook, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.glassyDark,
          borderRadius: BorderRadius.circular(999.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: AppColors.text, size: 32.icon),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return CustomButton.signUp(
      text: 'Create Account',
      width: double.infinity,
      onPressed: _agreeToTerms
          ? () {
              HapticFeedback.lightImpact();
              context.push(
                '${AppRouter.verifyEmail}?email=${Uri.encodeComponent(_emailController.text)}',
              );
            }
          : null,
    );
  }
}
