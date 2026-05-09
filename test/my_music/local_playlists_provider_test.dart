import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/services/storage_service.dart';
import 'package:muxify/features/my_music/models/local_playlist_track.dart';
import 'package:muxify/features/my_music/providers/local_playlists_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  LocalPlaylistTrack track({
    String id = 't1',
    String title = 'Song',
    bool wasFree = false,
  }) {
    return LocalPlaylistTrack(
      trackId: id,
      title: title,
      artist: 'Artist',
      durationSeconds: 180,
      wasFreeAtAdd: wasFree,
      addedAt: DateTime.utc(2026, 5, 9),
    );
  }

  test('hydrate is empty on first run', () async {
    final provider = LocalPlaylistsProvider();
    await provider.hydrate();

    expect(provider.hydrated, isTrue);
    expect(provider.isEmpty, isTrue);
    expect(provider.playlists, isEmpty);
  });

  test('create persists across new provider instances', () async {
    final provider = LocalPlaylistsProvider(rng: Random(1));
    await provider.hydrate();
    final created = await provider.create('Workout');

    expect(provider.playlists, hasLength(1));
    expect(provider.playlists.first.id, created.id);
    expect(provider.playlists.first.name, 'Workout');

    // A fresh provider hydrating from disk sees the same playlist.
    final next = LocalPlaylistsProvider(rng: Random(1));
    await next.hydrate();
    expect(next.playlists, hasLength(1));
    expect(next.playlists.first.name, 'Workout');
  });

  test('rename updates name and updatedAt', () async {
    final provider = LocalPlaylistsProvider(rng: Random(2));
    await provider.hydrate();
    final created = await provider.create('Old name');
    final initialUpdated = provider.playlistById(created.id)!.updatedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await provider.rename(created.id, 'New name');

    final renamed = provider.playlistById(created.id)!;
    expect(renamed.name, 'New name');
    expect(renamed.updatedAt.isAfter(initialUpdated) ||
        renamed.updatedAt == initialUpdated, isTrue);
  });

  test('delete removes the playlist', () async {
    final provider = LocalPlaylistsProvider(rng: Random(3));
    await provider.hydrate();
    final created = await provider.create('Mix');

    await provider.delete(created.id);
    expect(provider.playlists, isEmpty);
    expect(provider.playlistById(created.id), isNull);
  });

  group('addTrack eligibility', () {
    test('rejects locked, non-free track when not unlocked', () async {
      final unlocked = UnlockedContentProvider();
      final provider = LocalPlaylistsProvider(rng: Random(4))
        ..bindUnlockedSource(unlocked);
      await provider.hydrate();
      final p = await provider.create('Mix');

      expect(
        () => provider.addTrack(p.id, track(wasFree: false)),
        throwsA(isA<IneligibleTrackException>()),
      );
      expect(provider.playlistById(p.id)!.tracks, isEmpty);
    });

    test('accepts free track even when not unlocked', () async {
      final unlocked = UnlockedContentProvider();
      final provider = LocalPlaylistsProvider(rng: Random(5))
        ..bindUnlockedSource(unlocked);
      await provider.hydrate();
      final p = await provider.create('Mix');

      await provider.addTrack(p.id, track(wasFree: true));
      expect(provider.playlistById(p.id)!.tracks, hasLength(1));
    });

    test('accepts unlocked track when not free', () async {
      final unlocked = UnlockedContentProvider();
      await unlocked.markUnlocked('t1');
      final provider = LocalPlaylistsProvider(rng: Random(6))
        ..bindUnlockedSource(unlocked);
      await provider.hydrate();
      final p = await provider.create('Mix');

      await provider.addTrack(p.id, track());
      expect(provider.playlistById(p.id)!.tracks, hasLength(1));
    });

    test('does not duplicate a track', () async {
      final unlocked = UnlockedContentProvider();
      final provider = LocalPlaylistsProvider(rng: Random(7))
        ..bindUnlockedSource(unlocked);
      await provider.hydrate();
      final p = await provider.create('Mix');

      await provider.addTrack(p.id, track(wasFree: true));
      await provider.addTrack(p.id, track(wasFree: true));
      expect(provider.playlistById(p.id)!.tracks, hasLength(1));
    });
  });

  test('removeTrack drops the matching track only', () async {
    final unlocked = UnlockedContentProvider();
    final provider = LocalPlaylistsProvider(rng: Random(8))
      ..bindUnlockedSource(unlocked);
    await provider.hydrate();
    final p = await provider.create('Mix');

    await provider.addTrack(p.id, track(id: 'a', wasFree: true));
    await provider.addTrack(p.id, track(id: 'b', wasFree: true));
    await provider.removeTrack(p.id, 'a');

    final remaining = provider.playlistById(p.id)!.tracks;
    expect(remaining, hasLength(1));
    expect(remaining.first.trackId, 'b');
  });

  test('reorder shuffles the track order', () async {
    final unlocked = UnlockedContentProvider();
    final provider = LocalPlaylistsProvider(rng: Random(9))
      ..bindUnlockedSource(unlocked);
    await provider.hydrate();
    final p = await provider.create('Mix');

    for (final id in ['a', 'b', 'c']) {
      await provider.addTrack(p.id, track(id: id, wasFree: true));
    }

    // Move 'a' (index 0) to the end (index 3 means after the last item).
    await provider.reorder(p.id, 0, 3);
    final ids = provider
        .playlistById(p.id)!
        .tracks
        .map((t) => t.trackId)
        .toList(growable: false);
    expect(ids, ['b', 'c', 'a']);
  });
}
