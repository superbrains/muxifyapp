import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class GetCoinsHeader extends StatelessWidget implements PreferredSizeWidget {
  const GetCoinsHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.icon),
      ),
      title: Text(
        'Get Coins',
        style: AppTextStyles.heading2.copyWith(
          color: Colors.white,
          fontSize: 18.font,
          fontWeight: FontWeight.w400,
        ),
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: EdgeInsets.only(right: 16.padding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24.maxWidth,
                  height: 24.maxHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 12.icon,
                    ),
                  ),
                ),
                8.row,
                Text(
                  'How to!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 12.font,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
