import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<_FaqGroup> _groups = [
    _FaqGroup(
      title: 'Account',
      icon: Icons.person_outline,
      items: [
        _FaqItem(
          q: 'How do I change my avatar?',
          a: 'Open the Profile menu (top-right avatar), tap My Profile, '
              'then tap your avatar to pick a preset or upload a new image.',
        ),
        _FaqItem(
          q: 'How do I verify my email?',
          a: 'Profile menu → Account Verification → Verify Email. We\'ll '
              'send a 6-digit code to your inbox.',
        ),
        _FaqItem(
          q: 'I forgot my password',
          a: 'On the login screen tap "Forgot password" and enter your '
              'registered email. Check your inbox (and spam) for the link.',
        ),
        _FaqItem(
          q: 'Can I change my username?',
          a: 'Yes — open My Profile → Edit. Usernames must be unique and '
              'between 3 and 20 characters.',
        ),
      ],
    ),
    _FaqGroup(
      title: 'Coins & payments',
      icon: Icons.monetization_on_outlined,
      items: [
        _FaqItem(
          q: 'What are Muxify Coins?',
          a: 'Coins are our in-app currency. You use them to unlock songs, '
              'send gifts to artists, and access premium content.',
        ),
        _FaqItem(
          q: 'How do I top up coins?',
          a: 'Profile menu → Wallet & Payment → Top Up. Pay with card, '
              'bank transfer, or USSD.',
        ),
        _FaqItem(
          q: 'Are coins refundable?',
          a: 'No — coins are non-refundable except as required by law. See '
              'Legals → Terms of Service for details.',
        ),
        _FaqItem(
          q: 'What is the transactional PIN for?',
          a: 'Your PIN protects coin spends. We\'ll ask for it before '
              'unlocking content, sending gifts, or initiating withdrawals.',
        ),
      ],
    ),
    _FaqGroup(
      title: 'Music & playback',
      icon: Icons.music_note_outlined,
      items: [
        _FaqItem(
          q: 'Why do some songs need to be unlocked?',
          a: 'Some artists put their newest releases behind a small coin '
              'unlock so they earn directly from their biggest fans.',
        ),
        _FaqItem(
          q: 'Can I listen offline?',
          a: 'Offline downloads are rolling out. Once available, you\'ll '
              'see a download icon next to unlocked songs.',
        ),
        _FaqItem(
          q: 'Why does playback stop in the background?',
          a: 'Make sure battery optimization is disabled for Muxify in '
              'your device settings.',
        ),
      ],
    ),
    _FaqGroup(
      title: 'Privacy & safety',
      icon: Icons.shield_outlined,
      items: [
        _FaqItem(
          q: 'Who can see my activity?',
          a: 'By default, your gifts and badges are visible on your public '
              'profile. Listening history is private.',
        ),
        _FaqItem(
          q: 'How do I delete my account?',
          a: 'Profile menu → Delete Account. Type DELETE to confirm. '
              'Pending coin balances and badges will be lost.',
        ),
        _FaqItem(
          q: 'Where is my data stored?',
          a: 'In encrypted databases hosted in South Africa and the EU. '
              'See Privacy Policy for details.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'FAQ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSectionCard(
            child: Row(
              children: [
                Icon(Icons.help_outline,
                    color: AppColors.blue, size: 22.icon),
                12.row,
                Expanded(
                  child: Text(
                    'Quick answers to the things fans ask us most.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.font,
                      color: AppColors.text.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          18.column,
          for (final g in _groups) ...[
            _FaqGroupBlock(group: g),
            14.column,
          ],
        ],
      ),
    );
  }
}

class _FaqGroup {
  const _FaqGroup({required this.title, required this.icon, required this.items});
  final String title;
  final IconData icon;
  final List<_FaqItem> items;
}

class _FaqItem {
  const _FaqItem({required this.q, required this.a});
  final String q;
  final String a;
}

class _FaqGroupBlock extends StatelessWidget {
  const _FaqGroupBlock({required this.group});

  final _FaqGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.padding, bottom: 10.padding),
          child: Row(
            children: [
              Icon(group.icon,
                  color: AppColors.text.withValues(alpha: 0.7), size: 18.icon),
              8.row,
              Text(
                group.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.font,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text.withValues(alpha: 0.85),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        ProfileSectionCard(
          padding: EdgeInsets.symmetric(horizontal: 8.padding, vertical: 4.padding),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: [
                for (var i = 0; i < group.items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ExpansionTile(
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 8.padding, vertical: 4.padding),
                    childrenPadding:
                        EdgeInsets.fromLTRB(8.padding, 0, 8.padding, 12.padding),
                    iconColor: AppColors.text,
                    collapsedIconColor: AppColors.text.withValues(alpha: 0.6),
                    title: Text(
                      group.items[i].q,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.font,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          group.items[i].a,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.font,
                            height: 1.55,
                            color: AppColors.text.withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
