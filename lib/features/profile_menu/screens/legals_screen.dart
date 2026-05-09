import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

class LegalsScreen extends StatelessWidget {
  const LegalsScreen({super.key});

  static const String _effectiveDate = 'May 9, 2026';

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'Legals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSectionCard(
            child: Row(
              children: [
                Icon(Icons.gavel_outlined,
                    color: AppColors.badgeRating, size: 20.icon),
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
          18.column,
          _LegalGroup(
            title: 'Terms of Service',
            blocks: [
              _LegalBlock(
                heading: '1. Your account',
                body:
                    'You must be at least 13 years old to use Muxify. Keep '
                    'your password and PIN private — anyone using your '
                    'credentials acts on your behalf. Notify us immediately '
                    'if you suspect unauthorized access.',
              ),
              _LegalBlock(
                heading: '2. Acceptable use',
                body:
                    'Do not scrape, reverse-engineer, or redistribute Muxify '
                    'content. Do not impersonate artists or other users. '
                    'Hateful, fraudulent, or illegal behavior will result in '
                    'suspension without refund.',
              ),
              _LegalBlock(
                heading: '3. Coins and gifts',
                body:
                    'Muxify Coins are non-refundable and non-transferable '
                    'except as required by law. Promotional coins expire 90 '
                    'days after issuance. Gifts sent to artists are final '
                    'once delivered.',
              ),
              _LegalBlock(
                heading: '4. Content licensing',
                body:
                    'Streams, downloads, and unlocks are personal, '
                    'non-exclusive licenses. You may not record, broadcast, '
                    'or commercially exploit Muxify content without written '
                    'permission from the rights holders.',
              ),
              _LegalBlock(
                heading: '5. Termination',
                body:
                    'You can close your account at any time from Settings. '
                    'Muxify may suspend or terminate accounts that violate '
                    'these terms or applicable law. Sections that should '
                    'reasonably survive termination will continue to apply.',
              ),
              _LegalBlock(
                heading: '6. Disclaimers',
                body:
                    'Muxify is provided "as is" and "as available". We do '
                    'not warrant uninterrupted or error-free service. To the '
                    'fullest extent permitted by law, we exclude implied '
                    'warranties of merchantability and fitness for purpose.',
              ),
              _LegalBlock(
                heading: '7. Liability',
                body:
                    'Our aggregate liability arising from your use of Muxify '
                    'will not exceed the greater of NGN 10,000 or the '
                    'amount you paid us in the 12 months preceding the claim.',
              ),
              _LegalBlock(
                heading: '8. Governing law',
                body:
                    'These terms are governed by the laws of the Federal '
                    'Republic of Nigeria. Disputes will be resolved in the '
                    'courts of Lagos State unless otherwise required.',
              ),
            ],
          ),
          14.column,
          _LegalGroup(
            title: 'End User License Agreement',
            blocks: [
              _LegalBlock(
                heading: 'License grant',
                body:
                    'Subject to these terms, Muxify grants you a personal, '
                    'revocable, non-transferable license to install and use '
                    'the Muxify mobile app on devices you control.',
              ),
              _LegalBlock(
                heading: 'Restrictions',
                body:
                    'You may not modify, decompile, or create derivative '
                    'works of the app. Automated tooling, bots, and emulator '
                    'farms are prohibited.',
              ),
              _LegalBlock(
                heading: 'Updates',
                body:
                    'We may push updates that add, change, or remove '
                    'features. Some updates may be required for the app to '
                    'continue functioning.',
              ),
              _LegalBlock(
                heading: 'Open source',
                body:
                    'The app uses open-source libraries. A list of '
                    'attributions is available at muxify.app/oss.',
              ),
            ],
          ),
          14.column,
          _LegalGroup(
            title: 'Community guidelines',
            blocks: [
              _LegalBlock(
                heading: 'Be respectful',
                body:
                    'Comments, gifts, and direct interactions should be '
                    'respectful. Harassment, doxxing, and threats are not '
                    'tolerated.',
              ),
              _LegalBlock(
                heading: 'No fraud',
                body:
                    'Do not buy, sell, or transfer coins outside of Muxify. '
                    'Do not exploit refunds, chargebacks, or promotional '
                    'codes obtained in bad faith.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalBlock {
  const _LegalBlock({required this.heading, required this.body});
  final String heading;
  final String body;
}

class _LegalGroup extends StatelessWidget {
  const _LegalGroup({required this.title, required this.blocks});

  final String title;
  final List<_LegalBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ProfileSectionCard(
        padding: EdgeInsets.symmetric(horizontal: 8.padding, vertical: 4.padding),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 8.padding),
          childrenPadding: EdgeInsets.fromLTRB(8.padding, 0, 8.padding, 8.padding),
          iconColor: AppColors.text,
          collapsedIconColor: AppColors.text,
          title: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            for (final b in blocks) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  b.heading,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.font,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withValues(alpha: 0.9),
                  ),
                ),
              ),
              6.column,
              Text(
                b.body,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.font,
                  height: 1.55,
                  color: AppColors.text.withValues(alpha: 0.72),
                ),
              ),
              14.column,
            ],
          ],
        ),
      ),
    );
  }
}
