import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/models/artists/artist_follow_response.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/artist_profile/models/artist_albums_response.dart';
import 'package:muxify/features/artist_profile/models/artist_new_releases_response.dart';
import 'package:muxify/features/artist_profile/models/artist_tracks_response.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';

class ArtistsRepository {
  ArtistsRepository({ApiRequester? requester})
    : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<ArtistFollowResponse> followArtist(String artistId) {
    return _requester.postJson(
      ApiConstants.artistFollowPath(artistId),
      null,
      ArtistFollowResponse.fromJson,
      authenticate: true,
    );
  }

  Future<ArtistFollowResponse> unfollowArtist(String artistId) {
    return _requester.deleteJson(
      ApiConstants.artistFollowPath(artistId),
      ArtistFollowResponse.fromJson,
      authenticate: true,
    );
  }

  Future<ArtistNewReleasesResponse> getArtistNewReleases(
    String artistId, {
    int days = 30,
    int page = 1,
    int pageSize = 20,
  }) {
    return _requester.getJson(
      ApiConstants.artistNewReleasesPath(artistId),
      ArtistNewReleasesResponse.fromJson,
      queryParameters: {
        'days': days.toString(),
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      authenticate: true,
    );
  }

  Future<ArtistTracksResponse> getArtistTracks(
    String artistId, {
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = {'page': page.toString(), 'pageSize': pageSize.toString()};
    if (sortBy != null) {
      query['sortBy'] = sortBy;
    }
    return _requester.getJson(
      ApiConstants.artistTracksPath(artistId),
      ArtistTracksResponse.fromJson,
      queryParameters: query,
      authenticate: true,
    );
  }

  Future<ArtistAlbumsResponse> getArtistAlbums(
    String artistId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return _requester.getJson(
      ApiConstants.artistAlbumsPath(artistId),
      ArtistAlbumsResponse.fromJson,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      authenticate: true,
    );
  }

  Future<List<GiftItem>> getGiftTypes() {
    return _requester.getJsonList(
      ApiConstants.giftTypesPath,
      GiftItem.fromJson,
      authenticate: true,
    );
  }

  Future<String> getTrackStreamUrl(String trackId) async {
    final response = await _requester.getJson(
      ApiConstants.trackStreamPath(trackId),
      (json) => json,
      authenticate: true,
    );

    Logger.debug('Track stream response for $trackId: $response');
    final candidates = _collectUrlCandidates(response);
    Logger.debug('Track stream URL candidates for $trackId: $candidates');

    for (final value in candidates) {
      final normalized = _normalizePlayableUrl(value);
      if (normalized.isNotEmpty) {
        Logger.debug('Track stream selected URL for $trackId: $normalized');
        return normalized;
      }
    }

    Logger.warning('No playable stream URL found for track: $trackId');
    return '';
  }

  Future<void> unlockTrack(String trackId) {
    return _requester.postNoContent(
      ApiConstants.trackUnlockPath(trackId),
      null,
      successStatus: ApiConstants.statusOk,
      alsoAcceptStatuses: const [ApiConstants.statusNoContent],
      authenticate: true,
    );
  }

  List<String> _collectUrlCandidates(dynamic node) {
    final out = <String>[];

    void walk(dynamic value) {
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) out.add(trimmed);
        return;
      }
      if (value is Map) {
        value.forEach((key, nested) {
          final keyText = key.toString().toLowerCase();
          if ((keyText.contains('url') || keyText.contains('stream')) &&
              nested is String) {
            final trimmed = nested.trim();
            if (trimmed.isNotEmpty) out.add(trimmed);
          }
          walk(nested);
        });
        return;
      }
      if (value is List) {
        for (final entry in value) {
          walk(entry);
        }
      }
    }

    walk(node);
    return out.toSet().toList();
  }

  String _normalizePlayableUrl(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) return '';

    // Skip API metadata/proxy endpoints that return JSON wrappers.
    if (value.startsWith('/api/v1/content/')) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return '';
      if (uri.path.startsWith('/api/v1/content/')) return '';
      return value;
    }

    // Handle potentially relative signed paths if backend ever returns them.
    if (value.startsWith('/')) {
      final resolved = ApiConstants.resolvePublicUrl(value);
      final resolvedUri = Uri.tryParse(resolved);
      if (resolvedUri == null) return '';
      if (resolvedUri.path.startsWith('/api/v1/content/')) return '';
      return resolved;
    }

    return '';
  }
}
