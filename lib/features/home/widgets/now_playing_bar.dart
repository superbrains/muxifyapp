import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/now_playing_item.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

class NowPlayingBar extends StatelessWidget {
  final NowPlayingItem? currentTrack;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPauseTap;
  final VoidCallback? onUnlockTap;

  const NowPlayingBar({
    super.key,
    this.currentTrack,
    this.onTap,
    this.onPlayPauseTap,
    this.onUnlockTap,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if no track is playing
    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        // margin: EdgeInsets.only(bottom: 16.padding),
        padding: EdgeInsets.all(12.padding),
        decoration: BoxDecoration(
          color: AppColors.nowPlayingBackground.withValues(alpha: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
              child:
                  // Album Art
                  SizedBox(
                    width: 61.maxWidth,
                    height: 41.maxHeight,

                    child: Image.asset(
                      currentTrack!.albumArtUrl ??
                          'assets/pngs/active_play.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
            ),
            12.row,
            // Track Information
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap?.call();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Song Title
                    Text(
                      currentTrack!.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.font,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.column,
                    // Artist Name
                    Text(
                      currentTrack!.artist,
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
              ),
            ),
            12.row,
            // Unlock Button (if not unlocked)
            if (!currentTrack!.isUnlocked)
              UnlockButton(
                text: currentTrack!.isPlaying ? 'Unlock' : 'Send Gift',
                iconPath: currentTrack!.isPlaying
                    ? "assets/pngs/Bitcoin_musixfy.png"
                    : "assets/pngs/gift.png",
                onTap: onUnlockTap,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.padding,
                  vertical: 6.padding,
                ),
              ),
            12.row,
            // Play/Pause Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onPlayPauseTap?.call();
              },
              child: Image.asset(
                currentTrack!.isPlaying
                    ? "assets/pngs/pause.png"
                    : "assets/pngs/play.png",
                color: AppColors.text,
                width: 27.icon,
                height: 27.icon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
