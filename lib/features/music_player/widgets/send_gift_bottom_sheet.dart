import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/sticker_text.dart';

class SendGiftBottomSheet extends StatelessWidget {
  final GiftItem giftItem;
  final VoidCallback onClose;
  final VoidCallback onGetCoins;

  const SendGiftBottomSheet({
    super.key,
    required this.giftItem,
    required this.onClose,
    required this.onGetCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 536.maxHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.radius),
          topRight: Radius.circular(20.radius),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          33.column,
          // Gift Item Display
          _buildGiftItemDisplay(),
          30.column,
          // Error Message
          _buildErrorMessage(),
          const Spacer(),

          // Terms of Gifting
          _buildTermsSection(),
          25.column,
          // Get Coins Button
          _buildGetCoinsButton(context),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.padding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.padding,
        left: 20.padding,
        right: 20.padding,
        // bottom: 20.padding,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onClose();
            },
            child: Icon(Icons.arrow_back, color: Colors.white, size: 30.icon),
          ),
          Expanded(
            child: Text(
              'Send Gifts',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 20.font,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 20.maxWidth), // Balance the back arrow
        ],
      ),
    );
  }

  Widget _buildGiftItemDisplay() {
    return Column(
      children: [
        // Stack with background, emoji, and sticker text
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow overflow for sticker text
          children: [
            // Background image
            Container(
              width: 68.maxWidth,
              height: 68.maxHeight,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(12.radius),
                image: DecorationImage(
                  image: AssetImage('assets/pngs/gift_bg1.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Emoji in the center
            Image.asset(
              'assets/pngs/emoj1.png',
              width: 40.maxWidth,
              height: 40.maxHeight,
            ),
            // Sticker text overlay at bottom - positioned to extend outside
            Positioned(
              bottom: -11.padding, // Negative bottom to extend outside
              child: StickerText(
                text: 'X20',
                fontSize: 16.font,
                textColor: Colors.white,
                strokeColor: Colors.black,
                strokeWidth: 1.35.border,
                rotation: 0,
              ),
            ),
          ],
        ),
        15.column,
        // Gift name
        Text(
          'Big Box',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.font,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // 8.column,
        // // Unlock button
        // UnlockButton(
        //   text: 'Gift',
        //   onTap: onTap,
        //   backgroundColor: AppColors.toggleSelected,
        //   textColor: AppColors.text,
        //   borderRadius: 15.radius,
        //   padding: EdgeInsets.symmetric(
        //     horizontal: 12.padding,
        //     vertical: 6.padding,
        //   ),
        // ),
        3.column,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 12.icon,
              height: 12.icon,
            ),
            8.row,
            Text(
              "m100,250",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 8.font,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      height: 53.maxHeight,
      padding: EdgeInsets.all(15.padding),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withValues(
          alpha: 0.3,
        ), // Reddish-brown background
        borderRadius: BorderRadius.circular(10.radius),
        border: Border.all(
          color: const Color(0xFFD32F2F), // Red border
          width: 1.border,
        ),
      ),
      child: Text(
        'You don\'t have enough coins gift this item',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontSize: 14.font,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTermsSection() {
    return SizedBox(
      width: 298.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Terms of Gifting',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 12.font,
              fontWeight: FontWeight.w400,
            ),
          ),

          12.column,

          Text(
            'By clicking Gifts, you coins equivalent to this user, this will be deducted from your coin balance. Lorem ipsum dolor sit amet consectetur. Purus odio ultrices eleifend mollis eu duis vel sed.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10.font,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGetCoinsButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.padding),

      width: double.infinity,
      height: 56.buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onClose(); // Close the bottom sheet first
          context.push(AppRouter.getCoins); // Navigate to get coins screen
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 13.padding),
          backgroundColor: AppColors.greyButtonColor, // Dark gray
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.radius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            // Coin icon with sound waves
            // Stack(
            //   alignment: Alignment.center,
            //   children: [
            //     // Sound wave effect
            //     Container(
            //       width: 30.maxWidth,
            //       height: 30.maxHeight,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         border: Border.all(
            //           color: const Color(0xFFFF9800).withValues(alpha: 0.3),
            //           width: 1.border,
            //         ),
            //       ),
            //     ),
            //     Container(
            //       width: 20.maxWidth,
            //       height: 20.maxHeight,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         border: Border.all(
            //           color: const Color(0xFFFF9800).withValues(alpha: 0.5),
            //           width: 1.border,
            //         ),
            //       ),
            //     ),
            //     // Coin icon
            //     Icon(
            //       Icons.monetization_on,
            //       color: const Color(0xFFFF9800),
            //       size: 16.icon,
            //     ),
            //   ],
            // ),
            Image.asset(
              'assets/pngs/multi_coin.png',
              width: 60.icon,
              height: 36.icon,
              fit: BoxFit.contain,
            ),

            70.row,

            Text(
              'Get Coins',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontSize: 18.font,
                fontWeight: FontWeight.w400,
              ),
            ),
            10.row,
          ],
        ),
      ),
    );
  }
}
