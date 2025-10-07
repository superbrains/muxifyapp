import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/widgets/playlist_track_item.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistItem playlist;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSeeAllTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.onPlayTap,
    this.onFavoriteTap,
    this.onMenuTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 288.maxWidth,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Album Art and Details
            Container(
              padding: EdgeInsets.only(
                left: 16.padding,
                right: 16.padding,
                top: 16.padding,
                bottom: 8.padding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.radius),
                  topRight: Radius.circular(16.radius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  transform: const GradientRotation(1.5),
                  colors: [
                    const Color(0xFF141414),
                    const Color(0xFF141414).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.4, 0.8],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album Art - 106x106
                  Container(
                    width: 106.buttonHeight,
                    height: 106.buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.radius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withValues(alpha: 0.4),
                          Colors.blue.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.radius),

                      // color: AppColors.glassyDark,
                      // Image.network(playlist.imageUrl, fit: BoxFit.cover),
                      child: Center(
                        child: Text(
                          'AFROBEAT',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.font,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  16.row,
                  // Album Details and Icons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Album Title and Song Count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title - 20px, weight 700
                            Text(
                              playlist.title,
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 20.font,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            8.column,
                            // Song Count - 12px, weight 500
                            Text(
                              playlist.songCount,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12.font,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        16.column,
                        // Icons Row
                        Row(
                          children: [
                            // Favorite Icon - 24px
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onFavoriteTap?.call();
                              },
                              child: Icon(
                                playlist.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: playlist.isFavorite
                                    ? Colors.red
                                    : AppColors.text.withOpacity(0.7),
                                size: 24.icon,
                              ),
                            ),
                            8.row,
                            // Menu Icon - 24px
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onMenuTap?.call();
                              },
                              child: Icon(
                                Icons.more_vert,
                                color: AppColors.text.withOpacity(0.7),
                                size: 24.icon,
                              ),
                            ),
                            Spacer(),
                            // Play Button - 40x40 with 14px icon
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onPlayTap?.call();
                              },
                              child: Container(
                                width: 40.buttonHeight,
                                height: 40.buttonHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.text,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: AppColors.background,
                                  size: 16.icon,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Track List
            Column(
              children: [
                // 16.column,
                // Track Items with ListView.separated
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.padding),
                  scrollDirection: Axis.vertical,

                  itemCount: playlist.tracks.take(4).length,
                  separatorBuilder: (context, index) => 16.column,
                  itemBuilder: (context, index) {
                    final track = playlist.tracks[index];
                    return PlaylistTrackItem(
                      track: track,
                      onTap: () {
                        // TODO: Navigate to track detail or play track
                      },
                      onMenuTap: () {
                        // TODO: Show track options menu
                      },
                    );
                  },
                ),
                // 16.column,
                // See All Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSeeAllTap?.call();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: 16.padding,
                        bottom: 16.padding,
                      ),
                      alignment: Alignment.center,
                      width: 64.maxWidth,
                      height: 30.buttonHeight,
                      // padding: EdgeInsets.symmetric(vertical: 12.padding),
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(25.radius),
                      ),
                      child: Text(
                        'See All',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,

                          fontSize: 12.font,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ),
                16.column,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
