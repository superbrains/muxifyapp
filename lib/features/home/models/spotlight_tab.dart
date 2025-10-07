import 'package:flutter/material.dart';

class SpotlightTab {
  final String id;
  final String title;
  final IconData icon;

  SpotlightTab({required this.id, required this.title, required this.icon});

  factory SpotlightTab.fromJson(Map<String, dynamic> json) {
    return SpotlightTab(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _getIconFromString(json['icon'] as String),
    );
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'spotlight':
        return Icons.wb_sunny;
      case 'most_gifted':
        return Icons.card_giftcard;
      case 'top_giver':
        return Icons.trending_up;
      case 'most_giver':
        return Icons.people;
      default:
        return Icons.radio;
    }
  }
}
