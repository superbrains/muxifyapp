import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pngs/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.8),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.padding),
        child: Column(
          children: [
            32.column,
            _buildLogo(),
            170.column,
            _buildHeadline(),
            10.column,
            _buildDescription(),
            80.column,
            _buildButtons(context),
            32.column,
            _buildSocialLogin(),
            32.column,
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset('assets/pngs/textlogo.png', height: 65.h);
  }

  Widget _buildHeadline() {
    return Text(
      'Be the first to "Press Play"',
      textAlign: TextAlign.center,
      style: AppTextStyles.heading2.copyWith(),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Lorem ipsum dolor sit amet consectetur.\nFaucibus tellus vel vulputate tortor.',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyLarge.copyWith(),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton.signIn(
          text: 'Sign in',
          width: double.infinity,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(AppRouter.login);
          },
        ),
        16.column,
        CustomButton.signUp(
          text: 'Sign up for free',
          width: double.infinity,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(AppRouter.signup);
          },
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.text.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.padding),
              child: Text(
                'Or continue with',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.text.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        24.column,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.apple, () {}),
            24.row,
            _buildSocialButton(Icons.g_mobiledata, () {}),
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
}
