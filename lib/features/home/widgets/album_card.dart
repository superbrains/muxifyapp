import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/album_item.dart';

class AlbumCard extends StatelessWidget {
  final AlbumItem album;
  final VoidCallback? onTap;

  const AlbumCard({super.key, required this.album, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassyDark,
          borderRadius: BorderRadius.circular(12.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover
            Container(
              height: 140.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.radius),
                  topRight: Radius.circular(12.radius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.red.withOpacity(0.3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder for album image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.radius),
                        topRight: Radius.circular(12.radius),
                      ),
                      color: AppColors.glassyDark,
                    ),
                  ),
                  // Play button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 32.icon,
                      height: 32.icon,
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppColors.text,
                        size: 18.icon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Album Info
            Padding(
              padding: EdgeInsets.all(12.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.font,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.column,
                  Text(
                    album.artist,
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
          ],
        ),
      ),
    );
  }
}
