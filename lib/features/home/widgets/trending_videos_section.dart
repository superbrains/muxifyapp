import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/grid_video_card.dart';
import 'package:muxify/features/home/widgets/see_all_button.dart';

class TrendingVideosSection extends StatelessWidget {
  final List<VideoItem> items;

  const TrendingVideosSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 495.maxHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 24.padding),
        separatorBuilder: (context, index) => 12.row,
        itemCount: 3,
        itemBuilder: (context, _) {
          final pageItems = items.take(4).toList();

          return Container(
            width: 330.maxWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.radius),
              color: AppColors.text.withValues(alpha: 0.08),
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.topRight,
              //   transform: const GradientRotation(1.5),
              //   colors: [
              //     AppColors.playlistGradientStart,
              //     AppColors.playlistGradientStart.withValues(alpha: 0.6),
              //     Colors.transparent,
              //   ],
              //   stops: const [0, 0.4, 0.8],
              // ),
            ),
            padding: EdgeInsets.all(15.padding),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // onPlayTap?.call();
                      },
                      child: Container(
                        width: 40.maxWidth,
                        height: 40.maxHeight,
                        decoration: BoxDecoration(
                          color: AppColors.text.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColors.background,
                          size: 16.icon,
                        ),
                      ),
                    ),
                    12.row,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trending', style: AppTextStyles.trendingText),
                        4.column,
                        Text(
                          '54 Videos',
                          style: AppTextStyles.trendingText.copyWith(
                            fontSize: 12.font,
                            color: AppColors.text.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                20.column,
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.padding,
                    mainAxisSpacing: 12.padding,
                    childAspectRatio: 1.maxHeight,
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    final item = pageItems[index];
                    return GridVideoCard(item: item, onTap: () {});
                  },
                ),

                8.column,
                Align(
                  alignment: Alignment.bottomRight,
                  child: SeeAllButton(
                    margin: EdgeInsets.only(right: 0.padding),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRouter.trendingVideos);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
