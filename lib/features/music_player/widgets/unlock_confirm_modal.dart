import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/music_player/providers/music_player_interaction_provider.dart';

/// Coin-cost confirmation modal shown when the user taps the lock icon on a
/// premium track. Calls the existing
/// `POST /api/v1/content/tracks/{id}/unlock` via [MusicPlayerInteractionProvider]
/// and notifies the caller via [onUnlocked] so the player background can
/// switch to the unlocked treatment.
class UnlockConfirmModal extends StatefulWidget {
  final String trackId;
  final String trackTitle;
  final String artistName;
  final int unlockCostCoins;
  final MusicPlayerInteractionProvider interaction;
  final VoidCallback? onUnlocked;

  const UnlockConfirmModal({
    super.key,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.unlockCostCoins,
    required this.interaction,
    this.onUnlocked,
  });

  static Future<void> show(
    BuildContext context, {
    required String trackId,
    required String trackTitle,
    required String artistName,
    required int unlockCostCoins,
    required MusicPlayerInteractionProvider interaction,
    VoidCallback? onUnlocked,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => UnlockConfirmModal(
        trackId: trackId,
        trackTitle: trackTitle,
        artistName: artistName,
        unlockCostCoins: unlockCostCoins,
        interaction: interaction,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  State<UnlockConfirmModal> createState() => _UnlockConfirmModalState();
}

class _UnlockConfirmModalState extends State<UnlockConfirmModal> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    try {
      await widget.interaction.unlockTrack(widget.trackId);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onUnlocked?.call();
      await AppToast.showInfo('Track unlocked');
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

  @override
  Widget build(BuildContext context) {
    final cost = widget.unlockCostCoins;
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
              'Unlock this song?',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 20.font,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            12.column,
            Text(
              '${widget.trackTitle} · ${widget.artistName}',
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
                    cost > 0 ? '$cost coins' : 'Free',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            24.column,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(),
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
                  child: FilledButton(
                    onPressed: _busy ? null : _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.text,
                      padding: EdgeInsets.symmetric(vertical: 14.padding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.radius),
                      ),
                    ),
                    child: _busy
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
