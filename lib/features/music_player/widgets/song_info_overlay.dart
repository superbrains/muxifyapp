import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/circular_icon_button.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/features/music_player/widgets/lyrics_button_widget.dart';

class SongInfoOverlay extends StatelessWidget {
  final String songTitle;
  final String artistName;
  final bool isUnlocked;
  final bool isLiked;
  final bool isAdded;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleAdd;
  final VoidCallback onShare;
  final VoidCallback onUnlockSong;
  final VoidCallback onShowLyrics;

  const SongInfoOverlay({
    super.key,
    required this.songTitle,
    required this.artistName,
    required this.isUnlocked,
    required this.isLiked,
    required this.isAdded,
    required this.onToggleLike,
    required this.onToggleAdd,
    required this.onShare,
    required this.onUnlockSong,
    required this.onShowLyrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  songTitle,
                  style: AppTextStyles.specialText.copyWith(
                    color: AppColors.text,
                    fontSize: 26.font,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  artistName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.text.withValues(alpha: 0.64),
                    fontSize: 18.font,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Spacer(),
            LyricsButtonWidget(
              icon: Icons.notes_rounded,
              text: 'List',
              onTap: onShowLyrics,
            ),
          ],
        ),
        20.column,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Unlock Song button for locked songs
            if (!isUnlocked) ...[
              UnlockButton(
                backgroundColor: AppColors.text.withValues(alpha: 0.75),
                height: 44.buttonHeight,
                width: 158.maxWidth,
                text: 'Unlock Song',
                iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                iconSize: 32.icon,
                spacing: 6.padding,
                borderRadius: 20.radius,
                border: Border.all(width: 1.45.border, color: AppColors.text),
                onTap: onUnlockSong,
              ),
              const Spacer(),
            ],

            // Action buttons
            CircularIconButton(
              onTap: onToggleLike,
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
            ),
            16.row,
            CircularIconButton(
              onTap: onToggleAdd,
              icon: isAdded ? Icons.check : Icons.add,
            ),
            16.row,
            CircularIconButton(onTap: onShare, icon: Icons.share),
          ],
        ),
      ],
    );
  }
}

