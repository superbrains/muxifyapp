import 'package:flutter/foundation.dart';
import 'package:muxify/core/models/onboarding/check_username_response.dart';
import 'package:muxify/core/models/onboarding/preset_avatars_response.dart';
import 'package:muxify/core/models/onboarding/suggested_artist.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/auth/data/onboarding_repository.dart';

/// Fan onboarding APIs (username checks, presets). UI screens use Provider; debounce stays in widgets where needed.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({OnboardingRepository? repository})
    : _repository = repository ?? OnboardingRepository();

  final OnboardingRepository _repository;

  PresetAvatarsResponse? presetAvatars;

  bool presetAvatarsInitialLoading = false;
  bool presetAvatarsRefreshing = false;
  String? presetAvatarsError;

  bool get presetAvatarsShimmerLoading =>
      presetAvatarsInitialLoading || presetAvatarsRefreshing;

  List<SuggestedArtist> suggestedArtists = [];

  bool suggestedArtistsInitialLoading = false;
  bool suggestedArtistsRefreshing = false;
  String? suggestedArtistsError;

  bool get suggestedArtistsBusy =>
      suggestedArtistsInitialLoading || suggestedArtistsRefreshing;

  Future<CheckUsernameResponse> checkUsername(String username) {
    return _repository.checkUsername(username);
  }

  Future<void> setUsername(String username) {
    return _repository.setUsername(username);
  }

  Future<void> loadPresetAvatars({bool refreshing = false}) async {
    presetAvatarsError = null;
    if (refreshing) {
      presetAvatarsRefreshing = true;
    } else if (presetAvatars == null) {
      presetAvatarsInitialLoading = true;
    } else {
      presetAvatarsRefreshing = true;
    }
    notifyListeners();

    try {
      presetAvatars = await _repository.getPresetAvatars();
      presetAvatarsInitialLoading = false;
      presetAvatarsRefreshing = false;
      notifyListeners();
    } on ApiRequestException catch (e) {
      presetAvatarsInitialLoading = false;
      presetAvatarsRefreshing = false;
      presetAvatarsError = e.message;
      notifyListeners();
      await AppToast.showError(e.message);
    } catch (_) {
      presetAvatarsInitialLoading = false;
      presetAvatarsRefreshing = false;
      const msg = 'Could not load avatars. Pull to retry.';
      presetAvatarsError = msg;
      notifyListeners();
      await AppToast.showError(msg);
    }
  }

  /// Same string as in [PresetAvatarsResponse] (e.g. `/assets/avatars/male/avatar-m-1.png`).
  Future<String?> setPresetAvatar(String avatarUrlField) async {
    try {
      return await _repository.setAvatarPreset(avatarUrlField);
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return null;
    }
  }

  Future<String?> uploadAvatarBytes(
    Uint8List bytes, {
    required String filename,
  }) async {
    try {
      return await _repository.uploadAvatarBytes(bytes, filename: filename);
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return null;
    } catch (_) {
      await AppToast.showError('Could not upload your picture.');
      return null;
    }
  }

  static const int defaultSuggestedArtistCount = 36;

  Future<void> loadSuggestedArtists({
    bool refreshing = false,
    int count = defaultSuggestedArtistCount,
  }) async {
    suggestedArtistsError = null;
    if (refreshing) {
      suggestedArtistsRefreshing = true;
    } else if (suggestedArtists.isEmpty) {
      suggestedArtistsInitialLoading = true;
    } else {
      suggestedArtistsRefreshing = true;
    }
    notifyListeners();

    try {
      suggestedArtists = await _repository.getSuggestedArtists(count: count);
      suggestedArtistsInitialLoading = false;
      suggestedArtistsRefreshing = false;
      notifyListeners();
    } on ApiRequestException catch (e) {
      suggestedArtistsInitialLoading = false;
      suggestedArtistsRefreshing = false;
      suggestedArtistsError = e.message;
      notifyListeners();
      await AppToast.showError(e.message);
    } catch (_) {
      suggestedArtistsInitialLoading = false;
      suggestedArtistsRefreshing = false;
      const msg = 'Could not load artists. Pull down to retry.';
      suggestedArtistsError = msg;
      notifyListeners();
      await AppToast.showError(msg);
    }
  }

  /// Calls `follow-artists` then `complete` during onboarding fan flow.
  Future<bool> submitFollowOnboarding(List<String> artistIds) async {
    try {
      await _repository.followArtists(artistIds);
      await _repository.completeOnboarding();
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      await AppToast.showError('Could not complete onboarding.');
      return false;
    }
  }
}
