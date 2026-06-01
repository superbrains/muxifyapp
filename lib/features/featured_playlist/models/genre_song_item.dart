class GenreSongItem {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;
  final bool isUnlocked;
  final bool isPlaying;

  /// Coins required to unlock this track (0 = free / unknown). Carried so the
  /// player's real unlock modal reads the per-track price instead of a default.
  final int unlockCostCoins;
  final String? artistId;

  const GenreSongItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.isUnlocked,
    this.isPlaying = false,
    this.unlockCostCoins = 0,
    this.artistId,
  });

  GenreSongItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArtUrl,
    bool? isUnlocked,
    bool? isPlaying,
    int? unlockCostCoins,
    String? artistId,
  }) {
    return GenreSongItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isPlaying: isPlaying ?? this.isPlaying,
      unlockCostCoins: unlockCostCoins ?? this.unlockCostCoins,
      artistId: artistId ?? this.artistId,
    );
  }
}
