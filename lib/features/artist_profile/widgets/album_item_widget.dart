import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/album_item.dart';
import 'package:muxify/shared/widgets/gift_worth_widget.dart';

class AlbumItemWidget extends StatelessWidget {
  final AlbumItem item;
  final VoidCallback? onTap;
  final VoidCallback? onGiftCountTap;

  const AlbumItemWidget({
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
            width: 61.maxWidth,
            height: 61.maxHeight,
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
          // Album Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Title
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
              label: 'Received Gifts',
              iconSize: 22.icon,
              amountFontSize: 16.font,
              labelFontSize: 10.font,
            ),
          ),
        ],
      ),
    );
  }
}
