import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

/// Bottom sheet showing the player's current queue. Tap a row to jump
/// playback to that track. Locked rows are dimmed and offer an Unlock CTA.
class QueueListSheet extends StatelessWidget {
  /// Invoked with the locked track when its Unlock CTA is tapped.
  final void Function(Track track)? onUnlockTrack;

  const QueueListSheet({super.key, this.onUnlockTrack});

  static Future<void> show(
    BuildContext context, {
    void Function(Track track)? onUnlockTrack,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.radius),
        ),
      ),
      builder: (_) => QueueListSheet(onUnlockTrack: onUnlockTrack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final unlocked = context.watch<UnlockedContentProvider>();
    final queue = audio.queue;
    final currentId = audio.currentTrack?.id;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            16.column,
            Container(
              width: 40.maxWidth,
              height: 4.maxHeight,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.radius),
              ),
            ),
            16.column,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.padding),
              child: Row(
                children: [
                  Text(
                    'Up Next',
                    style: AppTextStyles.specialText.copyWith(
                      color: AppColors.text,
                      fontSize: 20.font,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${queue.length} ${queue.length == 1 ? 'song' : 'songs'}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                      fontSize: 14.font,
                    ),
                  ),
                ],
              ),
            ),
            12.column,
            Flexible(
              child: queue.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(22.padding),
                      child: Text(
                        'The queue is empty.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.padding,
                        vertical: 8.padding,
                      ),
                      itemCount: queue.length,
                      separatorBuilder: (_, _) => 8.column,
                      itemBuilder: (context, index) {
                        final t = queue[index];
                        final isCurrent = t.id == currentId;
                        final isUnlocked =
                            t.isUnlocked || unlocked.isUnlocked(t.id);
                        return _QueueRow(
                          track: t,
                          isCurrent: isCurrent,
                          isUnlocked: isUnlocked,
                          onTap: () {
                            audio.seekToIndex(index);
                            Navigator.of(context).pop();
                          },
                          onUnlock: onUnlockTrack == null
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  onUnlockTrack!(t);
                                },
                        );
                      },
                    ),
            ),
            12.column,
          ],
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final bool isUnlocked;
  final VoidCallback onTap;
  final VoidCallback? onUnlock;

  const _QueueRow({
    required this.track,
    required this.isCurrent,
    required this.isUnlocked,
    required this.onTap,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final cover = (track.artworkUrl ?? '').trim();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.radius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.padding),
        child: Row(
          children: [
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.radius),
                child: SizedBox(
                  width: 48.maxWidth,
                  height: 48.maxHeight,
                  child: _cover(cover),
                ),
              ),
            ),
            12.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title.isEmpty ? 'Unknown title' : track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isCurrent
                          ? AppColors.green
                          : AppColors.text,
                      fontSize: 16.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    track.artist.isEmpty ? 'Unknown artist' : track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                      fontSize: 13.font,
                    ),
                  ),
                ],
              ),
            ),
            12.row,
            if (!isUnlocked)
              UnlockButton(
                text: 'Unlock',
                iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                onTap: onUnlock,
                backgroundColor: AppColors.toggleSelected,
                iconColor: AppColors.buttonColor,
                iconSize: 14.icon,
                fontSize: 12.font,
                borderRadius: 16.radius,
                padding: EdgeInsets.symmetric(
                  horizontal: 10.padding,
                  vertical: 6.padding,
                ),
              )
            else if (isCurrent)
              Icon(
                Icons.equalizer,
                color: AppColors.green,
                size: 20.icon,
              ),
          ],
        ),
      ),
    );
  }

  Widget _cover(String source) {
    final fallback = Container(color: AppColors.background);
    if (source.isEmpty) return fallback;
    return AuthNetworkImage(
      path: source,
      fit: BoxFit.cover,
      placeholder: fallback,
      errorWidget: fallback,
    );
  }
}
