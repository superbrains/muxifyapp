import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// Solid-red "Buy Coin" CTA. The button is presentation-only; the parent
/// screen owns the purchase flow (package selection, payment-method sheet,
/// status navigation) so this widget stays trivial to reuse.
class BuyCoinButton extends StatelessWidget {
  const BuyCoinButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.label = 'Buy Coins',
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF94444),
          disabledBackgroundColor: const Color(0xFFF94444).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.radius),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
