import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class MusicProgressBar extends StatelessWidget {
  final double currentPosition;
  final double totalDuration;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const MusicProgressBar({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            padding: EdgeInsets.zero,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
            trackHeight: 10.border,
            trackShape: RoundedRectSliderTrackShape(),
          ),
          child: Slider.adaptive(
            value: currentPosition,
            min: 0.0,
            max: totalDuration,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        9.column,
        // Time Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(currentPosition),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12.font,
              ),
            ),
            Text(
              _formatTime(totalDuration),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12.font,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
