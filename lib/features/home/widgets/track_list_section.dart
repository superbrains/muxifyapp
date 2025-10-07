import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/track_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/track_list_item.dart';

class TrackListSection extends StatelessWidget {
  final List<TrackItem> tracks;
  final String title;

  const TrackListSection({
    super.key,
    required this.tracks,
    this.title = 'Popular Tracks',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () {
            HapticFeedback.lightImpact();
          },
        ),
        16.column,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length > 5 ? 5 : tracks.length,
          separatorBuilder: (context, index) => 8.column,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return TrackListItem(
              track: track,
              onTap: () {
              },
              onMenuTap: () {
              },
            );
          },
        ),
        16.column,
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.padding),
            decoration: BoxDecoration(
              color: AppColors.glassyDark,
              borderRadius: BorderRadius.circular(8.radius),
            ),
            child: Text(
              'See All',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.font,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
