import 'package:flutter/foundation.dart';
import 'package:muxify/core/models/artists/artist_follow_response.dart';
import 'package:muxify/core/models/gifts/send_gift_response.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/features/artist_profile/data/artists_repository.dart';
import 'package:muxify/features/artist_profile/models/artist_public_profile.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/providers/home_provider.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';

class ArtistProfileProvider extends ChangeNotifier {
  ArtistProfileProvider({ArtistsRepository? repository})
    : _repository = repository ?? ArtistsRepository();

  final ArtistsRepository _repository;

  ArtistPublicProfile? _artistProfile;
  bool _isLoadingProfile = false;
  String? _profileError;

  ArtistPublicProfile? get artistProfile => _artistProfile;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get profileError => _profileError;

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

  bool _isLoadingVideos = false;
  List<NewReleaseItem> _videos = [];
  String? _videosError;

  bool get isLoadingVideos => _isLoadingVideos;
  List<NewReleaseItem> get videos => _videos;
  String? get videosError => _videosError;

  bool _isLoadingSimilarArtists = false;
  List<TrendingArtist> _similarArtists = const [];
  String? _similarArtistsError;

  bool get isLoadingSimilarArtists => _isLoadingSimilarArtists;
  List<TrendingArtist> get similarArtists => _similarArtists;
  String? get similarArtistsError => _similarArtistsError;

  bool _isLoadingGifts = false;
  List<GiftItem> _gifts = [];
  String? _giftsError;

  bool get isLoadingGifts => _isLoadingGifts;
  List<GiftItem> get gifts => _gifts;
  String? get giftsError => _giftsError;

  bool _isActionInFlight = false;
  bool get isActionInFlight => _isActionInFlight;
  bool _isPlaybackActionInFlight = false;
  bool get isPlaybackActionInFlight => _isPlaybackActionInFlight;

  /// Set of track/video IDs the user has already unlocked, kept in sync from
  /// [UnlockedContentProvider] via the proxy provider in `main.dart`.
  /// Applied to every freshly loaded list so cards render "Play" instead of
  /// "Unlock" without waiting for the backend to reflect the unlock.
  Set<String> _persistedUnlockedIds = const <String>{};

  /// Keeps the persisted-unlock set in sync and re-applies it across all
  /// already-loaded lists. Called by the proxy provider whenever the
  /// [UnlockedContentProvider] notifies a change.
  void updatePersistedUnlocks(Set<String> ids) {
    _persistedUnlockedIds = ids;
    var changed = false;
    _releases = _applyUnlocks(_releases, mutated: () => changed = true);
    _tracks = _applyUnlocks(_tracks, mutated: () => changed = true);
    _albums = _applyUnlocks(_albums, mutated: () => changed = true);
    _videos = _applyUnlocks(_videos, mutated: () => changed = true);
    if (changed) notifyListeners();
  }

  List<NewReleaseItem> _applyUnlocks(
    List<NewReleaseItem> items, {
    void Function()? mutated,
  }) {
    if (_persistedUnlockedIds.isEmpty || items.isEmpty) return items;
    var anyChange = false;
    final updated = <NewReleaseItem>[];
    for (final item in items) {
      if (!item.isUnlocked && _persistedUnlockedIds.contains(item.id)) {
        anyChange = true;
        updated.add(item.copyWith(isUnlocked: true, unlockCostCoins: 0));
      } else {
        updated.add(item);
      }
    }
    if (!anyChange) return items;
    mutated?.call();
    return updated;
  }

