import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/auth/providers/auth_provider.dart';
import 'package:muxify/features/profile_menu/services/profile_menu_api_service.dart';
import 'package:muxify/shared/widgets/custom_button.dart';
import 'package:muxify/shared/widgets/custom_input_field.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';
import 'package:provider/provider.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _api = ProfileMenuApiService();

  bool _phoneFlowOpen = false;
  bool _waitingForCode = false;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startPhoneVerification() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      await AppToast.showError('Enter your phone number first.');
      return;
    }
    setState(() => _submitting = true);
    final ok = await _api.startPhoneVerification(phone);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _waitingForCode = ok;
    });
    if (ok) {
      await AppToast.showInfo('We sent a 6-digit code to $phone.');
    }
  }

  Future<void> _confirmPhoneCode() async {
    final code = _otpController.text.trim();
    if (code.length < 4) {
      await AppToast.showError('Enter the code we sent you.');
      return;
    }
    final auth = context.read<AuthProvider>();
    setState(() => _submitting = true);
    final ok = await _api.confirmPhoneVerification(code);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      await AppToast.showInfo('Phone verified.');
      await auth.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _waitingForCode = false;
        _phoneFlowOpen = false;
        _phoneController.clear();
        _otpController.clear();
      });
    }
  }

  void _resendEmailCode() {
    HapticFeedback.lightImpact();
    AppToast.showInfo(
      'Open your inbox and enter the code on the verification screen.',
    );
    context.push(
      '${AppRouter.verifyEmail}?email='
      '${Uri.encodeQueryComponent(context.read<AuthProvider>().currentUser?.email ?? '')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final emailVerified = user?.isVerified ?? false;
    final phoneNumber = ''; // PhoneNumber not yet exposed on AuthUserDto.

    return ProfileSectionScaffold(
      title: 'Account Verification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OverviewCard(
            verifiedCount: emailVerified ? 1 : 0,
            total: 2,
          ),
          18.column,
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.alternate_email,
                        color: AppColors.blue, size: 22.icon),
                    10.row,
                    Text(
                      'Email address',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 16.font,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    ProfileStatusChip(
                      label: emailVerified ? 'Verified' : 'Pending',
                      color: emailVerified ? AppColors.green : AppColors.badgeRating,
                    ),
                  ],
                ),
                12.column,
                Text(
                  user?.email ?? '—',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    color: AppColors.text.withValues(alpha: 0.85),
                  ),
                ),
                if (!emailVerified) ...[
                  16.column,
                  Text(
                    'Verifying your email lets us recover your account if '
                    'you ever lose your password.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.55),
                      height: 1.5,
                    ),
                  ),
                  14.column,
                  CustomButton.signUp(
                    text: 'Verify email',
                    onPressed: _resendEmailCode,
                  ),
                ],
              ],
            ),
          ),
          14.column,
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        color: AppColors.green, size: 22.icon),
                    10.row,
                    Text(
                      'Phone number',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 16.font,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    ProfileStatusChip(
                      label: phoneNumber.isNotEmpty ? 'Linked' : 'Not added',
                      color: phoneNumber.isNotEmpty
                          ? AppColors.green
                          : AppColors.cautionIcon,
                    ),
                  ],
                ),
                12.column,
                if (!_phoneFlowOpen) ...[
                  Text(
                    phoneNumber.isNotEmpty
                        ? phoneNumber
                        : 'Add your phone number to enable SMS sign-in and '
                            'safer payouts.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.font,
                      color: AppColors.text.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  14.column,
                  CustomButton.signUp(
                    text: phoneNumber.isNotEmpty ? 'Re-verify phone' : 'Add phone',
                    onPressed: () => setState(() => _phoneFlowOpen = true),
                  ),
                ] else if (!_waitingForCode) ...[
                  Text(
                    'Enter your phone in international format, e.g. +234 906 948 9382.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.55),
                    ),
                  ),
                  10.column,
                  CustomInputField(
                    controller: _phoneController,
                    hintText: '+234 …',
                    keyboardType: TextInputType.phone,
                  ),
                  12.column,
                  CustomButton.signUp(
                    text: 'Send code',
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _startPhoneVerification,
                  ),
                  8.column,
                  CustomButton.text(
                    text: 'Cancel',
                    onPressed: () => setState(() => _phoneFlowOpen = false),
                  ),
                ] else ...[
                  Text(
                    'We sent a 6-digit code to ${_phoneController.text.trim()}.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.65),
                    ),
                  ),
                  10.column,
                  CustomInputField(
                    controller: _otpController,
                    hintText: '6-digit code',
                    keyboardType: TextInputType.number,
                  ),
                  12.column,
                  CustomButton.signUp(
                    text: 'Confirm',
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _confirmPhoneCode,
                  ),
                  8.column,
                  CustomButton.text(
                    text: 'Use a different number',
                    onPressed: () => setState(() {
                      _waitingForCode = false;
                      _otpController.clear();
                    }),
                  ),
                ],
              ],
            ),
          ),
          18.column,
          Text(
            'Need help? Contact Customer Services from the menu.',
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.verifiedCount, required this.total});

  final int verifiedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = verifiedCount / total;
    return Container(
      padding: EdgeInsets.all(18.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerGradient.withValues(alpha: 0.7),
            AppColors.glassyDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  color: AppColors.text, size: 22.icon),
              10.row,
              Text(
                'Verification progress',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$verifiedCount / $total',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.font,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          14.column,
          ClipRRect(
            borderRadius: BorderRadius.circular(8.radius),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
          10.column,
          Text(
            verifiedCount == total
                ? 'You are fully verified.'
                : 'Verify the remaining channels to unlock all features.',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.font,
              color: AppColors.text.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
