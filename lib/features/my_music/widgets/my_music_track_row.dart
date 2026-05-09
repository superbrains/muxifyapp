import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

enum MyMusicTrackTrailing {
  /// Inline "+" — opens "Add to playlist" sheet.
  addToPlaylist,

  /// Trash glyph — used inside playlist detail to remove the track.
  remove,

  /// Round selectable circle — used in the track picker.
  selectable,

  /// Static play glyph — non-interactive label for free preview rows.
  none,
}

/// Single row used across My Music screens (Library, Playlist Detail, Picker).
/// Tap on the row plays the track, the trailing slot is configurable via
/// [trailing]. Stays a single source of truth so spacing and typography are
/// consistent across the feature.
class MyMusicTrackRow extends StatelessWidget {
  const MyMusicTrackRow({
    super.key,
    required this.title,
    required this.artist,
    required this.coverArtUrl,
    required this.durationSeconds,
    required this.onTap,
    required this.trailing,
    this.isSelected = false,
    this.onTrailingTap,
    this.subtitleSuffix,
  });

  final String title;
  final String artist;
  final String? coverArtUrl;
  final int durationSeconds;
  final VoidCallback onTap;
  final MyMusicTrackTrailing trailing;
  final bool isSelected;
  final VoidCallback? onTrailingTap;

  /// Optional badge text shown after the artist name (e.g. "Free").
  final String? subtitleSuffix;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.radius),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.padding,
          vertical: 8.padding,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.radius),
              child: SizedBox(
                width: 48.maxWidth,
                height: 48.maxHeight,
                child: _buildArt(),
              ),
            ),
            14.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.isEmpty ? 'Untitled track' : title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15.font,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  3.column,
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          artist.isEmpty ? 'Unknown artist' : artist,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13.font,
                            color: AppColors.text.withValues(alpha: 0.55),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitleSuffix != null && subtitleSuffix!.isNotEmpty) ...[
                        6.row,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.padding,
                            vertical: 2.padding,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6.radius),
                          ),
                          child: Text(
                            subtitleSuffix!,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.font,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            10.row,
            Text(
              _formatDuration(durationSeconds),
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.font,
                color: AppColors.text.withValues(alpha: 0.5),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            8.row,
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildArt() {
    final url = (coverArtUrl ?? '').trim();
    if (url.isEmpty) {
      return Image.asset(
        'assets/pngs/follows.png',
        fit: BoxFit.cover,
      );
    }
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      placeholder: Image.asset('assets/pngs/follows.png', fit: BoxFit.cover),
      errorWidget: Image.asset('assets/pngs/follows.png', fit: BoxFit.cover),
    );
  }

  Widget _buildTrailing() {
    switch (trailing) {
      case MyMusicTrackTrailing.addToPlaylist:
        return _IconBubble(
          icon: Icons.playlist_add_rounded,
          onTap: onTrailingTap,
          accent: false,
        );
      case MyMusicTrackTrailing.remove:
        return _IconBubble(
          icon: Icons.remove_circle_outline_rounded,
          onTap: onTrailingTap,
          accent: false,
        );
      case MyMusicTrackTrailing.selectable:
        return _Checkbubble(
          isSelected: isSelected,
          onTap: onTrailingTap,
        );
      case MyMusicTrackTrailing.none:
        return const SizedBox.shrink();
    }
  }

  static String _formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Container(
        height: 36.maxHeight,
        width: 36.maxWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent
              ? AppColors.buttonColor
              : AppColors.glassyLight.withValues(alpha: 0.9),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(
          icon,
          size: 19.icon,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _Checkbubble extends StatelessWidget {
  const _Checkbubble({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 28.maxHeight,
        width: 28.maxWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.buttonColor
              : AppColors.glassyLight.withValues(alpha: 0.6),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonColor
                : AppColors.text.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Icon(Icons.check_rounded, size: 18.icon, color: AppColors.text)
            : const SizedBox.shrink(),
      ),
    );
  }
}
