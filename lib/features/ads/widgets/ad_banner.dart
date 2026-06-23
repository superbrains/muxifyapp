import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/features/ads/models/served_ad.dart';
import 'package:muxify/features/ads/providers/ad_provider.dart';
import 'package:muxify/features/ads/screens/ad_webview_screen.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// A self-contained sponsored ad slot. Fetches an ad for [surface] on init,
/// fires the impression when shown, and on tap records the click and opens the
/// advertiser's URL. Renders nothing (zero height) when there is no ad to show,
/// so it's safe to drop into any feed or screen.
class AdBanner extends StatefulWidget {
  final String surface;
  final String? format;
  final String? targetContentId;
  final EdgeInsetsGeometry padding;

  const AdBanner({
    super.key,
    required this.surface,
    this.format,
    this.targetContentId,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late final AdProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AdProvider();
    _provider.load(
      surface: widget.surface,
      format: widget.format,
      targetContentId: widget.targetContentId,
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _onTap(ServedAd ad) async {
    // Record (and bill) the click first, then open the destination.
    await _provider.registerClick();
    final url = ad.clickUrl?.trim();
    if (!mounted || url == null || url.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdWebViewScreen(url: url, title: ad.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final ad = _provider.ad;
        if (ad == null) return const SizedBox.shrink();
        return Padding(
          padding: widget.padding,
          child: _AdCard(ad: ad, onTap: () => _onTap(ad)),
        );
      },
    );
  }
}

class _AdCard extends StatelessWidget {
  final ServedAd ad;
  final VoidCallback onTap;

  const _AdCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassyDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.buttonColor.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: _Creative(ad: ad),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Sponsored',
                        style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ad.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap to learn more',
                      style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Color(0xFFB0B0B0)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the creative. Photo and audio ads show their image via the authed
/// proxy (audio ads carry a cover image); video shows a branded format tile.
class _Creative extends StatelessWidget {
  final ServedAd ad;

  const _Creative({required this.ad});

  @override
  Widget build(BuildContext context) {
    final image = ad.displayImageUrl;
    if (image != null && image.isNotEmpty) {
      return AuthNetworkImage(
        path: image,
        fit: BoxFit.cover,
        width: 84,
        height: 84,
        placeholder: _fallback(),
        errorWidget: _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final icon = ad.format == 'video'
        ? Icons.play_circle_outline
        : ad.format == 'audio'
            ? Icons.graphic_eq
            : Icons.image_outlined;
    return Container(
      color: AppColors.darkGreyButtonColor,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.buttonColor, size: 28),
    );
  }
}
