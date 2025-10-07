class NewReleaseItem {
  final String id;
  final String albumName;
  final String artistName;
  final String? imageUrl;

  NewReleaseItem({
    required this.id,
    required this.albumName,
    required this.artistName,
    this.imageUrl,
  });

  factory NewReleaseItem.fromJson(Map<String, dynamic> json) {
    return NewReleaseItem(
      id: json['id'] as String,
      albumName: json['albumName'] as String,
      artistName: json['artistName'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
