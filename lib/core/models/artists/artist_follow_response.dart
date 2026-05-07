class ArtistFollowResponse {
  final bool success;
  final bool isFollowing;
  final int artistFollowerCount;
  final String? message;

  ArtistFollowResponse({
    required this.success,
    required this.isFollowing,
    required this.artistFollowerCount,
    this.message,
  });

  factory ArtistFollowResponse.fromJson(Map<String, dynamic> json) {
    return ArtistFollowResponse(
      success: json['success'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      artistFollowerCount: (json['artistFollowerCount'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );
  }
}
