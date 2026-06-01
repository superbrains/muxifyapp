import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class PositionSection extends StatelessWidget {
  const PositionSection({
    super.key,
    this.giftsRecord,
    this.leaderboardRank,
    this.onGiftsTap,
    this.onLeaderboardTap,
  });

  final int? giftsRecord;
  final int? leaderboardRank;
  final VoidCallback? onGiftsTap;
  final VoidCallback? onLeaderboardTap;

  String get giftsRecordValue {
    final value = giftsRecord;
    if (value == null) return '';
    return _formatThousands(value);
  }

  static String _formatThousands(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Position',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        15.column,
        Row(
          children: [
            // Gifts Record Card
            Expanded(
              child: _TappableCard(
                onTap: onGiftsTap,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/pngs/Bitcoin_musixfy.png',
                      width: 40.icon,
                      height: 40.icon,
                    ),
                    12.row,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: AppTextStyles.displayText.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: giftsRecordValue.isNotEmpty ? 'm' : '',
                                  style: AppTextStyles.displayText.copyWith(
                                    color: AppColors.text,
                                    fontSize: 10.font,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: giftsRecordValue.isNotEmpty
                                      ? giftsRecordValue
                                      : '—',
                                  style: AppTextStyles.displayText.copyWith(
                                    color: AppColors.text,
                                    fontSize: 18.font,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Gifts Record',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.text.withValues(alpha: 0.7),
                              fontSize: 15.font,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            10.row,
            // Leaderboard Card
            Expanded(
              child: _TappableCard(
                onTap: onLeaderboardTap,
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 40.maxWidth,
                      height: 40.maxHeight,
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/pngs/stats.png',
                        width: 18.icon,
                        height: 16.icon,
                      ),
                    ),
                    12.row,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            leaderboardRank != null ? '#$leaderboardRank' : '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.text,
                              fontSize: 21.font,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Leaderboard',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.text.withValues(alpha: 0.7),
                              fontSize: 15.font,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A Position card. When [onTap] is provided it becomes tappable (ripple +
/// a chevron affordance) so the user can drill into the full leaderboard /
/// gift history; otherwise it renders as a static stat card.
class _TappableCard extends StatelessWidget {
  const _TappableCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.all(18.padding),
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
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.radius),
        child: content,
      ),
    );
  }
}
