import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

class SendGiftsButton extends StatelessWidget {
  final VoidCallback onTap;

  const SendGiftsButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return UnlockButton(
      height: 53.buttonHeight,
      width: double.infinity,
      fontSize: 18.font,
      text: 'Send Gifts',
      iconPath: 'assets/pngs/gift.png',
      backgroundColor: AppColors.buttonColor.withValues(alpha: 0.5),
      textColor: AppColors.text,
      iconColor: Colors.white,
      iconSize: 20.icon,
      spacing: 8.padding,
      borderRadius: 25.radius,
      padding: EdgeInsets.symmetric(vertical: 13.padding),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}

