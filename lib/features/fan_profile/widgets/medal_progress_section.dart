import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// Shows how close the fan is to their next medal tier, derived from total coins
/// gifted. Tier thresholds mirror the backend medal catalog (Iron → Diamond).
class MedalProgressSection extends StatelessWidget {
  const MedalProgressSection({super.key, required this.totalGiftValue});

  final int totalGiftValue;

  // (name, threshold) ascending — must match the backend GamificationSeeder.
  static const List<({String name, int threshold})> _tiers = [
    (name: 'Iron Fan', threshold: 10000),
    (name: 'Crown Fan', threshold: 50000),
    (name: 'Gold Fan', threshold: 200000),
    (name: 'Platinum Fan', threshold: 1000000),
    (name: 'Diamond Fan', threshold: 5000000),
  ];

  @override
  Widget build(BuildContext context) {
    // Find the next tier the fan has not yet reached.
    ({String name, int threshold})? next;
    int prevThreshold = 0;
    for (final tier in _tiers) {
      if (totalGiftValue < tier.threshold) {
        next = tier;
        break;
      }
      prevThreshold = tier.threshold;
    }

    if (next == null) {
      // Highest tier reached.
      return _wrap(
        child: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.badgeRating, size: 20.icon),
            8.row,
            Expanded(
              child: Text(
                'Top tier reached — you\'re a Diamond Fan! 💎',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontSize: 13.font,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final span = (next.threshold - prevThreshold).clamp(1, 1 << 31);
    final progressed = (totalGiftValue - prevThreshold).clamp(0, span);
    final fraction = progressed / span;
    final remaining = next.threshold - totalGiftValue;

    return _wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium,
                  color: AppColors.badgeRating, size: 18.icon),
              8.row,
              Expanded(
                child: Text(
                  'Next medal: ${next.name}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.text,
                    fontSize: 13.font,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(fraction * 100).round()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text.withValues(alpha: 0.7),
                  fontSize: 12.font,
                ),
              ),
            ],
          ),
          10.column,
          ClipRRect(
            borderRadius: BorderRadius.circular(6.radius),
            child: LinearProgressIndicator(
              value: fraction.toDouble(),
              minHeight: 7,
              backgroundColor: AppColors.text.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.badgeRating),
            ),
          ),
          6.column,
          Text(
            '$remaining more coins gifted to unlock ${next.name}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
              fontSize: 11.font,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrap({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.radius),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.badgeRating.withValues(alpha: 0.08),
            AppColors.background.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: child,
    );
  }
}
