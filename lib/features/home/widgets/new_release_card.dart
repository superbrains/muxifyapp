import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

class NewReleaseCard extends StatelessWidget {
  final NewReleaseItem release;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  const NewReleaseCard({
    super.key,
    required this.release,
    this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 135.maxWidth,
        height: 145.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.radius),
          child: Stack(
            children: [
              // Album Art Background
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildCover(),
              ),
              // Strong Gradient Overlay - Creates dark bottom area
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.shadowColor.withValues(alpha: 0.7),
                      AppColors.shadowColor.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.4, 0.7, 0.6],
                  ),
                ),
              ),
              // Text Content and Play Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.padding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF2C1810).withValues(alpha: 0.8),
                        const Color(0xFF1A0E08).withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(13.radius),
                      bottomRight: Radius.circular(13.radius),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Album Name
                            Text(
                              release.albumName,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12.font,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            4.column,
                            // Artist Name
                            Text(
                              release.artistName,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10.font,
                                fontWeight: FontWeight.w300,
                                color: AppColors.text.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onPlayTap?.call();
                        },
                        child: Container(
                          width: 32.icon,
                          height: 32.icon,
                          decoration: BoxDecoration(
                            color: AppColors.unlockButtonDefault,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.text,
                            size: 16.icon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    final url = release.imageUrl?.trim() ?? '';
    if (url.isEmpty) return _placeholderCover();
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      placeholder: _placeholderCover(),
      errorWidget: _placeholderCover(),
    );
  }

  Widget _placeholderCover() {
    return Image.asset(
      'assets/pngs/release_placeholder.png',
      fit: BoxFit.cover,
    );
  }
}
