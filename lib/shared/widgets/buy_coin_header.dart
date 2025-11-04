import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class BuyCoinHeader extends StatelessWidget {

  final String? title;
  final String? subtitle;
  const BuyCoinHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title ?? 'Buy Coin',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w500,
          ),
        ),

        3.column,

        Text(
          subtitle ?? 'Choose how much coin to buy',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.text,
            fontSize: 14.font,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
