import 'package:flutter/material.dart';

// Model for tab options - can be replaced with backend model
class TabOption {
  final String title;
  final IconData icon;

  TabOption({required this.title, required this.icon});

  // Factory constructor for creating from JSON (backend data)
  factory TabOption.fromJson(Map<String, dynamic> json) {
    return TabOption(
      title: json['title'] as String,
      icon: _getIconFromString(json['icon'] as String),
    );
  }

  // Helper to map icon names to IconData (can be expanded)
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'music':
        return Icons.music_note;
      case 'video':
        return Icons.play_circle_outline;
      case 'dj_mix':
        return Icons.album_outlined;
      case 'podcast':
        return Icons.mic;
      default:
        return Icons.radio;
    }
  }
}
