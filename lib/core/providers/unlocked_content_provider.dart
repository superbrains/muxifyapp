import 'package:flutter/foundation.dart';
import 'package:muxify/core/services/storage_service.dart';

/// Tracks which track/video IDs the current user has already unlocked, so the
/// unlock UI is shown only once per item. Persisted via [StorageService] so
/// the state survives navigation, hot-restart, and app relaunches.
///
/// Track and video IDs are globally unique GUIDs in the Muxify backend, so a
/// single combined set is sufficient.
class UnlockedContentProvider extends ChangeNotifier {
  static const String _storageKey = 'muxify.unlocked_content_ids';
  final Set<String> _ids = <String>{};

  /// Loads any previously unlocked IDs from disk into the in-memory set.
  /// Safe to call multiple times; later calls reset the in-memory state to
  /// match what's on disk.
  void hydrate() {
    final stored = StorageService.getStringList(_storageKey) ?? const <String>[];
    _ids
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  bool isUnlocked(String? id) {
    if (id == null) return false;
    final trimmed = id.trim();
    if (trimmed.isEmpty) return false;
    return _ids.contains(trimmed);
  }

  /// Returns the current unlocked-id snapshot. Useful for batch-applying to
  /// freshly fetched lists (e.g. in [ArtistProfileProvider]).
  Set<String> get ids => Set<String>.unmodifiable(_ids);

  /// Adds [id] to the unlocked set and writes through to disk. No-op if [id]
  /// is empty or already tracked.
  Future<void> markUnlocked(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    if (!_ids.add(trimmed)) return;
    await StorageService.setStringList(_storageKey, _ids.toList(growable: false));
    notifyListeners();
  }
}
