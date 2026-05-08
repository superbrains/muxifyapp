import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/followed_item.dart';

class FollowedItemCard extends StatelessWidget {
  final FollowedItem item;
  final VoidCallback? onTap;

  const FollowedItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art - Square
          Container(
            width: double.infinity,
            height: 100.buttonHeight, // Square aspect ratio
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.radius),
              child: _buildCover(),
            ),
          ),
          8.column,
          // Song Title - Larger, bolder font
          Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          4.column,
          // Artist Name - Smaller, lighter font
          Text(
            item.artist,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.font,
              fontWeight: FontWeight.w400,
              color: AppColors.text.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    final url = item.imageUrl?.trim() ?? '';
    if (url.isEmpty) return _placeholderCover();
    return CachedNetworkImage(
      imageUrl: ApiConstants.resolvePublicUrl(url),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => _placeholderCover(),
      errorWidget: (_, __, ___) => _placeholderCover(),
    );
  }

  Widget _placeholderCover() {
    return Image.asset(
      'assets/pngs/follows.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
