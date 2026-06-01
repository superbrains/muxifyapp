import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Lightweight reference used by the "See all" sheet so it can render either
/// supported or followed artists without depending on a specific model.
class FanArtistRef {
  const FanArtistRef({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.subtitle,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? subtitle;
}

/// Full list of a fan's artists shown in a draggable bottom sheet. Tapping a row
/// opens that artist's profile via [onArtistTap]. Used for both
/// "Artists & Creators" and "Following" so the See-all arrows resolve to a real
/// destination without a dedicated route.
class FanArtistsSheet extends StatelessWidget {
  const FanArtistsSheet({
    super.key,
    required this.title,
    required this.artists,
    required this.onArtistTap,
  });

  final String title;
  final List<FanArtistRef> artists;
  final void Function(FanArtistRef artist) onArtistTap;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<FanArtistRef> artists,
    required void Function(FanArtistRef artist) onArtistTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.modalBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.radius)),
      ),
      builder: (_) => FanArtistsSheet(
        title: title,
        artists: artists,
        onArtistTap: onArtistTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Column(
          children: [
            12.column,
            Container(
              width: 44.maxWidth,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            16.column,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.padding),
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 16.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  8.row,
                  Text(
                    '${artists.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 14.font,
                    ),
                  ),
                ],
              ),
            ),
            12.column,
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.padding,
                  vertical: 8.padding,
                ),
                itemCount: artists.length,
                separatorBuilder: (_, __) => 6.column,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  final hasAvatar =
                      (artist.avatarUrl ?? '').trim().isNotEmpty;
                  final fallback = Image.asset(
                    'assets/pngs/fan_profile_image.png',
                    width: 48.maxWidth,
                    height: 48.maxHeight,
                    fit: BoxFit.cover,
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.of(context).pop();
                      onArtistTap(artist);
                    },
                    leading: ClipOval(
                      child: SizedBox(
                        width: 48.maxWidth,
                        height: 48.maxHeight,
                        child: hasAvatar
                            ? AuthNetworkImage(
                                path: artist.avatarUrl!,
                                width: 48.maxWidth,
                                height: 48.maxHeight,
                                fit: BoxFit.cover,
                                placeholder: fallback,
                                errorWidget: fallback,
                              )
                            : fallback,
                      ),
                    ),
                    title: Text(
                      artist.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.text,
                        fontSize: 14.font,
                      ),
                    ),
                    subtitle: (artist.subtitle ?? '').isEmpty
                        ? null
                        : Text(
                            artist.subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.text.withValues(alpha: 0.6),
                              fontSize: 12.font,
                            ),
                          ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.text.withValues(alpha: 0.4),
                      size: 20.icon,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
