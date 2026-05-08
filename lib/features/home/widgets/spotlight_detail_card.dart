import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

class SpotlightDetailCard extends StatelessWidget {
  final SpotlightItem item;
  final VoidCallback? onTap;
  final VoidCallback? onUnlockTap;

  const SpotlightDetailCard({
    super.key,
    required this.item,
    this.onTap,
    this.onUnlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.only(right: 16.padding),
        height: 200.buttonHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Album Cover
            Expanded(
              child: SizedBox(
                width: 241.maxWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.radius),
                  child: _buildCover(),
                ),
              ),
            ),

            20.row,
            // Track Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  item.title,
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 18.font,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.column,
                // Artist
                Text(
                  item.artist,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.playCount.isNotEmpty) ...[
                  12.column,
                  // Play Count / metric
                  Text(
                    item.playCount,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (!item.isUnlocked) ...[
                  16.column,
                  UnlockButton(
                    text: 'Unlock',
                    iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                    onTap: onUnlockTap,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    final url = item.imageUrl?.trim() ?? '';
    if (url.isEmpty) return _placeholderCover();
    return CachedNetworkImage(
      imageUrl: ApiConstants.resolvePublicUrl(url),
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      placeholder: (_, __) => _placeholderCover(),
      errorWidget: (_, __, ___) => _placeholderCover(),
    );
  }

  Widget _placeholderCover() {
    return Image.asset(
      'assets/pngs/spotlight_placeholder.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    );
  }
}
