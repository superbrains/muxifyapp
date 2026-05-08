import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/features/statistics/widgets/gift_item_widget.dart';
import 'package:muxify/features/music_player/widgets/send_gift_bottom_sheet.dart';

class GiftBoxModal extends StatelessWidget {
  final String? headerText;
  final String? subHeaderText;
  final List<GiftItem> giftItems;
  final VoidCallback? onClose;
  final Function(GiftItem)? onGiftSelected;

  /// When provided, the inner SendGiftBottomSheet's primary CTA in demo mode
  /// becomes "Send Gift" and invokes this callback with the selected gift.
  /// Wire this from screens that have a real artist context (e.g. artist
  /// profile) so the gift is actually sent to the backend.
  final Function(GiftItem)? onSendGift;

  const GiftBoxModal({
    super.key,
    this.headerText,
    this.subHeaderText,
    required this.giftItems,
    this.onClose,
    this.onGiftSelected,
    this.onSendGift,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 371.maxWidth,
        constraints: BoxConstraints(
          maxHeight: 695.maxHeight,
          maxWidth: 371.maxWidth,
        ),
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.circular(20.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClose?.call();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 7.padding, right: 8.padding),
                  width: 29.maxWidth,
                  height: 29.maxHeight,

                  decoration: BoxDecoration(
                    color: AppColors.modalCancelButtonBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.text,
                    size: 11.icon,
                  ),
                ),
              ),
            ),

            // Gift Value Display
            Text(
              headerText ?? 'GIFTBOX',
              style: AppTextStyles.displayText.copyWith(
                fontSize: 24.font,
                color: AppColors.text,
              ),
            ),

            15.column,
            Text(
              subHeaderText ?? 'Tap to send gift',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 16.font,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),

            40.column,
            // Gift Items Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 19.padding),
                child: GridView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.only(bottom: 42.padding),
                  // physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: giftItems.length,
                  itemBuilder: (context, index) {
                    final giftItem = giftItems[index];
                    return GiftItemWidget(
                      item: giftItem,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showSendGiftBottomSheet(context, giftItem);
                      },
                    );
                  },
                ),
              ),
            ),
            // 20.column,
          ],
        ),
      ),
    );
  }

  void _showSendGiftBottomSheet(BuildContext context, GiftItem giftItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SendGiftBottomSheet(
          giftItem: giftItem,
          onClose: () {
            Navigator.of(context).pop();
          },
          onGetCoins: () {
            Navigator.of(context).pop();
          },
          onSendGift: onSendGift == null
              ? null
              : () => onSendGift!(giftItem),
        );
      },
    );
  }
}
