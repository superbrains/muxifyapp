import 'package:muxify/core/network/api_requester.dart';

class LyricsResult {
  const LyricsResult({this.lrc, this.source});

  /// LRC body with `[mm:ss.xx]` timestamps, null when none are available.
  final String? lrc;

  /// `"Artist"` or `"LrcLib"`, null when [lrc] is null.
  final String? source;

  bool get hasLyrics => lrc != null && lrc!.trim().isNotEmpty;
}

/// Loads synchronized lyrics for a track from the Muxify backend. The backend
/// itself handles the LrcLib fallback and persists fetched LRC, so the client
/// only needs the track-detail endpoint.
///
/// Holds a small in-memory cache keyed by trackId so reopening the lyrics
/// overlay during the same session doesn't re-hit the API.
class LyricsRepository {
  LyricsRepository({ApiRequester? requester})
    : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;
  final Map<String, LyricsResult> _cache = {};

  Future<LyricsResult> getLyrics(String trackId) async {
    final cached = _cache[trackId];
    if (cached != null) return cached;

    final result = await _requester.getJson<LyricsResult>(
      '/api/v1/content/tracks/$trackId',
      (json) => LyricsResult(
        lrc: _stringOrNull(json['lrcContent']),
        source: _stringOrNull(json['lrcSource']),
      ),
      authenticate: true,
    );

    _cache[trackId] = result;
    return result;
  }

  void invalidate(String trackId) => _cache.remove(trackId);

  static String? _stringOrNull(dynamic v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}
