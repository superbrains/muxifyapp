import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/models/onboarding/avatar_set_result.dart';
import 'package:muxify/core/models/onboarding/check_username_response.dart';
import 'package:muxify/core/models/onboarding/preset_avatars_response.dart';
import 'package:muxify/core/models/onboarding/suggested_artist.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/network/api_requester.dart';

/// Fan onboarding endpoints under `/api/v1/onboarding` (JWT required).
class OnboardingRepository {
  OnboardingRepository({ApiRequester? requester})
    : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<CheckUsernameResponse> checkUsername(String username) {
    final normalized = username.trim().toLowerCase();
    return _requester.postJson(
      ApiConstants.checkUsernamePath,
      {'username': normalized},
      CheckUsernameResponse.fromJson,
      authenticate: true,
    );
  }

  /// Returns the same path strings the API returns (e.g. `/assets/avatars/...`).
  /// Resolve with [ApiConstants.resolvePublicUrl] only for network image widgets.
  Future<PresetAvatarsResponse> getPresetAvatars() {
    return _requester.getJson(
      ApiConstants.presetAvatarsPath,
      PresetAvatarsResponse.fromJson,
      authenticate: true,
    );
  }

  Future<void> setUsername(String username) {
    final normalized = username.trim().toLowerCase();
    return _requester.postNoContent(
      ApiConstants.setUsernamePath,
      {'username': normalized},
      alsoAcceptStatuses: const [ApiConstants.statusOk],
      authenticate: true,
    );
  }

  /// `POST /api/v1/onboarding/set-avatar` with form field [avatarUrl] (Swagger):
  /// use the **preset string from `GET /onboarding/avatars`**, e.g. `/assets/avatars/male/avatar-m-1.png`.
  Future<String> setAvatarPreset(String avatarUrlField) async {
    final trimmed = avatarUrlField.trim();
    final result = await _requester.postMultipartJson(
      ApiConstants.setAvatarPath,
      AvatarSetResult.fromJson,
      authenticate: true,
      fields: {'avatarUrl': trimmed},
    );
    return _effectiveAvatarUrl(result);
  }

  Future<String> uploadAvatarBytes(
    Uint8List bytes, {
    required String filename,
  }) async {
    final name = filename.trim().isEmpty ? 'avatar.jpg' : filename.trim();
    final files = [http.MultipartFile.fromBytes('file', bytes, filename: name)];
    final result = await _requester.postMultipartJson(
      ApiConstants.setAvatarPath,
      AvatarSetResult.fromJson,
      authenticate: true,
      files: files,
    );
    return _effectiveAvatarUrl(result);
  }

  static String _effectiveAvatarUrl(AvatarSetResult result) {
    final url = ApiConstants.resolvePublicUrl(result.avatarUrl);
    if (url.isEmpty) {
      throw ApiRequestException('Avatar URL missing from server response.');
    }
    return url;
  }

  /// `GET …/onboarding/suggested-artists?count=` (authenticated).
  Future<List<SuggestedArtist>> getSuggestedArtists({required int count}) {
    final n = count < 1 ? 1 : (count > 100 ? 100 : count);
    return _requester.getJsonList(
      ApiConstants.suggestedArtistsPath,
      SuggestedArtist.fromJson,
      queryParameters: {'count': n},
      authenticate: true,
    );
  }

  /// `POST …/follow-artists` JSON `{ "artistIds": […] }` (authenticated).
  Future<void> followArtists(List<String> artistIds) {
    final ids = artistIds.map((e) => e.trim()).where((s) => s.isNotEmpty).toList(growable: false);
    return _requester.postNoContent(
      ApiConstants.followArtistsPath,
      {'artistIds': ids},
      authenticate: true,
    );
  }

  /// `POST …/onboarding/complete` (authenticated).
  Future<void> completeOnboarding() {
    return _requester.postNoContent(
      ApiConstants.completeOnboardingPath,
      null,
      authenticate: true,
    );
  }
}
