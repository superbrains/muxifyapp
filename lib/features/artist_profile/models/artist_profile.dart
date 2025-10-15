class ArtistProfile {
  final String id;
  final String name;
  final String coverImageUrl;
  final String followers;

  ArtistProfile({
    required this.id,
    required this.name,
    required this.coverImageUrl,
    required this.followers,
  });

  ArtistProfile copyWith({
    String? id,
    String? name,
    String? coverImageUrl,
    String? followers,
  }) {
    return ArtistProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      followers: followers ?? this.followers,
    );
  }
}
