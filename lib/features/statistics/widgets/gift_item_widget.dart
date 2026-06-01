import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/sticker_text.dart';

class GiftItemWidget extends StatelessWidget {
  final GiftItem item;
  final VoidCallback? onTap;

  const GiftItemWidget({super.key, required this.item, this.onTap});

  Widget _buildImage(
    String pathOrUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    final t = pathOrUrl.trim();
    if (t.isEmpty) return const SizedBox.shrink();

    // Bundled assets (e.g. 'assets/pngs/...') render directly.
    if (t.toLowerCase().startsWith('assets/')) {
      return Image.asset(t, width: width, height: height, fit: fit);
    }

    // Gift images are served via the JWT-gated media proxy
    // (/api/v1/media/cover/gift-images/...) or an absolute URL. AuthNetworkImage
    // resolves relative proxy paths against the API base and attaches the bearer
    // token when the target is the Muxify API host.
    return AuthNetworkImage(
      path: t,
      width: width,
      height: height,
      fit: fit,
      placeholder: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: const Icon(Icons.card_giftcard, color: Colors.white70),
    );
  }

  DecorationImage? _buildDecorationImage(String pathOrUrl) {
    final t = pathOrUrl.trim();
    if (t.isEmpty) return null;

    final isNetwork =
        t.toLowerCase().startsWith('http://') ||
        t.toLowerCase().startsWith('https://');

    // The background is purely decorative — never let a missing/bad image throw
    // or spam the console; just fall back to no background.
    if (isNetwork) {
      return DecorationImage(
        image: CachedNetworkImageProvider(t),
        fit: BoxFit.fill,
        onError: (_, __) {},
      );
    }

    return DecorationImage(
      image: AssetImage(t),
      fit: BoxFit.fill,
      onError: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
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
                  image: _buildDecorationImage(item.backgroundImage),
                ),
              ),
              // Emoji in the center
              _buildImage(
                item.emojiImage,
                width: 40.maxWidth,
                height: 40.maxHeight,
              ),
              // Sticker text overlay at bottom - positioned to extend outside
              Positioned(
                bottom: -11.padding, // Negative bottom to extend outside
                child: StickerText(
                  // Show the actual gift name on the sticker instead of a
                  // generic "GIFT" label.
                  text: item.name.toUpperCase(),
                  fontSize: 16.font,
                  textColor: Colors.white,
                  strokeColor: Colors.black,
                  strokeWidth: 1.35.border,
                  rotation: 0,
                ),
              ),
            ],
          ),
          10.column,
          // Gift name. Kept as a plain (non-Flexible) Text so the widget also
          // lays out safely inside unbounded-height parents (e.g. the send-gift
          // sheet). The GIFTBOX grid gives it enough height via childAspectRatio.
          Text(
            item.name,
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
          2.column,
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
                'm${CoinRate.groupThousands((item.amount ?? 0).toInt())}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 8.font,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
