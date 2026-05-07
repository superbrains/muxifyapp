import 'package:flutter/foundation.dart';
import 'package:muxify/core/models/artists/artist_follow_response.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/features/artist_profile/data/artists_repository.dart';
import 'package:muxify/features/artist_profile/models/artist_albums_response.dart';
import 'package:muxify/features/artist_profile/models/artist_new_releases_response.dart';
import 'package:muxify/features/artist_profile/models/artist_tracks_response.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';

class ArtistProfileProvider extends ChangeNotifier {
  ArtistProfileProvider({ArtistsRepository? repository})
    : _repository = repository ?? ArtistsRepository();

  final ArtistsRepository _repository;

  bool _isLoadingReleases = false;
  List<NewReleaseItem> _releases = [];
  String? _releasesError;

  bool get isLoadingReleases => _isLoadingReleases;
  List<NewReleaseItem> get releases => _releases;
  String? get releasesError => _releasesError;

  bool _isLoadingTracks = false;
  List<NewReleaseItem> _tracks = [];
  String? _tracksError;

  bool get isLoadingTracks => _isLoadingTracks;
  List<NewReleaseItem> get tracks => _tracks;
  String? get tracksError => _tracksError;

  bool _isLoadingAlbums = false;
  List<NewReleaseItem> _albums = [];
  String? _albumsError;

  bool get isLoadingAlbums => _isLoadingAlbums;
  List<NewReleaseItem> get albums => _albums;
  String? get albumsError => _albumsError;

  bool _isLoadingGifts = false;
  List<GiftItem> _gifts = [];
  String? _giftsError;

  bool get isLoadingGifts => _isLoadingGifts;
  List<GiftItem> get gifts => _gifts;
  String? get giftsError => _giftsError;

  bool _isActionInFlight = false;
  bool get isActionInFlight => _isActionInFlight;

  Future<void> loadArtistNewReleases(String artistId, String artistName) async {
    if (_isLoadingReleases) return;

    _isLoadingReleases = true;
    _releasesError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistNewReleases(artistId);
      _releases = response.items
          .map(
            (item) => NewReleaseItem.fromArtistNewReleaseItem(item, artistName),
          )
          .toList();
    } on ApiRequestException catch (e) {
      _releasesError = e.message;
    } catch (e) {
      _releasesError = 'An unexpected error occurred';
    } finally {
      _isLoadingReleases = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistTracks(String artistId, String artistName) async {
    if (_isLoadingTracks) return;

    _isLoadingTracks = true;
    _tracksError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistTracks(artistId);
      _tracks = response.items
          .map((item) => NewReleaseItem.fromArtistTrackItem(item, artistName))
          .toList();
    } on ApiRequestException catch (e) {
      _tracksError = e.message;
    } catch (e) {
      _tracksError = 'An unexpected error occurred';
    } finally {
      _isLoadingTracks = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistAlbums(String artistId, String artistName) async {
    if (_isLoadingAlbums) return;

    _isLoadingAlbums = true;
    _albumsError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistAlbums(artistId);
      _albums = response.items
          .map((item) => NewReleaseItem.fromArtistAlbumItem(item, artistName))
          .toList();
    } on ApiRequestException catch (e) {
      _albumsError = e.message;
    } catch (e) {
      _albumsError = 'An unexpected error occurred';
    } finally {
      _isLoadingAlbums = false;
      notifyListeners();
    }
  }

  Future<void> loadGiftTypes() async {
    if (_isLoadingGifts) return;

    _isLoadingGifts = true;
    _giftsError = null;
    notifyListeners();

    try {
      _gifts = await _repository.getGiftTypes();
    } on ApiRequestException catch (e) {
      _giftsError = e.message;
    } catch (e) {
      _giftsError = 'An unexpected error occurred';
    } finally {
      _isLoadingGifts = false;
      notifyListeners();
    }
  }

  Future<ArtistFollowResponse?> followArtist(String artistId) async {
    if (_isActionInFlight) return null;

    _isActionInFlight = true;
    notifyListeners();

    try {
      final response = await _repository.followArtist(artistId);
      return response;
    } catch (e) {
      return null;
    } finally {
      _isActionInFlight = false;
      notifyListeners();
    }
  }

  Future<ArtistFollowResponse?> unfollowArtist(String artistId) async {
    if (_isActionInFlight) return null;

    _isActionInFlight = true;
    notifyListeners();

    try {
      final response = await _repository.unfollowArtist(artistId);
      return response;
    } catch (e) {
      return null;
    } finally {
      _isActionInFlight = false;
      notifyListeners();
    }
  }

  // Add more methods for tracks and albums if needed
}