  Future<void> loadArtistProfile(
    String artistId, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadingProfile) return;
    if (!forceRefresh && _artistProfile != null && _artistProfile!.id == artistId) {
      return;
    }

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      _artistProfile = await _repository.getArtistProfile(artistId);
    } on ApiRequestException catch (e) {
      _profileError = e.message;
    } catch (_) {
      _profileError = 'An unexpected error occurred';
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistNewReleases(
    String artistId,
    String artistName, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadingReleases && !forceRefresh) return;

    _isLoadingReleases = true;
    _releasesError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistNewReleases(artistId);
      _releases = _applyUnlocks(
        response.items
            .map(
              (item) =>
                  NewReleaseItem.fromArtistNewReleaseItem(item, artistName),
            )
            .toList(),
      );
    } on ApiRequestException catch (e) {
      _releasesError = e.message;
    } catch (_) {
      _releasesError = 'An unexpected error occurred';
    } finally {
      _isLoadingReleases = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistTracks(
    String artistId,
    String artistName, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadingTracks && !forceRefresh) return;

    _isLoadingTracks = true;
    _tracksError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistTracks(artistId);
      _tracks = _applyUnlocks(
        response.items
            .map((item) => NewReleaseItem.fromArtistTrackItem(item, artistName))
            .toList(),
      );
    } on ApiRequestException catch (e) {
      _tracksError = e.message;
    } catch (_) {
      _tracksError = 'An unexpected error occurred';
    } finally {
      _isLoadingTracks = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistAlbums(
    String artistId,
    String artistName, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadingAlbums && !forceRefresh) return;

    _isLoadingAlbums = true;
    _albumsError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistAlbums(artistId);
      _albums = _applyUnlocks(
        response.items
            .map((item) => NewReleaseItem.fromArtistAlbumItem(item, artistName))
            .toList(),
      );
    } on ApiRequestException catch (e) {
      _albumsError = e.message;
    } catch (_) {
      _albumsError = 'An unexpected error occurred';
    } finally {
      _isLoadingAlbums = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistVideos(
    String artistId,
    String artistName, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadingVideos && !forceRefresh) return;

    _isLoadingVideos = true;
    _videosError = null;
    notifyListeners();

    try {
      final response = await _repository.getArtistVideos(artistId);
      _videos = _applyUnlocks(
        response.items
            .map((item) => NewReleaseItem.fromArtistVideoItem(item, artistName))
            .toList(),
      );
    } on ApiRequestException catch (e) {
      _videosError = e.message;
    } catch (_) {
      _videosError = 'An unexpected error occurred';
    } finally {
      _isLoadingVideos = false;
      notifyListeners();
    }
  }

  Future<void> loadSimilarArtists({
    required String excludeId,
    required HomeProvider homeProvider,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingSimilarArtists) return;

    _isLoadingSimilarArtists = true;
    _similarArtistsError = null;
    notifyListeners();

    try {
      await homeProvider.loadTrendingArtists(forceRefresh: forceRefresh);
      _similarArtists = homeProvider.trendingArtists
          .where((a) => a.id != excludeId)
          .take(12)
          .toList();
    } on ApiRequestException catch (e) {
      _similarArtistsError = e.message;
    } catch (_) {
      _similarArtistsError = 'An unexpected error occurred';
    } finally {
      _isLoadingSimilarArtists = false;
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
    } catch (_) {
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
      _applyFollowResponse(response);
      return response;
    } catch (_) {
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
      _applyFollowResponse(response);
      return response;
    } catch (_) {
      return null;
    } finally {
      _isActionInFlight = false;
      notifyListeners();
    }
  }

  void _applyFollowResponse(ArtistFollowResponse response) {
    final current = _artistProfile;
    if (current == null) return;
    _artistProfile = current.copyWith(
      isFollowing: response.isFollowing,
      followerCount: response.artistFollowerCount,
    );
  }

  Future<String> getTrackStreamUrl(String trackId) async {
    return _repository.getTrackStreamUrl(trackId);
  }

  /// Fetches an artist's public profile without mutating provider state.
  /// Used by callers (e.g. the Music Player image fallback) that just need
  /// the avatar URL and shouldn't disturb a profile screen the user may
  /// already be viewing.
  Future<ArtistPublicProfile> getArtistPublicProfile(String artistId) {
    return _repository.getArtistProfile(artistId);
  }

  Future<void> unlockTrack(String trackId) async {
    if (_isPlaybackActionInFlight) return;
    _isPlaybackActionInFlight = true;
    notifyListeners();
    try {
      await _repository.unlockTrack(trackId);
    } finally {
      _isPlaybackActionInFlight = false;
      notifyListeners();
    }
  }

  Future<void> unlockVideo(String videoId) async {
    if (_isPlaybackActionInFlight) return;
    _isPlaybackActionInFlight = true;
    notifyListeners();
    try {
      await _repository.unlockVideo(videoId);
    } finally {
      _isPlaybackActionInFlight = false;
      notifyListeners();
    }
  }

  Future<SendGiftResponse?> sendGift({
    required String artistId,
    required String giftType,
    String? trackId,
    String? videoId,
    String? message,
  }) async {
    if (_isActionInFlight) return null;
    _isActionInFlight = true;
    notifyListeners();
    try {
      return await _repository.sendGift(
        artistId: artistId,
        giftType: giftType,
        trackId: trackId,
        videoId: videoId,
        message: message,
      );
    } finally {
      _isActionInFlight = false;
      notifyListeners();
    }
  }

  void markTrackUnlocked(String trackId) {
    var changed = false;

    final updatedTracks = <NewReleaseItem>[];
    for (final track in _tracks) {
      if (track.id == trackId && !track.isUnlocked) {
        changed = true;
        updatedTracks.add(track.copyWith(isUnlocked: true, unlockCostCoins: 0));
      } else {
        updatedTracks.add(track);
      }
    }

    final updatedVideos = <NewReleaseItem>[];
    for (final video in _videos) {
      if (video.id == trackId && !video.isUnlocked) {
        changed = true;
        updatedVideos.add(video.copyWith(isUnlocked: true, unlockCostCoins: 0));
      } else {
        updatedVideos.add(video);
      }
    }

    if (!changed) return;
    _tracks = updatedTracks;
    _videos = updatedVideos;
    notifyListeners();
  }
}
