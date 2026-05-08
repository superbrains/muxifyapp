import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';

class GenreSongItemWidget extends StatelessWidget {
  final GenreSongItem item;
  final VoidCallback? onTap;
  final VoidCallback? onPlayUnlockTap;
  final bool isMoreButtonVisible;
  final VoidCallback? onMenueTap;

  const GenreSongItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onPlayUnlockTap,
    this.isMoreButtonVisible = false,
    this.onMenueTap,
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
          Container(
            width: 40.maxWidth,
            height: 40.maxHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.radius),
              child: _buildAlbumArt(item.albumArtUrl),
            ),
          ),
          16.row,
          // Song Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song Title
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
                4.column,
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
          // Play/Unlock Button
          _buildPlayUnlockButton(),
          // 10.row,
          if (isMoreButtonVisible)
            IconButton(
              padding: EdgeInsets.zero,   
              onPressed: () {
                HapticFeedback.lightImpact();
                onMenueTap?.call();
              },
              icon: Icon(
                Icons.more_vert,
                size: 24.icon,
                color: AppColors.text.withValues(alpha: 0.65),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String url) {
    final value = url.trim();
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

  Widget _buildPlayUnlockButton() {
    if (item.isUnlocked) {
      // Play Button
      return UnlockButton(
        padding: EdgeInsets.symmetric(
          horizontal: 10.padding,
          vertical: 6.padding,
        ),
        onTap: onPlayUnlockTap,
        text: 'Play',
        iconPath: 'assets/pngs/play_red.png',
      );
    } else {
      // Unlock Button
      return UnlockButton(
        padding: EdgeInsets.symmetric(
          horizontal: 6.padding,
          vertical: 5.padding,
        ),
        onTap: onPlayUnlockTap,
        text: 'Unlock',
        iconPath: 'assets/pngs/Bitcoin_musixfy.png',
      );
    }
  }
}
