import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/music_player/widgets/payment_method_bottom_sheet.dart';

class BuyCoinButton extends StatelessWidget {
  const BuyCoinButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showPaymentMethodBottomSheet(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF94444), // Red background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.radius),
          ),
          elevation: 0,
        ),
        child: Text(
          'Buy Coin',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          PaymentMethodBottomSheet(onClose: () => Navigator.of(context).pop()),
    );
  }
}
