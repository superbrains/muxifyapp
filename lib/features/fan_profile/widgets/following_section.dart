import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

class FollowingSection extends StatelessWidget {
  const FollowingSection({
    super.key,
    required this.artists,
    this.onSeeAll,
    this.onArtistTap,
  });

  final List<FollowedArtist> artists;
  final VoidCallback? onSeeAll;
  final void Function(FollowedArtist artist)? onArtistTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Following',
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
          child: artists.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.padding),
                  child: Text(
                    'Not following any artists yet.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                      fontSize: 12.font,
                    ),
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) => 10.row,
                  padding: EdgeInsets.symmetric(horizontal: 12.padding),
                  scrollDirection: Axis.horizontal,
                  itemCount: artists.length + 1,
                  itemBuilder: (context, index) {
                    if (index == artists.length) {
                      return GestureDetector(
                        onTap: onSeeAll,
                        child: Container(
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
                        ),
                      );
                    }

                    final artist = artists[index];
                    final hasAvatar = artist.avatarUrl != null &&
                        artist.avatarUrl!.trim().isNotEmpty;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onArtistTap == null
                          ? null
                          : () => onArtistTap!(artist),
                      child: SizedBox(
                        width: 45.maxWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100.radius),
                              child: hasAvatar
                                  ? AuthNetworkImage(
                                      path: artist.avatarUrl!,
                                      width: 45.maxWidth,
                                      height: 45.maxHeight,
                                      fit: BoxFit.cover,
                                      placeholder: Image.asset(
                                        'assets/pngs/fan_profile_image.png',
                                        width: 45.maxWidth,
                                        height: 45.maxHeight,
                                        fit: BoxFit.cover,
                                      ),
                                      errorWidget: Image.asset(
                                        'assets/pngs/fan_profile_image.png',
                                        width: 45.maxWidth,
                                        height: 45.maxHeight,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/pngs/fan_profile_image.png',
                                      width: 45.maxWidth,
                                      height: 45.maxHeight,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            2.column,
                            Text(
                              artist.artistName ?? '—',
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
