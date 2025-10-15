import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';

class LatestReleaseBannerWidget extends StatelessWidget {
  final VoidCallback onTap;

  const LatestReleaseBannerWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 113.maxHeight,
      padding: EdgeInsets.only(left: 22, right: 14, top: 14, bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.radius),
        border: Border.all(
          color: AppColors.text.withValues(alpha: 0.3),
          width: 1.09.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Release',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14.font,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.column,
                Text(
                  "Boy ALone (Deluxe)",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14.font,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Album 🔹 2025",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14.font,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 88.maxWidth,
            height: 88.maxHeight,
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(bottom: 3.padding, right: 3.padding),
            decoration: BoxDecoration(
              color: AppColors.text.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9.radius),

              image: DecorationImage(
                image: AssetImage('assets/pngs/latest_release.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: _buildPlayButton(
              25.maxHeight,
              25.maxWidth,
              8.icon,
              10.icon,
              () {
                context.push(AppRouter.albumDetails);
              },
              AppColors.buttonColor,
            ),
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
