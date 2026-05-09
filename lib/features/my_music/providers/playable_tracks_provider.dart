import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/my_music/data/my_music_api.dart';
import 'package:muxify/features/my_music/models/playable_track.dart';

/// Drives the playlist track picker. Calls `/content/playable-tracks` with a
/// debounce on search input so each keystroke doesn't spawn a request.
class PlayableTracksProvider extends ChangeNotifier {
  PlayableTracksProvider({MyMusicApi? api}) : _api = api ?? MyMusicApi();

  final MyMusicApi _api;
  Timer? _debounce;

  static const Duration _searchDebounce = Duration(milliseconds: 280);

  String _search = '';
  String? _genreId;
  String? _artistId;

  List<PlayableTrack> _items = const [];
  bool _isLoading = false;
  String? _error;
  int _requestSeq = 0;

  String get search => _search;
  String? get genreId => _genreId;
  String? get artistId => _artistId;
  List<PlayableTrack> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSearch(String value) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, refresh);
    notifyListeners();
  }

  void setGenre(String? id) {
    _genreId = (id == null || id.trim().isEmpty) ? null : id.trim();
    refresh();
  }

  void setArtist(String? id) {
    _artistId = (id == null || id.trim().isEmpty) ? null : id.trim();
    refresh();
  }

  void clearFilters() {
    _search = '';
    _genreId = null;
    _artistId = null;
    refresh();
  }

  Future<void> refresh() async {
    final seq = ++_requestSeq;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _api.getPlayableTracks(
        search: _search,
        genreId: _genreId,
        artistId: _artistId,
        pageSize: 50,
      );
      // Drop stale responses (a newer request may have been issued mid-flight).
      if (seq != _requestSeq) return;
      _items = page.items;
    } catch (e, st) {
      Logger.error('PlayableTracksProvider.refresh failed', e, st);
      if (seq != _requestSeq) return;
      _error = 'Could not load tracks. Try again.';
      _items = const [];
    } finally {
      if (seq == _requestSeq) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
