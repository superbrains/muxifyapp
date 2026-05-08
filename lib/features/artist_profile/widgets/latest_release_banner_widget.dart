import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

class LatestReleaseBannerWidget extends StatelessWidget {
  final NewReleaseItem release;
  final VoidCallback onTap;

  const LatestReleaseBannerWidget({
    super.key,
    required this.release,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                    release.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.font,
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _subtitle(),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.font,
                      color: AppColors.text.withValues(alpha: 0.85),
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
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildArtwork(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _buildPlayButton(
                      25.maxHeight,
                      25.maxWidth,
                      8.icon,
                      10.icon,
                      onTap,
                      AppColors.buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final type = release.type.isEmpty ? 'Track' : _capitalize(release.type);
    final year = release.releaseDate?.year;
    if (year == null || year <= 1) return type;
    return '$type 🔹 $year';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  Widget _buildArtwork() {
    final url = release.coverImageUrl.trim();
    if (url.isEmpty) {
      return Image.asset(
        'assets/pngs/latest_release.png',
        fit: BoxFit.cover,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      placeholder: Image.asset(
        'assets/pngs/latest_release.png',
        fit: BoxFit.cover,
      ),
      errorWidget: Image.asset(
        'assets/pngs/latest_release.png',
        fit: BoxFit.cover,
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
      onTap: onTap,
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
