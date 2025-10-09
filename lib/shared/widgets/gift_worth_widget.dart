import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class GiftWorthWidget extends StatelessWidget {
  final String amount;
  final String label;
  final double? iconSize;
  final double? amountFontSize;
  final double? labelFontSize;

  const GiftWorthWidget({
    super.key,
    required this.amount,
    required this.label,
    this.iconSize,
    this.amountFontSize,
    this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Gift Icon
        Image.asset(
          'assets/pngs/gift.png',
          width: iconSize ?? 22.icon,
          height: iconSize ?? 22.icon,
        ),
        8.row,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amount,
              style: AppTextStyles.displayTextWithSize(
                amountFontSize ?? 16.font,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: labelFontSize ?? 10.font,
                fontWeight: FontWeight.w400,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
