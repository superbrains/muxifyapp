// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/services/biometric_auth_service.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final bool isAvailable = await BiometricAuthService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
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
              _buildEmailField(),
              16.column,
              _buildPasswordField(),
              16.column,
              _buildResetPasswordLink(),
              40.column,
              _buildSocialLoginSection(),
              74.column,
              _buildBiometricLogin(),
              54.column,
              _buildLoginButton(),
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
      'Welcome back to Muxify',
      style: AppTextStyles.heading1.copyWith(
        fontSize: 28.font,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Login with your information or use social login',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.text.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address or Phone Number',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.column,
        CustomInputField(
          controller: _emailController,
          hintText: 'Email Address or Phone Number',
          keyboardType: TextInputType.emailAddress,
          borderRadius: 12.radius,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 16.padding,
          ),
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
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.column,
        CustomInputField(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: !_isPasswordVisible,
          borderRadius: 12.radius,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 16.padding,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.padding),
              child: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.text.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(AppRouter.resetPassword);
        },
        child: Text(
          'Reset Password',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.buttonColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Text(
          'Social login',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        24.column,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata, () {
              HapticFeedback.lightImpact();
            }),
            24.row,
            _buildSocialButton(Icons.apple, () {
              HapticFeedback.lightImpact();
            }),
            24.row,
            _buildSocialButton(Icons.facebook, () {
              HapticFeedback.lightImpact();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.glassyDark,
          borderRadius: BorderRadius.circular(999.radius),
        ),
        child: Icon(icon, color: AppColors.text, size: 24.icon),
      ),
    );
  }

  Widget _buildBiometricLogin() {
    if (!_isBiometricAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _handleBiometricLogin,
          child: const Icon(Icons.fingerprint, color: AppColors.text, size: 50),
        ),
        8.column,
        Text(
          'Biometric login',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _handleBiometricLogin() async {
    HapticFeedback.lightImpact();

    final bool isAuthenticated = await BiometricAuthService.authenticate();

    if (isAuthenticated && mounted) {
      final String? savedEmail = await LocalStorageService.getUserEmail();
      final String? savedPassword = await LocalStorageService.getUserPassword();

      if (savedEmail != null && savedPassword != null) {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _performLogin();
      } else {
        context.go(AppRouter.home);
      }
    }
  }

  Future<void> _performLogin() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      await LocalStorageService.setUserEmail(_emailController.text);
      await LocalStorageService.setUserPassword(_passwordController.text);
      context.go(AppRouter.home);
    }
  }

  Widget _buildLoginButton() {
    return CustomButton.signUp(
      text: 'Login',
      width: double.infinity,
      onPressed: () {
        HapticFeedback.lightImpact();
        _performLogin();
      },
    );
  }
}
