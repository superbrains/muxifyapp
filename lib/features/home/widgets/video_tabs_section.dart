import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/widgets/video_tab_button.dart';

class VideoTabsSection extends StatelessWidget {
  final String selectedTabId;
  final Function(String) onTabChanged;

  const VideoTabsSection({
    super.key,
    required this.selectedTabId,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: VideoTabButton(
            title: 'Content Videos',
            icon: Icons.grid_view,
            isSelected: selectedTabId == 'content_videos',
            onTap: () => onTabChanged('content_videos'),
          ),
        ),
        12.row,
        Expanded(
          child: VideoTabButton(
            title: 'Music Videos',
            icon: Icons.video_library,
            isSelected: selectedTabId == 'music_videos',
            onTap: () => onTabChanged('music_videos'),
          ),
        ),
      ],
    );
  }
}
