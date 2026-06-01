import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';

class ReleasePlaybackHelper {
  ReleasePlaybackHelper._();

  /// Reusable entry point for opening player from release cards.
  ///
  /// - [tryBackendStream] true: tries unlock + `/tracks/{id}/stream`.
  /// - [tryBackendStream] false: metadata-only navigation (disabled for track playback).
  static Future<void> openFromRelease(
    BuildContext context, {
    required NewReleaseItem release,
    required String albumName,
    String? artistId,
    bool tryBackendStream = true,
  }) async {
    if (release.id.trim().isEmpty) {
      await AppToast.showError('Track is missing an id.');
      return;
    }

    final provider = context.read<ArtistProfileProvider>();
    var resolvedRelease = release;
    String streamUrl = '';

    try {
      if (tryBackendStream) {
        // Locked tracks still open the player; the unlock confirmation (with
        // the real per-track coin cost) happens there via the lock icon.
        streamUrl = (await provider.getTrackStreamUrl(resolvedRelease.id)).trim();
        if (streamUrl.isEmpty) {
          await AppToast.showError('No stream URL found for this track.');
          return;
        }
      }
    } catch (_) {
      if (tryBackendStream) {
        await AppToast.showError('Could not play this track right now.');
        return;
      }
    }

    if (!context.mounted) return;
    final resolvedArtistId = (artistId ?? '').trim();
    final uri = Uri(
      path: AppRouter.musicPlayer,
      queryParameters: {
        'trackId': resolvedRelease.id,
        'title': resolvedRelease.title,
        'artistName': resolvedRelease.artist,
        if (resolvedArtistId.isNotEmpty) 'artistId': resolvedArtistId,
        'albumName': albumName,
        'backgroundImageUrl': resolvedRelease.coverImageUrl,
        if (streamUrl.isNotEmpty) 'audioUrl': streamUrl,
        'isUnlocked': resolvedRelease.isUnlocked.toString(),
        'unlockCostCoins': resolvedRelease.unlockCostCoins.toString(),
      },
    );

    context.push(uri.toString());
  }
}
