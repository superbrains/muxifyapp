import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _effectiveDate = 'May 9, 2026';

  static const List<_PolicySection> _sections = [
    _PolicySection(
      title: '1. Information we collect',
      body:
          'When you create a Muxify account we collect your email address, '
          'phone number (optional), display name, and the avatar you select. '
          'We collect listening history, gifts, unlocks, and coin transactions '
          'so we can power your home feed and pay artists fairly. Device '
          'identifiers and crash reports are collected to keep the app stable.',
    ),
    _PolicySection(
      title: '2. How we use your data',
      body:
          'We use your data to deliver music and video, recommend artists, '
          'attribute streams to creators, prevent fraud, and respond to '
          'support requests. We do not sell your personal data. Aggregated, '
          'non-identifying analytics may be shared with artists about how '
          'their content performs.',
    ),
    _PolicySection(
      title: '3. Payments and coins',
      body:
          'Muxify Coins are a digital prepaid balance, not legal tender. '
          'Coin top-ups are processed by our payment partners; we never '
          'store your card number. Transaction logs are retained for tax '
          'and dispute resolution as required by law.',
    ),
    _PolicySection(
      title: '4. Your choices',
      body:
          'You can update your avatar, name, and phone number any time from '
          'the Profile menu. You can request deletion of your account from '
          'Settings → Delete Account; pending payouts and coin balances are '
          'forfeited at deletion. Marketing emails can be unsubscribed from '
          'the email footer or via Customer Services.',
    ),
    _PolicySection(
      title: '5. Children',
      body:
          'Muxify is not directed at children under 13. If we learn we have '
          'collected data from a child under 13 without verifiable parental '
          'consent, we delete it.',
    ),
    _PolicySection(
      title: '6. Security',
      body:
          'Passwords and PINs are stored using Argon2id hashing. Tokens are '
          'short-lived and bound to your device. We use HTTPS everywhere '
          'and review our infrastructure regularly. No system is perfectly '
          'secure — please use a unique password and enable biometric login '
          'where supported.',
    ),
    _PolicySection(
      title: '7. International transfers',
      body:
          'Muxify operates from Nigeria with infrastructure in South Africa '
          'and the European Union. By using the service you consent to your '
          'data being processed in these regions under contractual safeguards '
          'consistent with your local data-protection laws.',
    ),
    _PolicySection(
      title: '8. Changes to this policy',
      body:
          'We may update this policy as the product evolves. Material changes '
          'will be announced in-app at least 14 days before they take effect. '
          'Continued use of Muxify after the effective date constitutes '
          'acceptance of the updated policy.',
    ),
    _PolicySection(
      title: '9. Contact us',
      body:
          'Questions about this policy? Reach our team at privacy@muxify.app '
          'or through Customer Services in the app menu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'Privacy Policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSectionCard(
            child: Row(
              children: [
                Icon(Icons.event_available_outlined,
                    color: AppColors.green, size: 20.icon),
                12.row,
                Expanded(
                  child: Text(
                    'Effective $_effectiveDate',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.font,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          16.column,
          Text(
            'This Privacy Policy explains how Muxify collects, uses, and '
            'protects your information when you use our mobile application '
            'and services.',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              color: AppColors.text.withValues(alpha: 0.75),
              height: 1.55,
            ),
          ),
          20.column,
          for (final s in _sections) ...[
            _SectionBlock(section: s),
            14.column,
          ],
        ],
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({required this.title, required this.body});
  final String title;
  final String body;
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final _PolicySection section;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          10.column,
          Text(
            section.body,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.font,
              height: 1.6,
              color: AppColors.text.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
