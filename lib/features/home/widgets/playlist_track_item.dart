import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/track_item.dart';

class PlaylistTrackItem extends StatelessWidget {
  final TrackItem track;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const PlaylistTrackItem({
    super.key,
    required this.track,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: SizedBox(
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 32.buttonHeight,
              height: 32.buttonHeight,

              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.radius),
                child: Container(
                  // color: AppColors.glassyDark,
                  // Image.network(track.imageUrl, fit: BoxFit.cover),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.radius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.withValues(alpha: 0.4),
                        Colors.red.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            12.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.font,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.column,
                  Text(
                    track.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.font,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Menu Icon 
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onMenuTap?.call();
              },
              child: Icon(
                Icons.more_vert,
                color: AppColors.text.withValues(alpha: 0.7),
                size: 24.icon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
