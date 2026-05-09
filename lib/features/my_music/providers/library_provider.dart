import 'package:flutter/foundation.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/my_music/data/my_music_api.dart';
import 'package:muxify/features/my_music/models/unlocked_track.dart';

/// Drives the "Unlocked" tab of the My Music hub. Loads every track the user
/// has unlocked and provides the three views the UI offers: All, By Artist,
/// By Genre. Grouping is computed client-side from the enriched DTO so a tab
/// switch doesn't trigger a refetch.
class LibraryProvider extends ChangeNotifier {
  LibraryProvider({MyMusicApi? api}) : _api = api ?? MyMusicApi();

  final MyMusicApi _api;

  List<UnlockedTrack> _tracks = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<UnlockedTrack> get tracks => _tracks;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  bool get isEmpty => _hasLoaded && _tracks.isEmpty;

  /// Tracks bucketed by artist name (or "Unknown artist" when missing).
  /// Keys are sorted alphabetically; tracks within each group preserve the
  /// most-recently-unlocked-first order returned by the backend.
  Map<String, List<UnlockedTrack>> get byArtist =>
      _group((t) => t.artistName.trim().isEmpty ? 'Unknown artist' : t.artistName);

  /// Tracks bucketed by genre name (or "More" when missing).
  Map<String, List<UnlockedTrack>> get byGenre => _group((t) {
        final g = (t.genreName ?? '').trim();
        return g.isEmpty ? 'More' : g;
      });

  Map<String, List<UnlockedTrack>> _group(String Function(UnlockedTrack) key) {
    final buckets = <String, List<UnlockedTrack>>{};
    for (final t in _tracks) {
      buckets.putIfAbsent(key(t), () => <UnlockedTrack>[]).add(t);
    }
    final sortedKeys = buckets.keys.toList()..sort();
    return {for (final k in sortedKeys) k: buckets[k]!};
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh && _hasLoaded) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracks = await _api.getAllUnlocked();
      _hasLoaded = true;
    } catch (e, st) {
      Logger.error('LibraryProvider.load failed', e, st);
      _error = 'Could not load your library. Pull to retry.';
      _tracks = const [];
      _hasLoaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}
