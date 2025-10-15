import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/widgets/album_item_widget.dart';
import 'package:muxify/features/home/models/album_item.dart';

class AlbumsSectionWidget extends StatelessWidget {
  final List<AlbumItem> albums;
  final VoidCallback onTap;
  final VoidCallback onGiftCountTap;

  const AlbumsSectionWidget({
    super.key,
    required this.albums,
    required this.onTap,
    required this.onGiftCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430.maxHeight,
      width: 365.maxWidth,
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
                    'Most Played',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'm24,000,250',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 12.font,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Received Gifts',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 10.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text,
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
                  onGiftCountTap: onGiftCountTap,
                );
              },
              separatorBuilder: (context, index) => 17.column,
            ),
          ),
          32.column,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlayButton(
                52.maxHeight,
                52.maxWidth,
                26.icon,
                26.icon,
                onTap,
                AppColors.text.withValues(alpha: 0.16),
              ),

              Container(
                width: 150.maxWidth,
                height: 52.maxHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(35.radius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pngs/gift.png',
                      width: 28.icon,
                      height: 28.icon,
                    ),
                    8.row,
                    Text(
                      'Share Gift',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 18.font,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
    double contheight,
    double contwidth,
    double imgheight,
    double imgwidth,
    VoidCallback onTap,
    Color? color,
  ) {
    return GestureDetector(
      onTap: () {
        // Play action
        onTap();
      },
      child: Container(
        height: contheight,
        width: contwidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? AppColors.buttonColor,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/pngs/play.png',
          height: imgheight,
          width: imgwidth,
        ),
      ),
    );
  }
}
