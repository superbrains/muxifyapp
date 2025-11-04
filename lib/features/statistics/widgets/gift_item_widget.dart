import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/sticker_text.dart';

class GiftItemWidget extends StatelessWidget {
  final GiftItem item;
  final VoidCallback? onTap;

  const GiftItemWidget({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        children: [
          // Stack with background, emoji, and sticker text
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Allow overflow for sticker text
            children: [
              // Background image
              Container(
                width: 68.maxWidth,
                height: 68.maxHeight,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(12.radius),
                  image: DecorationImage(
                    image: AssetImage(item.backgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // Emoji in the center
              Image.asset(
                item.emojiImage,
                width: 40.maxWidth,
                height: 40.maxHeight,
              ),
              // Sticker text overlay at bottom - positioned to extend outside
              Positioned(
                bottom: -11.padding, // Negative bottom to extend outside
                child: StickerText(
                  text: item.stickerText,
                  fontSize: 16.font,
                  textColor: Colors.white,
                  strokeColor: Colors.black,
                  strokeWidth: 1.35.border,
                  rotation: 0,
                ),
              ),
            ],
          ),
          13.column,
          // Gift name
          Text(
            item.name,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.font,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // 8.column,
          // // Unlock button
          // UnlockButton(
          //   text: 'Gift',
          //   onTap: onTap,
          //   backgroundColor: AppColors.toggleSelected,
          //   textColor: AppColors.text,
          //   borderRadius: 15.radius,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 12.padding,
          //     vertical: 6.padding,
          //   ),
          // ),
          2.column,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/pngs/Bitcoin_musixfy.png',
                width: 12.icon,
                height: 12.icon,
              ),
              8.row,
              Text(
                "m${item.amount?.toString()}",
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 8.font,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
