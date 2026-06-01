import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';

/// Branded loading state that reuses the splash-screen identity — the Muxify
/// logo on a dark surface — with a gentle pulse so the user gets immediate,
/// on-brand feedback while audio (or any short async work) resolves.
///
/// Used as an overlay inside the music player while the first source buffers.
class MuxifyBrandedLoader extends StatefulWidget {
  const MuxifyBrandedLoader({
    super.key,
    this.logoSize = 128,
    this.backgroundColor,
    this.message,
  });

  /// Width of the logo, mirroring the splash screen's 164 at a smaller scale.
  final double logoSize;

  /// Surface colour behind the logo. Defaults to a translucent scrim so it can
  /// sit over existing player chrome without fully hiding it.
  final Color? backgroundColor;

  /// Optional caption shown beneath the logo (e.g. "Loading…").
  final String? message;

  @override
  State<MuxifyBrandedLoader> createState() => _MuxifyBrandedLoaderState();
}

class _MuxifyBrandedLoaderState extends State<MuxifyBrandedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.86, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? AppColors.background.withValues(alpha: 0.82),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulse,
            child: FadeTransition(
              opacity: _pulse,
              child: Image.asset(
                'assets/pngs/logo.png',
                width: widget.logoSize,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
              backgroundColor: AppColors.text.withValues(alpha: 0.16),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
