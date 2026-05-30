import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/features/statistics/widgets/gift_item_widget.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';

/// Confirms and sends a single gift to an artist. Reads the wallet balance +
/// coin/Naira rate so it can show the real cost, the ≈₦ value, and either a
/// **Send Gift** action (when affordable) or a **Get Coins** action (when the
/// wallet is short). Sending goes through
/// [ArtistProfileProvider.sendGift] → `POST /api/v1/gifts/send`.
class SendGiftBottomSheet extends StatefulWidget {
  final GiftItem giftItem;
  final String? recipientArtistId;
  final String? trackId;
  final String? videoId;
  final VoidCallback onClose;

  /// Called after a successful send so the caller can dismiss + refresh.
  final VoidCallback? onSent;

  const SendGiftBottomSheet({
    super.key,
    required this.giftItem,
    required this.onClose,
    this.recipientArtistId,
    this.trackId,
    this.videoId,
    this.onSent,
  });

  @override
  State<SendGiftBottomSheet> createState() => _SendGiftBottomSheetState();
}

class _SendGiftBottomSheetState extends State<SendGiftBottomSheet> {
  final WalletApiService _wallet = WalletApiService();

  bool _loading = true;
  bool _sending = false;
  int _balance = 0;
  CoinRate _rate = CoinRate.fallback();

  int get _cost => (widget.giftItem.amount ?? 0).toInt();
  bool get _canAfford => _balance >= _cost;
  bool get _canSend => (widget.recipientArtistId ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final results = await Future.wait([
      _wallet.fetchWalletSummary(),
      _wallet.fetchCoinRate(),
    ]);
    if (!mounted) return;
    setState(() {
      _balance = (results[0] as WalletSummary).balance;
      _rate = results[1] as CoinRate;
      _loading = false;
    });
  }

  Future<void> _send() async {
    if (_sending || !_canSend) return;
    setState(() => _sending = true);
    HapticFeedback.lightImpact();
    try {
      final response = await context.read<ArtistProfileProvider>().sendGift(
            artistId: widget.recipientArtistId!.trim(),
            giftType: widget.giftItem.id,
            trackId: widget.trackId,
            videoId: widget.videoId,
          );
      if (!mounted) return;
      if (response == null || !response.success) {
        setState(() => _sending = false);
        await AppToast.showError('Could not send gift. Please try again.');
        return;
      }
      await AppToast.showInfo('Sent ${widget.giftItem.name}!');
      widget.onSent?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      await AppToast.showError(_humanise(e));
    }
  }

  String _humanise(Object e) =>
      e.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');

  void _getCoins() {
    HapticFeedback.lightImpact();
    widget.onClose();
    context.push(AppRouter.getCoins);
  }

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
          _buildHeader(),
          33.column,
          _buildGiftItemDisplay(),
          30.column,
          if (!_loading && _canSend && !_canAfford) _buildErrorMessage(),
          const Spacer(),
          _buildTermsSection(),
          25.column,
          _buildPrimaryButton(),
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
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onClose();
            },
            child: Icon(Icons.arrow_back, color: AppColors.text, size: 30.icon),
          ),
          Expanded(
            child: Text(
              'Send Gifts',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.text,
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
        // Reuse the same tile the GIFTBOX grid uses so the selected gift looks
        // identical here (icon, sticker, name, coin cost).
        GiftItemWidget(item: widget.giftItem),
        6.column,
        // ≈ Naira equivalent of the coin cost.
        Text(
          _loading ? ' ' : _rate.nairaLabel(_cost),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10.font,
            fontWeight: FontWeight.w400,
            color: AppColors.text.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.padding),
      padding: EdgeInsets.all(15.padding),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10.radius),
        border: Border.all(
          color: const Color(0xFFD32F2F),
          width: 1.border,
        ),
      ),
      child: Text(
        "You don't have enough coins to gift this item",
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.text,
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
              color: AppColors.text,
              fontSize: 12.font,
              fontWeight: FontWeight.w400,
            ),
          ),
          12.column,
          Text(
            'By sending a gift, the selected coin amount will be deducted from your wallet and sent directly to this creator. Gifts are final and cannot be reversed.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
              fontSize: 10.font,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    // While balances load, keep the button inert.
    final showGetCoins = !_loading && _canSend && !_canAfford;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.padding),
      width: double.infinity,
      height: 56.buttonHeight,
      child: showGetCoins ? _getCoinsButton() : _sendButton(),
    );
  }

  Widget _sendButton() {
    final enabled = !_loading && !_sending && _canSend && _canAfford;
    return ElevatedButton(
      onPressed: enabled ? _send : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 13.padding),
        backgroundColor: AppColors.buttonColor,
        disabledBackgroundColor: AppColors.greyButtonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.radius),
        ),
        elevation: 0,
      ),
      child: _sending
          ? SizedBox(
              width: 22.icon,
              height: 22.icon,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              _loading ? 'Please wait…' : 'Send Gift',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.text,
                fontSize: 18.font,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }

  Widget _getCoinsButton() {
    return ElevatedButton(
      onPressed: _getCoins,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 13.padding),
        backgroundColor: AppColors.greyButtonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.radius),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
              color: AppColors.text,
              fontSize: 18.font,
              fontWeight: FontWeight.w400,
            ),
          ),
          10.row,
        ],
      ),
    );
  }
}
