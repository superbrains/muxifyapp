import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/services/storage_service.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/my_music/models/local_playlist.dart';
import 'package:muxify/features/my_music/models/local_playlist_track.dart';

/// Thrown when the caller tries to add a track that the user neither owns nor
/// is free. The eligibility rule is per the product spec: "I should be able to
/// Create Playlists but I can Only Add Either free Songs or Songs I unlocked".
class IneligibleTrackException implements Exception {
  final String message;
  IneligibleTrackException(this.message);
  @override
  String toString() => 'IneligibleTrackException: $message';
}

/// CRUD over the user's local (on-device) playlists. State is persisted to
/// SharedPreferences via [StorageService] so it survives app relaunches but
/// stays scoped to the device — there is no server sync.
class LocalPlaylistsProvider extends ChangeNotifier {
  LocalPlaylistsProvider({UnlockedContentProvider? unlocked, Random? rng})
      : _unlocked = unlocked,
        _rng = rng ?? Random();

  static const String storageKey = 'muxify.local_playlists';

  UnlockedContentProvider? _unlocked;
  final Random _rng;

  final List<LocalPlaylist> _playlists = [];
  bool _hydrated = false;

  List<LocalPlaylist> get playlists => List.unmodifiable(_playlists);
  bool get hydrated => _hydrated;
  bool get isEmpty => _hydrated && _playlists.isEmpty;

  /// Wires the eligibility source. Called after construction (when the
  /// `UnlockedContentProvider` instance is available via Provider.of) so the
  /// playlists provider can re-check eligibility on every add.
  void bindUnlockedSource(UnlockedContentProvider source) {
    _unlocked = source;
  }

  Future<void> hydrate() async {
    final raw = StorageService.getString(storageKey);
    _playlists.clear();
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _playlists.add(LocalPlaylist.fromJson(item));
            } else if (item is Map) {
              _playlists.add(
                LocalPlaylist.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      } catch (e, st) {
        Logger.error('LocalPlaylistsProvider hydrate failed', e, st);
      }
    }
    _hydrated = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final list = _playlists.map((p) => p.toJson()).toList(growable: false);
    await StorageService.setString(storageKey, jsonEncode(list));
  }

  LocalPlaylist? playlistById(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;
    for (final p in _playlists) {
      if (p.id == trimmed) return p;
    }
    return null;
  }

  bool isEligible(String trackId, {bool isFree = false}) {
    if (isFree) return true;
    final source = _unlocked;
    if (source == null) return false;
    return source.isUnlocked(trackId);
  }

  Future<LocalPlaylist> create(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Playlist name cannot be empty.');
    }
    final now = DateTime.now().toUtc();
    final playlist = LocalPlaylist(
      id: _generateId(),
      name: trimmed,
      createdAt: now,
      updatedAt: now,
    );
    _playlists.insert(0, playlist);
    await _persist();
    notifyListeners();
    return playlist;
  }

  Future<void> rename(String playlistId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Playlist name cannot be empty.');
    }
    final idx = _indexOf(playlistId);
    if (idx < 0) return;
    _playlists[idx] = _playlists[idx]
        .copyWith(name: trimmed, updatedAt: DateTime.now().toUtc());
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String playlistId) async {
    final idx = _indexOf(playlistId);
    if (idx < 0) return;
    _playlists.removeAt(idx);
    await _persist();
    notifyListeners();
  }

  /// Adds [track] to the named playlist after re-checking eligibility against
  /// the current [UnlockedContentProvider]. The picker UI server-side filters
  /// already, but the guard catches direct callers and stale state.
  Future<void> addTrack(String playlistId, LocalPlaylistTrack track) async {
    if (!isEligible(track.trackId, isFree: track.wasFreeAtAdd)) {
      throw IneligibleTrackException(
        '"${track.title}" needs to be unlocked before it can go into a playlist.',
      );
    }
    final idx = _indexOf(playlistId);
    if (idx < 0) return;
    final current = _playlists[idx];
    if (current.tracks.any((t) => t.trackId == track.trackId)) return;
    final next = current.copyWith(
      tracks: List<LocalPlaylistTrack>.from(current.tracks)..add(track),
      updatedAt: DateTime.now().toUtc(),
    );
    _playlists[idx] = next;
    await _persist();
    notifyListeners();
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    final idx = _indexOf(playlistId);
    if (idx < 0) return;
    final current = _playlists[idx];
    final next = current.copyWith(
      tracks:
          current.tracks.where((t) => t.trackId != trackId).toList(growable: false),
      updatedAt: DateTime.now().toUtc(),
    );
    _playlists[idx] = next;
    await _persist();
    notifyListeners();
  }

  Future<void> reorder(String playlistId, int oldIndex, int newIndex) async {
    final idx = _indexOf(playlistId);
    if (idx < 0) return;
    final current = _playlists[idx];
    if (oldIndex < 0 ||
        oldIndex >= current.tracks.length ||
        newIndex < 0 ||
        newIndex > current.tracks.length) {
      return;
    }
    final next = List<LocalPlaylistTrack>.from(current.tracks);
    var insertAt = newIndex;
    if (insertAt > oldIndex) insertAt -= 1;
    final moved = next.removeAt(oldIndex);
    next.insert(insertAt.clamp(0, next.length), moved);
    _playlists[idx] = current.copyWith(
      tracks: next,
      updatedAt: DateTime.now().toUtc(),
    );
    await _persist();
    notifyListeners();
  }

  int _indexOf(String playlistId) {
    final trimmed = playlistId.trim();
    if (trimmed.isEmpty) return -1;
    for (var i = 0; i < _playlists.length; i++) {
      if (_playlists[i].id == trimmed) return i;
    }
    return -1;
  }

  String _generateId() {
    final ts = DateTime.now().toUtc().microsecondsSinceEpoch.toRadixString(36);
    final tail = _rng.nextInt(0x7fffffff).toRadixString(36).padLeft(6, '0');
    return 'lp_${ts}_$tail';
  }
}
