import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/models/artists/artist_follow_response.dart';
import 'package:muxify/core/network/api_requester.dart';
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
}
