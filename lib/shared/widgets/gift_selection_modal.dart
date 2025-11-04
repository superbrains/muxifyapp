import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/features/statistics/widgets/gift_item_widget.dart';

class GiftSelectionModal extends StatelessWidget {
  final String totalGiftValue;
  final List<GiftItem> giftItems;
  final VoidCallback? onClose;
  final Function(GiftItem)? onGiftSelected;

  const GiftSelectionModal({
    super.key,
    required this.totalGiftValue,
    required this.giftItems,
    this.onClose,
    this.onGiftSelected,
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
                  Navigator.of(context).pop();
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
            Padding(
              padding: EdgeInsets.only(left: 36.padding, right: 37.padding),
              child: Text(
                'Received Gift',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 21.font,
                  fontWeight: FontWeight.w400,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            21.column,
            // Gift Value Display
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pngs/gift.png',
                    width: 33.maxWidth,
                    height: 33.maxHeight,
                  ),
                  8.row,
                  Text(
                    totalGiftValue,
                    style: AppTextStyles.displayText.copyWith(
                      fontSize: 24.font,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            30.column,
            // Gift Items Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 19.padding),
                child: GridView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.only(bottom: 42.padding),
                  // physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65.maxHeight,
                  ),
                  itemCount: giftItems.length,
                  itemBuilder: (context, index) {
                    final giftItem = giftItems[index];
                    return GiftItemWidget(
                      item: giftItem,
                      onTap: () {
                        onGiftSelected?.call(giftItem);
                        Navigator.of(context).pop();
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
}
