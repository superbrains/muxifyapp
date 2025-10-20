import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/circular_icon_button.dart';

class MusicPlayerTopBar extends StatelessWidget {
  final String artistName;
  final String albumName;
  final bool isUnlocked;
  final VoidCallback onToggleUnlock;

  const MusicPlayerTopBar({
    super.key,
    required this.artistName,
    required this.albumName,
    required this.isUnlocked,
    required this.onToggleUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.padding,
        bottom: 7.padding,
        left: 23.padding,
        right: 23.padding,
      ),
      child: Row(
        children: [
          // Back Button
          CircularIconButton(
            onTap: () {
              context.pop();
            },
            icon: Icons.keyboard_arrow_down,
          ),

          const Spacer(),

          // Artist Name and Album
          Column(
            children: [
              Text(
                artistName,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 18.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                albumName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12.font,
                ),
              ),
            ],
          ),

          const Spacer(),

          // More Options / Toggle for testing
          CircularIconButton(
            onTap: () {
              onToggleUnlock();
              HapticFeedback.lightImpact();
            },
            icon: isUnlocked ? Icons.lock_open : Icons.lock,
          ),
        ],
      ),
    );
  }
}

