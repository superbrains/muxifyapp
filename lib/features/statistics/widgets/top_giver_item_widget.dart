import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/top_giver_item.dart';
import 'package:muxify/shared/widgets/gift_worth_widget.dart';

class TopGiverItemWidget extends StatelessWidget {
  final TopGiverItem item;
  final VoidCallback? onTap;

  const TopGiverItemWidget({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Avatar
          _buildAvatar(),
          11.row,
          // User Info and Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Username and Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.username,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 15.font,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    10.row,
                    _buildBadges(),
                  ],
                ),
                5.column,
                // Associated Artists
                Text(
                  item.associatedArtists,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Gift Worth Section
          GiftWorthWidget(
            amount: item.giftWorth,
            label: 'Gift Worth',
            iconSize: 22.icon,
            amountFontSize: 18.font,
            labelFontSize: 12.font,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 38.maxWidth,
      height: 38.maxHeight,
      decoration: BoxDecoration(
        shape: BoxShape.circle,

        image: DecorationImage(
          image: AssetImage(item.avatarUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: item.badges.map((badge) {
        return Container(
          margin: EdgeInsets.only(right: 4.padding),
          child: Image.asset(
            badge.imageUrl,
            width: 14.maxWidth,
            height: 15.maxHeight,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }
}
