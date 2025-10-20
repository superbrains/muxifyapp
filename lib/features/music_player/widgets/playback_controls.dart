import 'package:flutter/material.dart';
import 'package:muxify/shared/widgets/circular_icon_button.dart';

class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool isRepeating;
  final bool isShuffled;
  final VoidCallback onTogglePlay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleRepeat;
  final VoidCallback onToggleShuffle;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.isRepeating,
    required this.isShuffled,
    required this.onTogglePlay,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleRepeat,
    required this.onToggleShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Repeat Button
        CircularIconButton(
          buttonSize: 44,
          backgroundColor: Colors.transparent,
          onTap: onToggleRepeat,
          icon: Icons.repeat,
        ),

        // Previous Button
        CircularIconButton(
          buttonSize: 53,
          onTap: onPrevious,
          icon: Icons.skip_previous,
        ),

        // Play/Pause Button
        CircularIconButton(
          buttonSize: 80,
          iconSize: 45,
          onTap: onTogglePlay,
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        ),

        // Next Button
        CircularIconButton(
          buttonSize: 53,
          onTap: onNext,
          icon: Icons.skip_next,
        ),

        // Shuffle Button
        CircularIconButton(
          buttonSize: 44,
          backgroundColor: Colors.transparent,
          onTap: onToggleShuffle,
          icon: Icons.shuffle,
        ),
      ],
    );
  }
}

