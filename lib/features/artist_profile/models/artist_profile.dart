class ArtistProfile {
  final String id;
  final String name;
  final String coverImageUrl;
  final int followerCount;

  ArtistProfile({
    required this.id,
    required this.name,
    required this.coverImageUrl,
    this.followerCount = 0,
  });

  ArtistProfile copyWith({
    String? id,
    String? name,
    String? coverImageUrl,
    int? followerCount,
  }) {
    return ArtistProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      followerCount: followerCount ?? this.followerCount,
    );
  }
}
