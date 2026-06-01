import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/album_item.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

class AlbumItemWidget extends StatelessWidget {
  final AlbumItem item;
  final VoidCallback? onTap;

  const AlbumItemWidget({
    super.key,
    required this.item,
    this.onTap,
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
              child: _buildAlbumArt(item.albumArtUrl),
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
          // Play Count Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/pngs/play.png',
                width: 14.icon,
                height: 14.icon,
              ),
              8.row,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPlays(item.playCount),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16.font,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Plays',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPlays(int count) {
    if (count <= 0) return '0';
    return NumberFormat.compact().format(count);
  }

  Widget _buildAlbumArt(String? url) {
    final value = (url ?? '').trim();
    if (value.isEmpty) {
      return Image.asset(
        'assets/pngs/follows.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return AuthNetworkImage(
      path: value,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: Image.asset(
        'assets/pngs/follows.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
      errorWidget: Image.asset(
        'assets/pngs/follows.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
