import 'package:flutter_test/flutter_test.dart';
import 'package:muxify/features/my_music/data/my_music_api.dart';
import 'package:muxify/features/my_music/models/playable_track.dart';
import 'package:muxify/features/my_music/models/unlocked_track.dart';
import 'package:muxify/features/my_music/providers/library_provider.dart';

/// Fake [MyMusicApi] returning canned data so the provider can be tested
/// without hitting the network.
class _FakeApi implements MyMusicApi {
  _FakeApi(this.unlocked);

  final List<UnlockedTrack> unlocked;

  @override
  Future<UnlockedContentPage> getUnlocked({int page = 1, int pageSize = 50}) {
    return Future.value(
      UnlockedContentPage(
        items: unlocked,
        totalCount: unlocked.length,
        page: 1,
        pageSize: unlocked.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<List<UnlockedTrack>> getAllUnlocked({
    int pageSize = 100,
    int maxItems = 1000,
  }) {
    return Future.value(unlocked);
  }

  @override
  Future<PlayableTrackPage> getPlayableTracks({
    String? search,
    String? genreId,
    String? artistId,
    int page = 1,
    int pageSize = 30,
  }) {
    return Future.value(
      const PlayableTrackPage(
        items: <PlayableTrack>[],
        totalCount: 0,
        page: 1,
        pageSize: 0,
        totalPages: 0,
      ),
    );
  }
}

UnlockedTrack make({
  required String id,
  required String artist,
  String? genre,
}) =>
    UnlockedTrack(
      id: id,
      title: 'Title $id',
      artistName: artist,
      genreName: genre,
    );

void main() {
  test('load populates tracks and marks loaded', () async {
    final tracks = [
      make(id: '1', artist: 'AZKeyz', genre: 'Afrobeats'),
      make(id: '2', artist: 'Tems', genre: 'R&B'),
    ];
    final provider = LibraryProvider(api: _FakeApi(tracks));

    await provider.load();

    expect(provider.hasLoaded, isTrue);
    expect(provider.tracks, hasLength(2));
    expect(provider.error, isNull);
  });

  test('byArtist groups by artist name and sorts keys', () async {
    final provider = LibraryProvider(
      api: _FakeApi([
        make(id: '1', artist: 'Tems'),
        make(id: '2', artist: 'AZKeyz'),
        make(id: '3', artist: 'Tems'),
      ]),
    );
    await provider.load();

    final groups = provider.byArtist;
    expect(groups.keys.toList(), ['AZKeyz', 'Tems']);
    expect(groups['AZKeyz'], hasLength(1));
    expect(groups['Tems'], hasLength(2));
  });

  test('byGenre buckets missing genres into "More"', () async {
    final provider = LibraryProvider(
      api: _FakeApi([
        make(id: '1', artist: 'A', genre: 'Afrobeats'),
        make(id: '2', artist: 'B', genre: null),
        make(id: '3', artist: 'C', genre: 'Afrobeats'),
        make(id: '4', artist: 'D', genre: '   '),
      ]),
    );
    await provider.load();

    final groups = provider.byGenre;
    expect(groups['Afrobeats'], hasLength(2));
    expect(groups['More'], hasLength(2));
  });

  test('isEmpty reports true for an empty unlocked library', () async {
    final provider = LibraryProvider(api: _FakeApi(const []));
    await provider.load();

    expect(provider.isEmpty, isTrue);
    expect(provider.tracks, isEmpty);
  });
}
