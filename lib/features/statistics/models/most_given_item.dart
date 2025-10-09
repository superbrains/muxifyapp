class MostGivenItem {
  final String id;
  final String artistName;
  final String workSnippet;
  final String receivedGifts;
  final int rank;

  const MostGivenItem({
    required this.id,
    required this.artistName,
    required this.workSnippet,
    required this.receivedGifts,
    required this.rank,
  });

  MostGivenItem copyWith({
    String? id,
    String? artistName,
    String? workSnippet,
    String? receivedGifts,
    int? rank,
  }) {
    return MostGivenItem(
      id: id ?? this.id,
      artistName: artistName ?? this.artistName,
      workSnippet: workSnippet ?? this.workSnippet,
      receivedGifts: receivedGifts ?? this.receivedGifts,
      rank: rank ?? this.rank,
    );
  }
}
