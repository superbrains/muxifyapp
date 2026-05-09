import 'package:flutter/foundation.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/music_player/data/music_player_repository.dart';
import 'package:muxify/features/music_player/models/playlist_summary.dart';
import 'package:muxify/features/music_player/models/track_like_status.dart';
import 'package:muxify/features/music_player/models/track_share_info.dart';

/// Owns the per-track engagement state surfaced by the music player UI:
/// like-status (heart), share metadata, in-flight flags. Kept separate from
/// [AudioProvider] so playback concerns and engagement concerns don't
/// step on each other.
class MusicPlayerInteractionProvider extends ChangeNotifier {
  MusicPlayerInteractionProvider({MusicPlayerRepository? repository})
    : _repository = repository ?? MusicPlayerRepository();

  final MusicPlayerRepository _repository;

  /// Cache of like-status per trackId. Survives screen navigation so the
  /// heart icon stays in sync without re-fetching on every rebuild.
  final Map<String, TrackLikeStatus> _likeStatus = {};

  /// Tracks where a like-toggle is currently in flight. Used to disable the
  /// button so rapid taps don't issue duplicate POSTs.
  final Set<String> _likeInFlight = <String>{};

  /// Tracks where a share request is currently in flight.
  final Set<String> _shareInFlight = <String>{};

  bool isLiked(String trackId) {
    final id = trackId.trim();
    if (id.isEmpty) return false;
    return _likeStatus[id]?.liked ?? false;
  }

  int likeCount(String trackId) {
    final id = trackId.trim();
    if (id.isEmpty) return 0;
    return _likeStatus[id]?.likeCount ?? 0;
  }

  bool isLikeInFlight(String trackId) => _likeInFlight.contains(trackId.trim());

  bool isShareInFlight(String trackId) =>
      _shareInFlight.contains(trackId.trim());

  /// Pulls the latest like-status for [trackId] and stores it in the cache.
  /// Called by the player screen when a track loads. Failures are logged and
  /// swallowed — the heart simply stays in its previous state.
  Future<void> hydrateLikeStatus(String trackId) async {
    final id = trackId.trim();
    if (id.isEmpty) return;
    try {
      final status = await _repository.getLikeStatus(id);
      _likeStatus[id] = status;
      notifyListeners();
    } catch (e, st) {
      Logger.warning('Failed to hydrate like status for $id: $e');
      Logger.debug(st.toString());
    }
  }

  /// Optimistically flips the heart and calls the toggle endpoint. If the
  /// call fails the local state is rolled back so the UI stays truthful.
  /// Returns true on success, false on failure.
  Future<bool> toggleLike(String trackId) async {
    final id = trackId.trim();
    if (id.isEmpty) return false;
    if (_likeInFlight.contains(id)) return false;

    final previous =
        _likeStatus[id] ??
        TrackLikeStatus(trackId: id, liked: false, likeCount: 0);

    // Optimistic flip.
    _likeInFlight.add(id);
    _likeStatus[id] = TrackLikeStatus(
      trackId: id,
      liked: !previous.liked,
      likeCount: (previous.likeCount + (previous.liked ? -1 : 1))
          .clamp(0, 1 << 31),
    );
    notifyListeners();

    try {
      final updated = await _repository.toggleLike(id);
      _likeStatus[id] = updated;
      return true;
    } catch (e, st) {
      // Roll back on failure so the icon doesn't lie about server state.
      _likeStatus[id] = previous;
      Logger.error('Toggle like failed for $id', e, st);
      return false;
    } finally {
      _likeInFlight.remove(id);
      notifyListeners();
    }
  }

  /// Calls the share endpoint and returns the metadata the OS share sheet
  /// should use. Throws on failure so the caller can show a toast.
  Future<TrackShareInfo> shareTrack(String trackId) async {
    final id = trackId.trim();
    if (id.isEmpty) {
      throw ArgumentError('Empty trackId');
    }
    if (_shareInFlight.contains(id)) {
      throw StateError('Share already in flight');
    }
    _shareInFlight.add(id);
    notifyListeners();
    try {
      return await _repository.shareTrack(id);
    } finally {
      _shareInFlight.remove(id);
      notifyListeners();
    }
  }

  /// Loads the user's playlists for the picker. Throws on failure.
  Future<List<PlaylistSummary>> getMyPlaylists() async {
    final result = await _repository.getMyPlaylists();
    return result.items;
  }

  /// Adds a track to a playlist. Throws on failure.
  Future<void> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) {
    return _repository.addTrackToPlaylist(
      playlistId: playlistId,
      trackId: trackId,
    );
  }

  /// Creates a new playlist seeded with [trackId]. Returns the new playlist's
  /// summary so the caller can show it in the picker.
  Future<PlaylistSummary> createPlaylistWithTrack({
    required String name,
    required String trackId,
  }) {
    return _repository.createPlaylist(
      name: name,
      initialTrackIds: [trackId],
    );
  }

  /// Calls the coin-based unlock endpoint for [trackId]. Throws on failure.
  Future<void> unlockTrack(String trackId) {
    return _repository.unlockTrack(trackId);
  }
}
