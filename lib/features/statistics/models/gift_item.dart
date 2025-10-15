class GiftItem {
  final String id;
  final String name;
  final String backgroundImage;
  final String emojiImage;
  final String stickerText;
  final int count;

  const GiftItem({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.emojiImage,
    required this.stickerText,
    required this.count,
  });

  @override
  String toString() {
    return 'GiftItem(id: $id, name: $name, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GiftItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
