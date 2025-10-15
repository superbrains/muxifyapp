class NewReleaseItem {
  final String id;
  final String title;
  final String artist;
  final String coverImageUrl;
  bool isUnlocked;

  NewReleaseItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
    this.isUnlocked = false,
  });

  NewReleaseItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverImageUrl,
    bool? isUnlocked,
  }) {
    return NewReleaseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
