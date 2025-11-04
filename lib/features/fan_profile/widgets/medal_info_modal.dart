import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class MedalInfoModal extends StatelessWidget {
  final String medalName;
  final String medalDescription;
  final String medalImagePath;

  const MedalInfoModal({
    super.key,
    required this.medalName,
    required this.medalDescription,
    required this.medalImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.padding),
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.circular(20.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.padding),
              child: Text(
                'MEDAL INFO',
                style: AppTextStyles.displayText.copyWith(
                  color: AppColors.text,
                  fontSize: 30.font,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            27.column,
            // Medal Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Image.asset(
                medalImagePath,
                width: 120.maxWidth,
                height: 120.maxHeight,
                fit: BoxFit.cover,
              ),
            ),

            27.column,

            // Medal Name
            Text(
              textAlign: TextAlign.center,
              medalName,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.text,
                fontSize: 20.font,
                fontWeight: FontWeight.w600,
              ),
            ),

            4.column,

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 41.padding),
              child: Text(
                medalDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                  fontSize: 14.font,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            30.column,
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String medalName,
    required String medalDescription,
    required String medalImagePath,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MedalInfoModal(
        medalName: medalName,
        medalDescription: medalDescription,
        medalImagePath: medalImagePath,
      ),
    );
  }
}
