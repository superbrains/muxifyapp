import 'package:flutter/material.dart';
import 'package:muxify/features/music_player/providers/music_player_interaction_provider.dart';
import 'package:muxify/shared/widgets/content_unlock_confirm_modal.dart';

/// Coin-cost confirmation modal shown when the user taps the lock icon on a
/// premium track. Thin wrapper that delegates to the shared
/// [ContentUnlockConfirmModal] so music and video share one identical unlock
/// UX. Calls `POST /api/v1/content/tracks/{id}/unlock` via
/// [MusicPlayerInteractionProvider] and notifies the caller via [onUnlocked].
class UnlockConfirmModal {
  const UnlockConfirmModal._();

  static Future<void> show(
    BuildContext context, {
    required String trackId,
    required String trackTitle,
    required String artistName,
    required int unlockCostCoins,
    required MusicPlayerInteractionProvider interaction,
    int coinsPerNairaMajor = 50,
    VoidCallback? onUnlocked,
  }) {
    return ContentUnlockConfirmModal.show(
      context,
      lockPrompt: 'Unlock this song?',
      contentTitle: trackTitle,
      artistName: artistName,
      unlockCostCoins: unlockCostCoins,
      coinsPerNairaMajor: coinsPerNairaMajor,
      successMessage: 'Track unlocked',
      onUnlock: () => interaction.unlockTrack(trackId),
      onUnlocked: onUnlocked,
    );
  }
}
