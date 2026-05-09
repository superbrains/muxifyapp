import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/profile_menu/services/profile_menu_api_service.dart';
import 'package:muxify/features/profile_menu/widgets/pin_entry_pad.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

enum _PinFlow { menu, set, change, forgot }

class PinSettingsScreen extends StatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> {
  final _api = ProfileMenuApiService();

  _PinFlow _flow = _PinFlow.menu;
  bool _hasPin = false;
  bool _loading = true;

  String? _stagedNewPin;
  String? _stagedCurrentPin;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final has = await _api.hasPin();
    if (!mounted) return;
    setState(() {
      _hasPin = has;
      _loading = false;
    });
  }

  void _resetFlowState() {
    _stagedNewPin = null;
    _stagedCurrentPin = null;
    _error = null;
  }

  Future<void> _onSet(String pin) async {
    // Two-step confirm: first entry sets _stagedNewPin, second entry confirms.
    if (_stagedNewPin == null) {
      setState(() {
        _stagedNewPin = pin;
        _error = null;
      });
      return;
    }
    if (_stagedNewPin != pin) {
      setState(() {
        _stagedNewPin = null;
        _error = 'PINs did not match. Try again.';
      });
      return;
    }
    setState(() => _busy = true);
    final ok = await _api.setPin(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) {
        _flow = _PinFlow.menu;
        _hasPin = true;
        _resetFlowState();
      } else {
        _stagedNewPin = null;
        _error = 'We could not save your PIN. Try again.';
      }
    });
    if (ok) await AppToast.showInfo('Transactional PIN set.');
  }

  Future<void> _onChange(String pin) async {
    if (_stagedCurrentPin == null) {
      setState(() {
        _stagedCurrentPin = pin;
        _error = null;
      });
      return;
    }
    if (_stagedNewPin == null) {
      setState(() {
        _stagedNewPin = pin;
        _error = null;
      });
      return;
    }
    if (_stagedNewPin != pin) {
      setState(() {
        _stagedNewPin = null;
        _error = 'New PINs did not match. Re-enter the new PIN twice.';
      });
      return;
    }
    setState(() => _busy = true);
    final ok = await _api.changePin(
      currentPin: _stagedCurrentPin!,
      newPin: pin,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) {
        _flow = _PinFlow.menu;
        _resetFlowState();
      } else {
        _resetFlowState();
        _error = 'Current PIN was incorrect.';
      }
    });
    if (ok) await AppToast.showInfo('PIN changed.');
  }

  Future<void> _onForgotConfirm() async {
    setState(() => _busy = true);
    final ok = await _api.requestForgotPin();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _flow = _PinFlow.menu;
    });
    if (ok) {
      await AppToast.showInfo(
        'We sent password-reset style instructions to your email.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'Transactional PIN',
      child: _loading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 64.padding),
              child: const Center(child: CircularProgressIndicator()),
            )
          : switch (_flow) {
              _PinFlow.menu => _buildMenu(),
              _PinFlow.set => _buildSet(),
              _PinFlow.change => _buildChange(),
              _PinFlow.forgot => _buildForgot(),
            },
    );
  }

  Widget _buildMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(18.padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.statisticsHeaderGradient.withValues(alpha: 0.6),
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
                  Icon(Icons.lock_outline, color: AppColors.text, size: 22.icon),
                  10.row,
                  Text(
                    _hasPin ? 'PIN is active' : 'No PIN set',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ProfileStatusChip(
                    label: _hasPin ? 'Active' : 'Off',
                    color: _hasPin ? AppColors.green : AppColors.cautionIcon,
                  ),
                ],
              ),
              12.column,
              Text(
                'Your transactional PIN protects every coin spend, gift, and '
                'withdrawal. We never store the digits in plain text.',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.font,
                  color: AppColors.text.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        18.column,
        ProfileSectionCard(
          padding: EdgeInsets.symmetric(horizontal: 12.padding, vertical: 4.padding),
          child: Column(
            children: [
              if (!_hasPin)
                ProfileSectionRow(
                  icon: Icons.add_circle_outline,
                  label: 'Set up transactional PIN',
                  subtitle: '4-digit PIN required for purchases',
                  onTap: () => setState(() {
                    _flow = _PinFlow.set;
                    _resetFlowState();
                  }),
                )
              else ...[
                ProfileSectionRow(
                  icon: Icons.refresh,
                  label: 'Change PIN',
                  subtitle: 'Replace your current PIN',
                  onTap: () => setState(() {
                    _flow = _PinFlow.change;
                    _resetFlowState();
                  }),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                ProfileSectionRow(
                  icon: Icons.help_outline,
                  label: 'Forgot PIN?',
                  subtitle: 'Reset via email verification',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _flow = _PinFlow.forgot;
                      _resetFlowState();
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSet() {
    final stage = _stagedNewPin == null
        ? 'Choose a 4-digit PIN'
        : 'Confirm your PIN';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.padding),
      child: PinEntryPad(
        title: stage,
        subtitle: _stagedNewPin == null
            ? 'You will use this PIN to confirm purchases and gifts.'
            : 'Re-enter the same digits to confirm.',
        error: _error,
        busy: _busy,
        onSubmit: _onSet,
      ),
    );
  }

  Widget _buildChange() {
    final stage = _stagedCurrentPin == null
        ? 'Enter your current PIN'
        : _stagedNewPin == null
            ? 'Choose a new PIN'
            : 'Confirm new PIN';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.padding),
      child: PinEntryPad(
        title: stage,
        subtitle: _stagedCurrentPin == null
            ? 'We need your existing PIN before setting a new one.'
            : _stagedNewPin == null
                ? 'Pick a new 4-digit PIN.'
                : 'Re-enter the new PIN to confirm.',
        error: _error,
        busy: _busy,
        onSubmit: _onChange,
      ),
    );
  }

  Widget _buildForgot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        16.column,
        Icon(Icons.forward_to_inbox_outlined,
            color: AppColors.blue, size: 56.icon),
        16.column,
        Text(
          'Reset your PIN',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading2.copyWith(
            fontSize: 22.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        10.column,
        Text(
          'We will email you a secure link. Open the link from this device '
          'to set a brand new transactional PIN. Coin spending will be paused '
          'until the new PIN is in place.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.font,
            height: 1.55,
            color: AppColors.text.withValues(alpha: 0.7),
          ),
        ),
        24.column,
        FilledButton(
          onPressed: _busy ? null : _onForgotConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.text,
            minimumSize: Size.fromHeight(48.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.radius),
            ),
          ),
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.text),
                  ),
                )
              : Text(
                  'Send reset email',
                  style: AppTextStyles.buttonText,
                ),
        ),
        8.column,
        TextButton(
          onPressed: () => setState(() => _flow = _PinFlow.menu),
          child: Text(
            'Back',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              color: AppColors.text.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }
}
