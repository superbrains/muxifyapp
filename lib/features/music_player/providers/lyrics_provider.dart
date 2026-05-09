import 'package:flutter/foundation.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/music_player/data/lyrics_repository.dart';

enum LyricsStatus { idle, loading, ready, empty, error }

/// Owns the lyrics state for the currently-open lyrics overlay. Kept separate
/// from [AudioProvider] so async fetches don't share rebuild cycles with the
/// ~10 Hz position frames driving the player UI.
class LyricsProvider extends ChangeNotifier {
  LyricsProvider({LyricsRepository? repository})
    : _repo = repository ?? LyricsRepository();

  final LyricsRepository _repo;

  String? _trackId;
  String? _lrc;
  String? _source;
  String? _errorMessage;
  LyricsStatus _status = LyricsStatus.idle;

  String? get lrc => _lrc;
  String? get source => _source;
  String? get errorMessage => _errorMessage;
  LyricsStatus get status => _status;

  bool get hasLyrics =>
      _status == LyricsStatus.ready && _lrc != null && _lrc!.isNotEmpty;

  /// Loads lyrics for [trackId]. No-ops when called repeatedly with the same
  /// trackId while the previous load is still in flight or already complete.
  Future<void> loadFor(String trackId) async {
    final id = trackId.trim();
    if (id.isEmpty) {
      _reset();
      return;
    }
    if (_trackId == id &&
        (_status == LyricsStatus.loading ||
            _status == LyricsStatus.ready ||
            _status == LyricsStatus.empty)) {
      return;
    }

    _trackId = id;
    _status = LyricsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getLyrics(id);
      // Track changed during the in-flight request — drop this result.
      if (_trackId != id) return;

      if (result.hasLyrics) {
        _lrc = result.lrc;
        _source = result.source;
        _status = LyricsStatus.ready;
      } else {
        _lrc = null;
        _source = null;
        _status = LyricsStatus.empty;
      }
    } on ApiRequestException catch (e) {
      if (_trackId != id) return;
      _lrc = null;
      _source = null;
      _errorMessage = e.message;
      _status = LyricsStatus.error;
      Logger.warning('LyricsProvider load failed for $id: ${e.message}');
    } catch (e, st) {
      if (_trackId != id) return;
      _lrc = null;
      _source = null;
      _errorMessage = 'Couldn\'t load lyrics.';
      _status = LyricsStatus.error;
      Logger.error('LyricsProvider load failed for $id', e, st);
    }
    notifyListeners();
  }

  void _reset() {
    _trackId = null;
    _lrc = null;
    _source = null;
    _errorMessage = null;
    _status = LyricsStatus.idle;
    notifyListeners();
  }
}
