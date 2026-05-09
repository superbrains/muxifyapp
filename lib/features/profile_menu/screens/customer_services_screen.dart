import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/profile_menu/services/profile_menu_api_service.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

class CustomerServicesScreen extends StatefulWidget {
  const CustomerServicesScreen({super.key});

  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _api = ProfileMenuApiService();

  static const List<_Category> _categories = [
    _Category('Account', 'account'),
    _Category('Payments & coins', 'payments'),
    _Category('Music & playback', 'playback'),
    _Category('Bug report', 'bug'),
    _Category('Other', 'other'),
  ];

  _Category _category = _categories.first;
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      await AppToast.showError('Add a subject and a short description.');
      return;
    }
    setState(() => _submitting = true);
    final ok = await _api.submitSupportTicket(
      subject: subject,
      category: _category.code,
      message: message,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      await AppToast.showInfo(
        'Thanks — our team will reply by email within 24 hours.',
      );
      _subjectController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'Customer Services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSectionCard(
            child: Row(
              children: [
                Container(
                  width: 44.icon,
                  height: 44.icon,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.headset_mic_outlined,
                      color: AppColors.green, size: 22.icon),
                ),
                12.row,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We typically reply within 24 hours.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14.font,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.column,
                      Text(
                        'Mon–Sat · 9am–8pm WAT',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12.font,
                          color: AppColors.text.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          18.column,
          Text(
            'Submit a ticket',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
          10.column,
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Category',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.font,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                8.column,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in _categories)
                      _CategoryChip(
                        label: c.label,
                        selected: c == _category,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
                16.column,
                Text(
                  'Subject',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.font,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                6.column,
                CustomInputField(
                  controller: _subjectController,
                  hintText: 'A short summary',
                ),
                14.column,
                Text(
                  'Message',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.font,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                6.column,
                CustomInputField(
                  controller: _messageController,
                  hintText: 'Tell us what is going on…',
                  maxLines: 6,
                ),
                16.column,
                CustomButton.signUp(
                  text: 'Send to support',
                  isLoading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
          20.column,
          Text(
            'Other ways to reach us',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
          10.column,
          ProfileSectionCard(
            padding: EdgeInsets.symmetric(vertical: 4.padding, horizontal: 12.padding),
            child: Column(
              children: [
                ProfileSectionRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  subtitle: 'support@muxify.app',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                      const ClipboardData(text: 'support@muxify.app'),
                    );
                    AppToast.showInfo('Email copied to clipboard.');
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                ProfileSectionRow(
                  icon: Icons.phone_in_talk_outlined,
                  label: 'Phone',
                  subtitle: '+234 906 948 9382',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                      const ClipboardData(text: '+2349069489382'),
                    );
                    AppToast.showInfo('Phone copied to clipboard.');
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                ProfileSectionRow(
                  icon: Icons.location_on_outlined,
                  label: 'Office',
                  subtitle: '36 Aladdin St, Lekki, Lagos',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category(this.label, this.code);
  final String label;
  final String code;
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.radius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.padding, vertical: 8.padding),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.buttonColor.withValues(alpha: 0.18)
              : AppColors.glassyAccent.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20.radius),
          border: Border.all(
            color: selected
                ? AppColors.buttonColor
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12.font,
            fontWeight: FontWeight.w500,
            color:
                selected ? AppColors.text : AppColors.text.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
