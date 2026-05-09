import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/my_music/models/local_playlist.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Spotify-style 2x2 cover collage assembled from the first four tracks'
/// cover art. When fewer than four covers are available, the missing tiles
/// are filled by a brand-aligned red→black gradient with the playlist's
/// initial — keeps the brand identity present in empty/sparse playlists.
class PlaylistCoverMosaic extends StatelessWidget {
  const PlaylistCoverMosaic({
    super.key,
    required this.playlist,
    required this.size,
    this.borderRadius,
  });

  final LocalPlaylist playlist;
  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12.radius);
    final covers = playlist.tracks
        .map((t) => (t.coverArtUrl ?? '').trim())
        .where((url) => url.isNotEmpty)
        .take(4)
        .toList(growable: false);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: covers.isEmpty
            ? _BrandTile(initial: _initial(playlist.name), full: true)
            : _Mosaic(covers: covers, initial: _initial(playlist.name)),
      ),
    );
  }

  static String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'M';
    return trimmed.characters.first.toUpperCase();
  }
}

class _Mosaic extends StatelessWidget {
  const _Mosaic({required this.covers, required this.initial});

  final List<String> covers;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (var i = 0; i < 4; i++)
        i < covers.length
            ? _CoverTile(url: covers[i])
            : _BrandTile(initial: initial),
    ];

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: tiles[0]),
              Expanded(child: tiles[1]),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: tiles[2]),
              Expanded(child: tiles[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: const _BrandTile(initial: ''),
      errorWidget: const _BrandTile(initial: ''),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.initial, this.full = false});

  final String initial;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.2, -0.4),
          radius: 1.1,
          colors: [
            AppColors.headerGradient,
            AppColors.background,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: full && initial.isNotEmpty
          ? Text(
              initial,
              style: AppTextStyles.displayText.copyWith(
                fontSize: 64.font,
                color: AppColors.text.withValues(alpha: 0.92),
                shadows: [
                  Shadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.6),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
