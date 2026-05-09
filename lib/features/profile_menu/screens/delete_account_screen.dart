import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/features/profile_menu/services/profile_menu_api_service.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  final _api = ProfileMenuApiService();

  bool _agreed = false;
  bool _submitting = false;
  static const String _confirmationWord = 'DELETE';

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() => _submitting = true);
    final ok = await _api.deactivateAccount();
    if (!mounted) return;
    if (!ok) {
      setState(() => _submitting = false);
      return;
    }
    await LocalStorageService.clearUserCredentials();
    if (!mounted) return;
    context.read<AuthProvider>().clearCurrentUser();
    if (!mounted) return;
    await AppToast.showInfo('Your account has been deactivated.');
    if (!mounted) return;
    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _agreed &&
        _confirmController.text.trim().toUpperCase() == _confirmationWord &&
        !_submitting;

    return ProfileSectionScaffold(
      title: 'Delete Account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(18.padding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE57373).withValues(alpha: 0.25),
                  AppColors.glassyDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20.radius),
              border: Border.all(
                color: const Color(0xFFE57373).withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: const Color(0xFFE57373), size: 22.icon),
                    10.row,
                    Expanded(
                      child: Text(
                        'This action is permanent',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16.font,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                10.column,
                Text(
                  'Deactivating your Muxify account is immediate. You will be '
                  'signed out of every device and the items below will be '
                  'forfeited.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.font,
                    height: 1.5,
                    color: AppColors.text.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          16.column,
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What will be removed',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                12.column,
                _LossRow(
                    icon: Icons.account_balance_wallet_outlined,
                    text: 'Your remaining Muxify Coin balance'),
                _LossRow(
                    icon: Icons.emoji_events_outlined,
                    text: 'Earned medals, badges, and leaderboard standing'),
                _LossRow(
                    icon: Icons.favorite_outline,
                    text: 'Followed artists, saved playlists, and unlocks'),
                _LossRow(
                    icon: Icons.history_outlined,
                    text: 'Listening history and watch progress'),
                _LossRow(
                    icon: Icons.message_outlined,
                    text: 'Messages and support tickets'),
              ],
            ),
          ),
          16.column,
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type $_confirmationWord to confirm',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.font,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                10.column,
                CustomInputField(
                  controller: _confirmController,
                  hintText: _confirmationWord,
                  onChanged: (_) => setState(() {}),
                ),
                14.column,
                InkWell(
                  onTap: () => setState(() => _agreed = !_agreed),
                  borderRadius: BorderRadius.circular(12.radius),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          activeColor: const Color(0xFFE57373),
                          checkColor: AppColors.text,
                          side: BorderSide(
                            color: AppColors.text.withValues(alpha: 0.4),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.padding),
                            child: Text(
                              'I understand my coins, badges, and history will '
                              'be erased and cannot be restored.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12.font,
                                color: AppColors.text.withValues(alpha: 0.78),
                                height: 1.5,
                              ),
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
          18.column,
          FilledButton(
            onPressed: canSubmit ? _delete : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              foregroundColor: AppColors.text,
              disabledBackgroundColor:
                  const Color(0xFFE57373).withValues(alpha: 0.35),
              disabledForegroundColor: AppColors.text.withValues(alpha: 0.7),
              minimumSize: Size.fromHeight(48.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.radius),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.text),
                    ),
                  )
                : Text(
                    'Permanently delete account',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 14.font),
                  ),
          ),
          8.column,
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Keep my account',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.font,
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LossRow extends StatelessWidget {
  const _LossRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: const Color(0xFFE57373).withValues(alpha: 0.85),
              size: 18.icon),
          10.row,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.font,
                color: AppColors.text.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
