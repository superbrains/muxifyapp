import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/most_given_item.dart';
import 'package:muxify/shared/widgets/gift_worth_widget.dart';

class MostGivenItemWidget extends StatelessWidget {
  final MostGivenItem item;
  final VoidCallback? onTap;

  const MostGivenItemWidget({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank Image
          _buildRankImage(),
          11.row,
          // Artist Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artist Name
                Text(
                  item.artistName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                5.column,
                // Work Snippet
                Text(
                  item.workSnippet,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Received Gifts Section
          GiftWorthWidget(
            amount: item.receivedGifts,
            label: 'Received gifts',
            iconSize: 22.icon,
            amountFontSize: 16.font,
            labelFontSize: 10.font,
          ),
        ],
      ),
    );
  }

  Widget _buildRankImage() {
    return Image.asset(
      'assets/pngs/rank_${item.rank}.png',
      width: 40.maxWidth,
      height: 40.maxHeight,
      fit: BoxFit.contain,
    );
  }
}
