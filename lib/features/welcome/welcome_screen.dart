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
      'Fresh drops, real artists, real support.\nStream, gift, and ride with Africa\'s next big names.',
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

}
