import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class CoinPackageCard extends StatelessWidget {
  final String amount;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const CoinPackageCard({
    super.key,
    required this.amount,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12.padding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor.withValues(alpha: 0.1)
              : AppColors.greyButtonColor,
          borderRadius: BorderRadius.circular(10.radius),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonColor
                : AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 35.icon,
              height: 35.icon,
            ),

            8.row,

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'm$amount',
                  style: AppTextStyles.displayText.copyWith(
                    color: Colors.white,
                    fontSize: 10.font,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                4.column,

                Text(
                  'N$price',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10.font,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
