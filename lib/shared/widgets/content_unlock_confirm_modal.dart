import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';

/// Content-agnostic coin-cost confirmation modal shown when a user unlocks a
/// premium item (track OR video). It owns the entire unlock UX so both flows
/// are byte-for-byte identical: live wallet balance, ≈₦ value, a `Get Coins`
/// fallback when short, a busy spinner, error surfacing via [AppToast], and the
/// [onUnlocked] callback on success.
///
/// The actual API call is injected via [onUnlock] (e.g.
/// `MusicPlayerRepository.unlockTrack` or `VideoRepository.unlockVideo`) and is
/// expected to THROW on failure so this modal can keep the UI locked.
class ContentUnlockConfirmModal extends StatefulWidget {
  /// Prompt shown at the top, e.g. "Unlock this song?" / "Unlock this video?".
  final String lockPrompt;
  final String contentTitle;
  final String artistName;
  final int unlockCostCoins;

  /// Coins per ₦1, used to show the Naira equivalent of the coin cost.
  final int coinsPerNairaMajor;

  /// Performs the unlock API call. Must throw on failure.
  final Future<void> Function() onUnlock;

  /// Toast shown on success, e.g. "Track unlocked" / "Video unlocked".
  final String successMessage;
  final VoidCallback? onUnlocked;

  const ContentUnlockConfirmModal({
    super.key,
    required this.lockPrompt,
    required this.contentTitle,
    required this.artistName,
    required this.unlockCostCoins,
    required this.onUnlock,
    required this.successMessage,
    this.coinsPerNairaMajor = 10,
    this.onUnlocked,
  });

  static Future<void> show(
    BuildContext context, {
    required String lockPrompt,
    required String contentTitle,
    required String artistName,
    required int unlockCostCoins,
    required Future<void> Function() onUnlock,
    required String successMessage,
    int coinsPerNairaMajor = 10,
    VoidCallback? onUnlocked,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ContentUnlockConfirmModal(
        lockPrompt: lockPrompt,
        contentTitle: contentTitle,
        artistName: artistName,
        unlockCostCoins: unlockCostCoins,
        onUnlock: onUnlock,
        successMessage: successMessage,
        coinsPerNairaMajor: coinsPerNairaMajor,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  State<ContentUnlockConfirmModal> createState() =>
      _ContentUnlockConfirmModalState();
}

class _ContentUnlockConfirmModalState extends State<ContentUnlockConfirmModal> {
  final WalletApiService _wallet = WalletApiService();

  bool _busy = false;
  bool _loading = true;
  int _balance = 0;

  bool get _canAfford => _balance >= widget.unlockCostCoins;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  // The coin/Naira rate is passed in by the caller; here we only need the
  // wallet balance to decide between the Unlock and Get Coins actions.
  Future<void> _hydrate() async {
    final summary = await _wallet.fetchWalletSummary();
    if (!mounted) return;
    setState(() {
      _balance = summary.balance;
      _loading = false;
    });
  }

  void _getCoins() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    context.push(AppRouter.getCoins);
  }

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    try {
      await widget.onUnlock();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onUnlocked?.call();
      await AppToast.showInfo(widget.successMessage);
    } catch (e) {
      if (!mounted) return;
      await AppToast.showError(_humanise(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _humanise(Object e) {
    final raw = e.toString();
    // Strip the "ApiRequestException: " prefix some thrown messages carry.
    return raw.replaceFirst(RegExp(r'^[^:]+:\s*'), '');
  }

  Widget _buildPrimaryButton(int cost) {
    final mustTopUp = cost > 0 && !_loading && !_canAfford;
    if (mustTopUp) {
      return FilledButton(
        onPressed: _getCoins,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.text,
          padding: EdgeInsets.symmetric(vertical: 14.padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.radius),
          ),
        ),
        child: const Text(
          'Get Coins',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }
    return FilledButton(
      onPressed: (_busy || _loading) ? null : _confirm,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: AppColors.text,
        disabledBackgroundColor: AppColors.buttonColor.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(vertical: 14.padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.radius),
        ),
      ),
      child: (_busy || _loading)
          ? SizedBox(
              width: 18.icon,
              height: 18.icon,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Unlock',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cost = widget.unlockCostCoins;
    final rate = widget.coinsPerNairaMajor > 0 ? widget.coinsPerNairaMajor : 10;
    final nairaEquivalent = cost > 0 ? (cost / rate).round() : 0;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.padding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.circular(20.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.padding,
          vertical: 24.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.modalCancelButtonBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.text,
                size: 30.icon,
              ),
            ),
            16.column,
            Text(
              widget.lockPrompt,
              style: AppTextStyles.heading1.copyWith(
                fontSize: 20.font,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            12.column,
            Text(
              '${widget.contentTitle} · ${widget.artistName}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            20.column,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.padding,
                vertical: 12.padding,
              ),
              decoration: BoxDecoration(
                color: AppColors.modalCancelButtonBackground,
                borderRadius: BorderRadius.circular(14.radius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/pngs/Bitcoin_musixfy.png',
                    width: 24.icon,
                    height: 24.icon,
                  ),
                  10.row,
                  Text(
                    cost > 0 ? '${CoinRate.groupThousands(cost)} coins' : 'Free',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (cost > 0) ...[
              8.column,
              Text(
                '≈ ₦${CoinRate.groupThousands(nairaEquivalent)} value',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
            24.column,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _busy ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: BorderSide(
                        color: AppColors.text.withValues(alpha: 0.2),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.padding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.radius),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                12.row,
                Expanded(
                  child: _buildPrimaryButton(cost),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
