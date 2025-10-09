class StatisticsTab {
  final String id;
  final String title;
  final String icon;

  StatisticsTab({required this.id, required this.title, required this.icon});

  factory StatisticsTab.fromJson(Map<String, dynamic> json) {
    return StatisticsTab(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
    );
  }
}
