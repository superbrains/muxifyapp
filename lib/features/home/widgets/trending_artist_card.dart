import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/trending_artist.dart';

class TrendingArtistCard extends StatelessWidget {
  final TrendingArtist artist;
  final VoidCallback? onTap;
  final String? mediaType;

  const TrendingArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: SizedBox(
        width: 64.buttonHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 64.buttonHeight,
                  height: 64.buttonHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.withValues(alpha: 0.4),
                        Colors.purple.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppColors.glassyDark,
                      // When you have images: Image.network(artist.imageUrl, fit: BoxFit.cover)
                      child: Icon(
                        Icons.person,
                        size: 32.icon,
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                // Verified Badge
                if (artist.isVerified)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Image.asset(
                      mediaType == 'Videos'
                          ? 'assets/pngs/verify_green.png'
                          : 'assets/pngs/verify.png',
                      width: 24.icon,
                      height: 24.icon,
                    ),
                  ),
              ],
            ),
            8.column,
            Text(
              artist.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.font,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
