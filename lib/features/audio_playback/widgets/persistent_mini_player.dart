import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';

/// Docked mini-player that mirrors the in-app design of the legacy
/// `NowPlayingBar` but is driven entirely by [AudioProvider]. Tapping the bar
/// pushes the full [MusicPlayerScreen]; the play/pause button toggles
/// playback in place. A thin progress line at the top reflects position.
class PersistentMiniPlayer extends StatelessWidget {
  const PersistentMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final track = audio.currentTrack;
    if (!audio.hasActiveTrack || track == null) {
      return const SizedBox.shrink();
    }

    final duration = audio.duration.inMilliseconds;
    final position = audio.position.inMilliseconds.clamp(0, duration);
    final progress = duration > 0 ? position / duration : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.nowPlayingBackground.withValues(alpha: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProgressLine(progress: progress.clamp(0.0, 1.0)),
          Padding(
            padding: EdgeInsets.all(12.padding),
            child: Row(
              children: [
                _Artwork(track: track, onTap: () => _openFullPlayer(context)),
                12.row,
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openFullPlayer(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14.font,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        2.column,
                        Text(
                          track.artist,
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
                _MiniControl(
                  icon: Icons.skip_previous,
                  size: 24.icon,
                  onTap: audio.previous,
                ),
                _MiniControl(
                  icon: audio.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 30.icon,
                  onTap: audio.togglePlayPause,
                ),
                _MiniControl(
                  icon: Icons.skip_next,
                  size: 24.icon,
                  onTap: audio.next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openFullPlayer(BuildContext context) {
    HapticFeedback.lightImpact();
    final loc = GoRouterState.of(context).uri.path;
    if (loc == AppRouter.musicPlayer) return;
    context.pushNamed('music-player');
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.border,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppColors.text.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.text),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.track, required this.onTap});
  final Track track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.radius),
        child: SizedBox(
          width: 41.maxWidth,
          height: 41.maxHeight,
          child: _ArtworkImage(url: track.artworkUrl),
        ),
      ),
    );
  }
}

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final raw = (url ?? '').trim();
    if (raw.isEmpty) {
      return _fallback();
    }
    final lower = raw.toLowerCase();
    final isRemote =
        lower.startsWith('http://') ||
            lower.startsWith('https://') ||
            raw.startsWith('/');
    if (isRemote) {
      return Image.network(
        ApiConstants.resolvePublicUrl(raw),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return Image.asset(
      raw,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() => Image.asset(
        'assets/pngs/active_play.png',
        fit: BoxFit.cover,
      );
}

class _MiniControl extends StatelessWidget {
  const _MiniControl({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.padding),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Icon(icon, color: AppColors.text, size: size),
      ),
    );
  }
}
