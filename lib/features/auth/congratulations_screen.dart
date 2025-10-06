import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/custom_button.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.padding),
          child: Column(
            children: [
              40.column,
              Image.asset('assets/pngs/textlogo.png', height: 44.h),
              32.column,
              _buildWelcomeMessage(),
              40.column,
              _buildCongratulationCard(),
              const Spacer(),
              _buildSkipVerification(),
              32.column,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Text(
      'Welcome to Muxify, be the first to play the latest songs, and watch the newest content',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.text.withValues(alpha: 0.9),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCongratulationCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.padding),
      decoration: BoxDecoration(
        color: AppColors.glassyDark,
        borderRadius: BorderRadius.circular(30.radius),
      ),
      child: Column(
        children: [
          Text(
            'Congratulation!',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 28.font,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          8.column,
          Text(
            'You just earned 100 coins',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          32.column,
          Image.asset('assets/pngs/Bitcoin_musixfy.png', height: 222.h),
          24.column,
          Text(
            'Verify your identity to earn more',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          24.column,
          _buildEarnMuxcoinButton(),
        ],
      ),
    );
  }

  Widget _buildEarnMuxcoinButton() {
    return CustomButton.signUp(
      text: 'Earn Muxcoin',
      width: double.infinity,
      onPressed: () {
        HapticFeedback.lightImpact();
      },
    );
  }

  Widget _buildSkipVerification() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Text(
        'Skip verification',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.text.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
