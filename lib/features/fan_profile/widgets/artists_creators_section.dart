import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class ArtistsCreatorsSection extends StatelessWidget {
  const ArtistsCreatorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final artists = [
      'Davido',
      'Burna Boy',
      'Flavour',
      'Rema',
      'Wizkid',
      'Flavour',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artists & Creators',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        5.column,
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.radius),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.text.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: 0.2),
              ],
            ),
          ),
          height: 95.maxHeight,
          child: ListView.separated(
            separatorBuilder: (context, index) => 10.row,
            padding: EdgeInsets.symmetric(horizontal: 12.padding),
            scrollDirection: Axis.horizontal,
            itemCount: artists.length + 1, // +1 for the arrow
            itemBuilder: (context, index) {
              if (index == artists.length) {
                // Arrow at the end
                return Container(
                  width: 24.maxWidth,
                  height: 24.maxHeight,
                  decoration: BoxDecoration(
                    color: AppColors.text.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  margin: EdgeInsets.only(right: 12.padding),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.text,
                      size: 10.icon,
                    ),
                  ),
                );
              }

              final artist = artists[index];
              return Container(
                alignment: Alignment.center,
                width: 45.maxWidth,
                // margin: EdgeInsets.only(left: 11.padding, right: 10.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.radius),
                          child: Image.asset(
                            'assets/pngs/davido.png',
                            width: 45.maxWidth,
                            height: 45.maxHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -2.padding,
                          right: -2.padding,
                          child: Image.asset(
                            'assets/pngs/fan_verify.png',
                            width: 16.icon,
                            height: 16.icon,
                          ),
                        ),
                      ],
                    ),
                    2.column,
                    Text(
                      artist,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.text,
                        fontSize: 8.font,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
