import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class LargeCoinPackageCard extends StatelessWidget {
  final String amount;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const LargeCoinPackageCard({
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
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16.padding,
          vertical: 12.padding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor.withValues(alpha: 0.1)
              : AppColors.greyButtonColor,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonColor
                : AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 30.icon,
              height: 30.icon,
            ),

            12.row,

            Text(
              'm$amount',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontSize: 16.font,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.padding,
                vertical: 5.padding,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.darkGreyButtonColor,
                borderRadius: BorderRadius.circular(30.radius),
              ),
              child: Text(
                'N$price',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12.font,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
