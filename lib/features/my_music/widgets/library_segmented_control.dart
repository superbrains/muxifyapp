import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// Three-segment selector used at the top of the Library tab. Brand red active
/// pill slides under the selected label; the wrapper is a frosted-glass card
/// matching the now-playing screen aesthetic.
enum LibraryGrouping { all, byArtist, byGenre }

class LibrarySegmentedControl extends StatelessWidget {
  const LibrarySegmentedControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LibraryGrouping value;
  final ValueChanged<LibraryGrouping> onChanged;

  static const _segments = [
    (LibraryGrouping.all, 'All'),
    (LibraryGrouping.byArtist, 'By artist'),
    (LibraryGrouping.byGenre, 'By genre'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segmentWidth = width / _segments.length;
        final selectedIndex = _segments.indexWhere((s) => s.$1 == value);

        return Container(
          height: 44.maxHeight,
          padding: EdgeInsets.all(4.padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassyDark.withValues(alpha: 0.85),
                AppColors.glassyLight.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(22.radius),
            border: Border.all(
              color: AppColors.text.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: selectedIndex * (segmentWidth - (8 / _segments.length)),
                top: 0,
                bottom: 0,
                width: segmentWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(18.radius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.buttonColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: _segments.map((seg) {
                  final isActive = seg.$1 == value;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (isActive) return;
                        HapticFeedback.selectionClick();
                        onChanged(seg.$1);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.font,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? AppColors.text
                                : AppColors.text.withValues(alpha: 0.6),
                          ),
                          child: Text(seg.$2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
