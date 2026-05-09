import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/music_player/models/playlist_summary.dart';
import 'package:muxify/features/music_player/models/track_like_status.dart';
import 'package:muxify/features/music_player/models/track_share_info.dart';

/// Repository for music-player engagement actions: like/share/unlock/playlist.
/// Mirrors the pattern used by [ArtistsRepository] — wraps the shared
/// [ApiRequester] which already handles auth headers and 401 refresh.
class MusicPlayerRepository {
  MusicPlayerRepository({ApiRequester? requester})
    : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<TrackLikeStatus> toggleLike(String trackId) {
    return _requester.postJson(
      ApiConstants.trackLikePath(trackId),
      null,
      TrackLikeStatus.fromJson,
      authenticate: true,
    );
  }

  Future<TrackLikeStatus> getLikeStatus(String trackId) {
    return _requester.getJson(
      ApiConstants.trackLikeStatusPath(trackId),
      TrackLikeStatus.fromJson,
      authenticate: true,
    );
  }

  Future<TrackShareInfo> shareTrack(String trackId) {
    return _requester.postJson(
      ApiConstants.trackSharePath(trackId),
      null,
      TrackShareInfo.fromJson,
      authenticate: true,
    );
  }

  /// Calls `POST /api/v1/content/tracks/{id}/unlock`. Backend responds with
  /// 200 + UnlockContentResponse on success; we don't need the body for the
  /// player UI today, so [postNoContent] keeps the call light.
  Future<void> unlockTrack(String trackId) {
    return _requester.postNoContent(
      ApiConstants.trackUnlockPath(trackId),
      null,
      successStatus: ApiConstants.statusOk,
      alsoAcceptStatuses: const [ApiConstants.statusNoContent],
      authenticate: true,
    );
  }

  /// Lists the current user's playlists. Backend returns up to [pageSize] in a
  /// single page; the player picker only needs the first page since most users
  /// have a small number of playlists.
  Future<PlaylistList> getMyPlaylists({int page = 1, int pageSize = 50}) {
    return _requester.getJson(
      ApiConstants.playlistsPath,
      PlaylistList.fromJson,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      authenticate: true,
    );
  }

  /// Adds [trackId] to the playlist identified by [playlistId]. The backend
  /// returns the updated PlaylistDetailDto on success; we drop the body
  /// because the picker only cares about the success/failure outcome.
  Future<void> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) {
    return _requester.postNoContent(
      ApiConstants.playlistTracksPath(playlistId),
      {
        'trackIds': [trackId],
      },
      successStatus: ApiConstants.statusOk,
      alsoAcceptStatuses: const [ApiConstants.statusNoContent],
      authenticate: true,
    );
  }

  /// Creates a new playlist owned by the current user, optionally seeded with
  /// [initialTrackIds]. Returns the new playlist's id so the caller can chain
  /// follow-up operations (e.g. adding a track right after creation).
  Future<PlaylistSummary> createPlaylist({
    required String name,
    String? description,
    bool isPublic = true,
    List<String>? initialTrackIds,
  }) {
    final body = <String, dynamic>{
      'name': name,
      'isPublic': isPublic,
      'isCollaborative': false,
    };
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }
    if (initialTrackIds != null && initialTrackIds.isNotEmpty) {
      body['initialTrackIds'] = initialTrackIds;
    }

    return _requester.postJson(
      ApiConstants.playlistsPath,
      body,
      PlaylistSummary.fromJson,
      successStatus: ApiConstants.statusCreated,
      authenticate: true,
    );
  }
}
