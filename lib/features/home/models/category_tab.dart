import 'package:flutter/material.dart';

// Model for category tab options
class CategoryTab {
  final String id;
  final String title;
  final IconData icon;

  CategoryTab({required this.id, required this.title, required this.icon});

  // Factory constructor for creating from JSON (backend data)
  factory CategoryTab.fromJson(Map<String, dynamic> json) {
    return CategoryTab(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _getIconFromString(json['icon'] as String),
    );
  }

  // Helper to map icon names to IconData
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'trending':
        return Icons.trending_up;
      case 'hot_release':
        return Icons.local_fire_department;
      case 'top_chart':
        return Icons.bar_chart;
      case 'new_release':
        return Icons.fiber_new;
      default:
        return Icons.radio;
    }
  }
}
