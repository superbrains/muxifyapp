import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class CoinBalanceSection extends StatelessWidget {
  final String currentBalance;

  const CoinBalanceSection({super.key, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Coin Balance',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w500,
          ),
        ),

        16.column,

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 43.icon,
              height: 43.icon,
            ),

            10.row,

            Text(
              'm$currentBalance',
              style: AppTextStyles.displayText.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15.font,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
