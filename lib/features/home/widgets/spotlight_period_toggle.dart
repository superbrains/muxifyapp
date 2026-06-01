import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// A compact two-segment pill ("This Week" / "All Time") that scopes the gift
/// leaderboards' time window. Mirrors the toggle treatment used elsewhere in the
/// app (see [AppColors.toggleSelected]) so it reads as a first-class control.
class SpotlightPeriodToggle extends StatelessWidget {
  final String selectedPeriod; // 'week' | 'all'
  final ValueChanged<String> onPeriodChanged;

  const SpotlightPeriodToggle({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.padding),
      decoration: BoxDecoration(
        color: AppColors.toggleUnselected,
        borderRadius: BorderRadius.circular(24.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(label: 'This Week', value: 'week'),
          _segment(label: 'All Time', value: 'all'),
        ],
      ),
    );
  }

  Widget _segment({required String label, required String value}) {
    final selected = selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        if (selected) return;
        HapticFeedback.selectionClick();
        onPeriodChanged(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: 16.padding,
          vertical: 7.padding,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.toggleSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(24.radius),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.font,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.toggleSelectedText
                : AppColors.text.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
