class TopGiverItem {
  final String id;
  final String username;
  final String avatarUrl;
  final String avatarBackgroundColor;
  final List<UserBadge> badges;
  final String associatedArtists;
  final String giftWorth;

  const TopGiverItem({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.avatarBackgroundColor,
    required this.badges,
    required this.associatedArtists,
    required this.giftWorth,
  });

  TopGiverItem copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? avatarBackgroundColor,
    List<UserBadge>? badges,
    String? associatedArtists,
    String? giftWorth,
  }) {
    return TopGiverItem(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarBackgroundColor:
          avatarBackgroundColor ?? this.avatarBackgroundColor,
      badges: badges ?? this.badges,
      associatedArtists: associatedArtists ?? this.associatedArtists,
      giftWorth: giftWorth ?? this.giftWorth,
    );
  }
}

class UserBadge {
  final String id;
  final String imageUrl;

  const UserBadge({required this.id, required this.imageUrl});
}
