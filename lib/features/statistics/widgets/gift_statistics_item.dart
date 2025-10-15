import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/gift_statistics_item.dart';
import 'package:muxify/shared/widgets/gift_worth_widget.dart';

class GiftStatisticsItemWidget extends StatelessWidget {
  final GiftStatisticsItem item;
  final VoidCallback? onTap;
  final VoidCallback? onGiftCountTap;

  const GiftStatisticsItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onGiftCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Row(
        children: [
          // Album Art
          SizedBox(
            width: 38.maxWidth,
            height: 38.maxHeight,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(8.radius),
            // ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.radius),
              child: Image.asset(
                item.albumArtUrl ?? 'assets/pngs/follows.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          11.row,
          // Track Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Track Title
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                5.column,
                // Artist Name
                Text(
                  item.artist,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 15.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Gift Count Section
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onGiftCountTap?.call();
            },
            child: GiftWorthWidget(
              amount: item.giftCount,
              label: item.giftLabel,
              iconSize: 22.icon,
              amountFontSize: 16.font,
              labelFontSize: 10.font,
            ),
          ),
        ],
      ),
    );
  }

  //   String _formatGiftCount(int count) {
  //     if (count >= 1000000) {
  //       return '${(count / 1000000).toStringAsFixed(1)}M';
  //     } else if (count >= 1000) {
  //       return '${(count / 1000).toStringAsFixed(1)}K';
  //     } else {
  //       return count.toString();
  //     }
  //   }
}
