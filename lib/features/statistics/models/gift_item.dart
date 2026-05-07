class GiftItem {
  final String id;
  final String name;
  final String backgroundImage;
  final String emojiImage;
  final String stickerText;
  final int count;
  final double? amount;

  const GiftItem({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.emojiImage,
    required this.stickerText,
    required this.count,
    this.amount,
  });

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      backgroundImage: json['backgroundImage'] as String? ?? 'assets/pngs/gift_bg_1.png',
      emojiImage: json['imageUrl'] as String? ?? json['emojiImage'] as String? ?? '',
      stickerText: json['stickerText'] as String? ?? 'GIFT',
      count: json['count'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble(),
    );
  }

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
