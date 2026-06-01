import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/video_player/models/video_detail.dart';

/// Repository for the video player: detail hydration, like toggle, and the
/// coin unlock. Mirrors [MusicPlayerRepository] — wraps the shared
/// [ApiRequester] which handles auth headers + 401 refresh. Failures surface as
/// [ApiRequestException]; callers decide how to present them (no swallowing).
class VideoRepository {
  VideoRepository({ApiRequester? requester})
      : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  /// GET /api/v1/content/videos/{id} — authoritative detail (unlock state,
  /// pricing, avatar, counts, like state).
  Future<VideoDetail> getVideoDetail(String videoId) {
    return _requester.getJson(
      ApiConstants.videoDetailPath(videoId),
      VideoDetail.fromJson,
      authenticate: true,
    );
  }

  /// POST /api/v1/content/videos/{id}/like — idempotent toggle. Returns the new
  /// like state + count.
  Future<VideoLikeStatus> toggleLike(String videoId) {
    return _requester.postJson(
      ApiConstants.videoLikePath(videoId),
      null,
      VideoLikeStatus.fromJson,
      authenticate: true,
    );
  }

  /// POST /api/v1/content/videos/{id}/unlock. Mirrors
  /// [MusicPlayerRepository.unlockTrack]: 200 + UnlockContentResponse on
  /// success; we don't need the body for the player. Rethrows on failure so the
  /// confirm modal can show the real error and NOT flip the UI to "unlocked".
  Future<void> unlockVideo(String videoId) {
    return _requester.postNoContent(
      ApiConstants.videoUnlockPath(videoId),
      null,
      successStatus: ApiConstants.statusOk,
      alsoAcceptStatuses: const [ApiConstants.statusNoContent],
      authenticate: true,
    );
  }
}
