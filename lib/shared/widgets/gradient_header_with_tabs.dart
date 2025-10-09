import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/features/home/models/category_tab.dart';

class GradientHeaderWithTabs extends StatelessWidget {
  final String title;
  final VoidCallback? onBackTap;
  final String selectedMediaType;
  final Function(String)? onMediaTypeChanged;
  final List<CategoryTab> tabs;
  final String selectedTabId;
  final Function(String) onTabChanged;
  final Color gradientColor;

  const GradientHeaderWithTabs({
    super.key,
    required this.title,
    this.onBackTap,
    this.selectedMediaType = 'Music',
    this.onMediaTypeChanged,
    required this.tabs,
    required this.selectedTabId,
    required this.onTabChanged,
    this.gradientColor = AppColors.statisticsHeaderGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 62.maxHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          transform: const GradientRotation(1.5),
          colors: [
            gradientColor.withValues(alpha: 0.4),
            gradientColor.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0, 0.4, 0.8],
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: EdgeInsets.only(left: 24.padding, right: 20.padding),
            child: Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onBackTap?.call();
                  },
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.text,
                    size: 30.icon,
                  ),
                ),
                16.row,
                // Title
                Text(
                  title,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 20.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Media Type Dropdown
                _buildMediaTypeDropdown(),
              ],
            ),
          ),
          38.column,
          // Navigation Tabs
          CategoryTabsSection(
            categories: tabs,
            selectedCategoryId: selectedTabId,
            onCategoryChanged: onTabChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTypeDropdown() {
    final Map<String, IconData> mediaTypes = {
      'Music': Icons.music_note,
      'Videos': Icons.play_circle_outline,
      'DJ Mix': Icons.album_outlined,
      'Podcast': Icons.mic,
    };

    return PopupMenuButton<String>(
      color: AppColors.glassyDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: Offset(0, 40.buttonHeight),
      onSelected: (String value) {
        HapticFeedback.lightImpact();
        onMediaTypeChanged?.call(value);
      },
      child: Row(
        children: [
          Icon(
            mediaTypes[selectedMediaType] ?? Icons.music_note,
            color: AppColors.text,
            size: 20.icon,
          ),
          8.row,
          Text(
            selectedMediaType,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.row,
          Icon(
            Icons.arrow_drop_down_rounded,
            color: AppColors.text,
            size: 30.icon,
          ),
        ],
      ),
      itemBuilder: (BuildContext context) {
        return mediaTypes.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(
                  entry.value,
                  color: selectedMediaType == entry.key
                      ? AppColors.blue
                      : AppColors.text,
                  size: 20.icon,
                ),
                12.row,
                Text(
                  entry.key,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w500,
                    color: selectedMediaType == entry.key
                        ? AppColors.blue
                        : AppColors.text,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
