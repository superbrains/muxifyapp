import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/widgets/album_item_widget.dart';
import 'package:muxify/features/home/models/album_item.dart';

class AlbumsSectionWidget extends StatelessWidget {
  final List<AlbumItem> albums;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final int totalPlays;
  final String? mediaType;

  const AlbumsSectionWidget({
    super.key,
    required this.albums,
    required this.onTap,
    required this.onPlay,
    this.totalPlays = 0,
    this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430.maxHeight,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.padding,
        vertical: 21.padding,
      ),
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaType == 'Videos' ? 'Most Played' : 'Most Played',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 21.font,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  9.column,
                  Text(
                    'Sorted by relevance',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 13.font,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.compact().format(totalPlays),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 14.font,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Total Plays',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 10.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          25.column,
          SizedBox(
            height: 217.maxHeight,
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              itemCount: albums.length,
              padding: EdgeInsets.zero,

              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AlbumItemWidget(
                  item: albums[index],
                  onTap: onTap,
                );
              },
              separatorBuilder: (context, index) => 17.column,
            ),
          ),
          32.column,

          // Full-width "Play All" button — plays the artist's whole track list.
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: double.infinity,
              height: 52.maxHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                borderRadius: BorderRadius.circular(35.radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pngs/play.png',
                    width: 22.icon,
                    height: 22.icon,
                  ),
                  10.row,
                  Text(
                    'Play All',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 18.font,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
