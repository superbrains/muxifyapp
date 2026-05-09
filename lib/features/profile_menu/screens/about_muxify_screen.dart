import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

class AboutMuxifyScreen extends StatelessWidget {
  const AboutMuxifyScreen({super.key});

  static const String _appVersion = '1.0.0';
  static const String _buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'About Muxify',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          16.column,
          Center(
            child: Container(
              width: 96.icon,
              height: 96.icon,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.buttonColor,
                    AppColors.headerGradient,
                  ],
                ),
                borderRadius: BorderRadius.circular(24.radius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.radius),
                child: Image.asset(
                  'assets/pngs/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.equalizer,
                    color: AppColors.text,
                    size: 48.icon,
                  ),
                ),
              ),
            ),
          ),
          16.column,
          Text(
            'Muxify',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 26.font,
              fontWeight: FontWeight.w700,
            ),
          ),
          6.column,
          Text(
            'Where African sound meets the world.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              color: AppColors.text.withValues(alpha: 0.65),
            ),
          ),
          24.column,
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our mission',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                12.column,
                Text(
                  'Muxify connects fans, artists, and creators on a single '
                  'platform built for the way Africa listens. We make every '
                  'stream, gift, and unlock count toward the artists you '
                  'love — no middlemen, no opaque payouts, no compromise.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    height: 1.55,
                    color: AppColors.text.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          14.column,
          ProfileSectionCard(
            child: Column(
              children: [
                _InfoRow(label: 'Version', value: '$_appVersion ($_buildNumber)'),
                _Divider(),
                _InfoRow(label: 'Released', value: 'May 2026'),
                _Divider(),
                _InfoRow(label: 'Website', value: 'muxify.app'),
                _Divider(),
                _InfoRow(label: 'Made in', value: 'Lagos, Nigeria'),
              ],
            ),
          ),
          16.column,
          Text(
            '© 2026 Muxify. All rights reserved.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.font,
              color: AppColors.text.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.padding),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.font,
              color: AppColors.text.withValues(alpha: 0.55),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.font,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}
