import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/features/ads/providers/audio_ad_controller.dart';
import 'package:muxify/features/ads/screens/ad_webview_screen.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Full-screen, non-skippable overlay shown while an audio-ad interstitial plays
/// (driven by [AudioAdController]). Shows the ad's cover art, a live countdown,
/// and an optional "Learn more" that records the click and opens the advertiser
/// URL. Renders nothing when no interstitial is active.
class AudioAdOverlay extends StatelessWidget {
  const AudioAdOverlay({super.key});

  Future<void> _onLearnMore(BuildContext context, AudioAdController controller) async {
    final ad = controller.ad;
    final url = ad?.clickUrl?.trim();
    await controller.registerClick();
    if (!context.mounted || url == null || url.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdWebViewScreen(url: url, title: ad!.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioAdController>();
    final ad = controller.ad;
    if (!controller.active || ad == null) return const SizedBox.shrink();

    final remaining = controller.secondsRemaining;
    final image = ad.displayImageUrl;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.94),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SPONSORED',
                    style: TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: (image != null && image.isNotEmpty)
                        ? AuthNetworkImage(
                            path: image,
                            fit: BoxFit.cover,
                            width: 220,
                            height: 220,
                            placeholder: _imageFallback(),
                            errorWidget: _imageFallback(),
                          )
                        : _imageFallback(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  ad.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  remaining > 0 ? 'Your music resumes in ${remaining}s' : 'Resuming…',
                  style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                ),
                const SizedBox(height: 24),
                if ((ad.clickUrl?.trim().isNotEmpty ?? false))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onLearnMore(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Learn more',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        color: AppColors.darkGreyButtonColor,
        alignment: Alignment.center,
        child: const Icon(Icons.graphic_eq, color: AppColors.buttonColor, size: 48),
      );
}
