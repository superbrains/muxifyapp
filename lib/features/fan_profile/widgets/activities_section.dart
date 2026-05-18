import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';

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
              ? Text(
                  'No activities yet.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                    fontSize: 12.font,
                  ),
                )
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final FanActivity activity;

  @override
  Widget build(BuildContext context) {
    final iconAsset = _iconAssetForActivity(activity);
    final title = _titleForActivity(activity);
    final time = _formatTimestamp(activity.activityAt);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.radius),
          child: SizedBox(
            width: 45.maxWidth,
            height: 45.maxHeight,
            child: Image.asset(iconAsset, fit: BoxFit.cover),
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
      ],
    );
  }

  static String _iconAssetForActivity(FanActivity a) {
    switch (a.activityType) {
      case 'BadgeEarned':
        return 'assets/pngs/badge_1.png';
      case 'MedalEarned':
        return 'assets/pngs/earned_badge.png';
      case 'GiftSent':
      case 'GiftReceived':
        return 'assets/pngs/fan_profile_image.png';
      case 'TrackPlay':
      case 'VideoPlay':
      case 'ContentUnlock':
      case 'ContentLike':
      case 'ContentShare':
        return 'assets/pngs/davido.png';
      case 'ArtistFollow':
        return 'assets/pngs/fan_verify.png';
      default:
        return 'assets/pngs/davido.png';
    }
  }

  static String _titleForActivity(FanActivity a) {
    final artist = a.artistName ?? 'an artist';
    final track = a.trackTitle ?? a.videoTitle ?? '';
    switch (a.activityType) {
      case 'TrackPlay':
        return track.isNotEmpty ? 'Played: $artist - $track' : 'Played a track';
      case 'VideoPlay':
        return track.isNotEmpty ? 'Watched: $artist - $track' : 'Watched a video';
      case 'ContentUnlock':
        return track.isNotEmpty
            ? 'Unlocked: $artist - $track'
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
        return 'Earned badge: $badge';
      case 'MedalEarned':
        final medal = a.medalName ?? 'a medal';
        return 'Earned medal: $medal';
      case 'ContentLike':
        return track.isNotEmpty ? 'Liked: $artist - $track' : 'Liked content';
      case 'ContentShare':
        return track.isNotEmpty ? 'Shared: $artist - $track' : 'Shared content';
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
