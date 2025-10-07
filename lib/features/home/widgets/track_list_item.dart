import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/track_item.dart';

class TrackListItem extends StatelessWidget {
  final TrackItem track;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const TrackListItem({
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
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8.padding,
          horizontal: 12.padding,
        ),
        child: Row(
          children: [
            // Album Thumbnail
            Container(
              width: 48.buttonHeight,
              height: 48.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.3),
                    Colors.pink.withOpacity(0.3),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.radius),
                child: Container(
                  color: AppColors.glassyDark,
                  // When you have images: Image.network(track.imageUrl, fit: BoxFit.cover)
                ),
              ),
            ),
            12.row,
            // Track Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.font,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.column,
                  Text(
                    track.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withOpacity(0.6),
                      fontSize: 12.font,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Menu Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onMenuTap?.call();
              },
              child: Icon(
                Icons.more_vert,
                color: AppColors.text.withOpacity(0.6),
                size: 20.icon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
