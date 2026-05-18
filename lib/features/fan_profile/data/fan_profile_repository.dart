import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';

class FanProfileRepository {
  FanProfileRepository({ApiRequester? requester})
      : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<FanPublicProfile> getFanProfile(String fanId) {
    return _requester.getJson(
      ApiConstants.fanProfilePath(fanId),
      FanPublicProfile.fromJson,
      authenticate: true,
    );
  }

  Future<FanActivityList> getFanActivity(
    String fanId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return _requester.getJson(
      ApiConstants.fanActivityPath(fanId),
      FanActivityList.fromJson,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      authenticate: true,
    );
  }

  Future<SupportedArtistsList> getSupportedArtists(
    String fanId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return _requester.getJson(
      ApiConstants.fanSupportedArtistsPath(fanId),
      SupportedArtistsList.fromJson,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      authenticate: true,
    );
  }

  Future<FollowedArtistsList> getFollowedArtists(
    String fanId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return _requester.getJson(
      ApiConstants.fanFollowedArtistsPath(fanId),
      FollowedArtistsList.fromJson,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      authenticate: true,
    );
  }

  Future<UserBadgeList> getFanBadges(String fanId) {
    return _requester.getJson(
      ApiConstants.fanBadgesPath(fanId),
      UserBadgeList.fromJson,
      authenticate: true,
    );
  }

  Future<UserMedalList> getFanMedals(String fanId) {
    return _requester.getJson(
      ApiConstants.fanMedalsPath(fanId),
      UserMedalList.fromJson,
      authenticate: true,
    );
  }

  Future<SendFanGiftResponse> sendFanGift({
    required String fanId,
    required String giftType,
    String? message,
  }) {
    final body = <String, dynamic>{'giftType': giftType};
    if (message != null && message.trim().isNotEmpty) {
      body['message'] = message.trim();
    }
    return _requester.postJson(
      ApiConstants.fanGiftPath(fanId),
      body,
      SendFanGiftResponse.fromJson,
      authenticate: true,
    );
  }
}
