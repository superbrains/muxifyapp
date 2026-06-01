import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';
import 'package:muxify/features/fan_profile/widgets/achievement_icon.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Activity feed for a fan profile. Each row shows the real image the activity
/// references (track cover / video thumbnail / artist avatar, served via the
/// authenticated media proxy) with a small activity-type glyph badge overlaid —
/// matching the visual density of Spotify/YouTube activity rows. Badge/medal
/// milestones render the gamification medallion instead.
class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key, required this.activities});

  final List<FanActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        15.column,
        Container(
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
          padding: EdgeInsets.all(16.padding),
          child: activities.isEmpty
              ? _EmptyActivities()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => 16.column,
                  itemBuilder: (context, index) =>
                      _ActivityRow(activity: activities[index]),
                ),
        ),
      ],
    );
  }
}

class _EmptyActivities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.timeline,
          color: AppColors.text.withValues(alpha: 0.4),
          size: 32.icon,
        ),
        8.column,
        Text(
          'No activity yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 14.font,
          ),
        ),
        4.column,
        Text(
          'Gifts, likes, unlocks and follows will show up here.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.text.withValues(alpha: 0.6),
            fontSize: 12.font,
          ),
        ),
      ],
    );
  }
}

/// Skeleton placeholder shown while the first page of activity loads.
class ActivitiesSkeleton extends StatelessWidget {
  const ActivitiesSkeleton({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.text.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6.radius),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        15.column,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.radius),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
          ),
          padding: EdgeInsets.all(16.padding),
          child: Column(
            children: List.generate(rows, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: i == rows - 1 ? 0 : 16.padding),
                child: Row(
                  children: [
                    Container(
                      width: 45.maxWidth,
                      height: 45.maxHeight,
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.radius),
                      ),
                    ),
                    15.row,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [bar(180.maxWidth, 12), 8.column, bar(90.maxWidth, 10)],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final FanActivity activity;

  @override
  Widget build(BuildContext context) {
    final title = _titleForActivity(activity);
    final time = _formatTimestamp(activity.activityAt);
    final visual = _ActivityVisuals.forType(activity.activityType);

    return Row(
      children: [
        SizedBox(
          width: 48.maxWidth,
          height: 48.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _leadingImage(visual),
              // Activity-type glyph badge, bottom-right.
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: EdgeInsets.all(4.padding),
                  decoration: BoxDecoration(
                    color: visual.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                  child: Icon(visual.icon, color: Colors.white, size: 10.icon),
                ),
              ),
            ],
          ),
        ),
        15.row,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text,
                  fontSize: 14.font,
                  fontWeight: FontWeight.w400,
                ),
              ),
              2.column,
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                  fontSize: 12.font,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (activity.coinValue != null && activity.coinValue! > 0) ...[
          8.row,
          Text(
            'm${activity.coinValue}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.badgeRating,
              fontSize: 13.font,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _leadingImage(_ActivityVisuals visual) {
    // Milestones get the gamification medallion.
    if (activity.activityType == 'BadgeEarned' ||
        activity.activityType == 'MedalEarned') {
      return AchievementIcon(
        icon: '',
        color: '#FFAD12',
        size: 48.maxWidth,
        glyph: visual.icon,
      );
    }

    final path = activity.relatedImageUrl?.trim() ?? '';
    final fallback = _typeTile(visual);
    if (path.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.radius),
      child: AuthNetworkImage(
        path: path,
        width: 48.maxWidth,
        height: 48.maxHeight,
        fit: BoxFit.cover,
        placeholder: fallback,
        errorWidget: fallback,
      ),
    );
  }

  Widget _typeTile(_ActivityVisuals visual) {
    return Container(
      width: 48.maxWidth,
      height: 48.maxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.radius),
        color: visual.color.withValues(alpha: 0.2),
      ),
      child: Icon(visual.icon, color: visual.color, size: 22.icon),
    );
  }

  static String _titleForActivity(FanActivity a) {
    final artist = a.artistName ?? 'an artist';
    final track = a.trackTitle ?? a.videoTitle ?? '';
    switch (a.activityType) {
      case 'TrackPlay':
        return track.isNotEmpty ? 'Played $track' : 'Played a track';
      case 'VideoPlay':
        return track.isNotEmpty ? 'Watched $track' : 'Watched a video';
      case 'ContentUnlock':
        return track.isNotEmpty
            ? 'Unlocked $track by $artist'
            : 'Unlocked content';
      case 'GiftSent':
        final gift = a.giftType ?? 'a gift';
        return 'Sent $gift to $artist';
      case 'GiftReceived':
        final gift = a.giftType ?? 'a gift';
        return 'Received $gift';
      case 'ArtistFollow':
        return 'Followed $artist';
      case 'BadgeEarned':
        final badge = a.badgeName ?? 'a badge';
        return 'Earned the $badge badge';
      case 'MedalEarned':
        final medal = a.medalName ?? 'a medal';
        return 'Earned the $medal medal';
      case 'ContentLike':
        return track.isNotEmpty ? 'Liked $track by $artist' : 'Liked content';
      case 'ContentShare':
        return track.isNotEmpty ? 'Shared $track' : 'Shared content';
      default:
        return a.activityType;
    }
  }

  static String _formatTimestamp(DateTime when) {
    final now = DateTime.now();
    final local = when.toLocal();
    final dayDiff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute$ampm';
    String dayStr;
    if (dayDiff == 0) {
      dayStr = 'Today';
    } else if (dayDiff == 1) {
      dayStr = 'Yesterday';
    } else if (dayDiff < 7) {
      dayStr = '$dayDiff days ago';
    } else {
      dayStr =
          '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    }
    return '$dayStr • $timeStr';
  }
}

/// Maps an activity type to its glyph + accent color used for the overlay badge
/// and the fallback tile.
class _ActivityVisuals {
  const _ActivityVisuals(this.icon, this.color);

  final IconData icon;
  final Color color;

  static _ActivityVisuals forType(String type) {
    switch (type) {
      case 'GiftSent':
      case 'GiftReceived':
        return const _ActivityVisuals(Icons.card_giftcard, Color(0xFFEA4335));
      case 'ContentLike':
        return const _ActivityVisuals(Icons.favorite, Color(0xFFEA4335));
      case 'ContentUnlock':
        return const _ActivityVisuals(Icons.lock_open, Color(0xFF06A0B5));
      case 'ArtistFollow':
        return const _ActivityVisuals(Icons.person_add, Color(0xFF34A891));
      case 'ContentShare':
        return const _ActivityVisuals(Icons.share, Color(0xFF8D4CA8));
      case 'TrackPlay':
        return const _ActivityVisuals(Icons.music_note, Color(0xFF06A0B5));
      case 'VideoPlay':
        return const _ActivityVisuals(Icons.play_arrow, Color(0xFF06A0B5));
      case 'BadgeEarned':
        return const _ActivityVisuals(Icons.military_tech, Color(0xFFFFAD12));
      case 'MedalEarned':
        return const _ActivityVisuals(Icons.workspace_premium, Color(0xFFFFAD12));
      default:
        return const _ActivityVisuals(Icons.bolt, Color(0xFF424242));
    }
  }
}
