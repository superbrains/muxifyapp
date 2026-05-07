import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/models/auth/auth_login_result.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/app_toast.dart';

/// Fan home menu from the right (matches mobile dashboard nav sheet).
class HomeMenuDrawer extends StatefulWidget {
  const HomeMenuDrawer({super.key});

  @override
  State<HomeMenuDrawer> createState() => _HomeMenuDrawerState();
}

class _HomeMenuDrawerState extends State<HomeMenuDrawer> {
  AuthUserDto? _user;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final raw = await LocalStorageService.getAuthUserJson();
    final biometric = await LocalStorageService.isBiometricEnabled();
    if (!mounted) return;
    setState(() {
      _user = AuthUserDto.tryParseStored(raw);
      _biometricEnabled = biometric;
    });
  }

  Future<void> _signOut() async {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    await LocalStorageService.clearUserCredentials();
    if (!mounted) return;
    context.go(AppRouter.login);
  }

  void _closeThen(VoidCallback action) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final drawerWidth = w * 0.88;
    final user = _user;

    return Drawer(
      width: drawerWidth.clamp(280.0, 360.0),
      backgroundColor: const Color(0xFF252525),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.padding, vertical: 16.padding),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: _Avatar(avatar: user?.avatar),
                ),
                12.row,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name
                                  : 'Muxify fan',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.font,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user?.isVerified == true) ...[
                            4.row,
                            Icon(
                              Icons.verified,
                              size: 18.icon,
                              color: AppColors.badgeRating,
                            ),
                          ],
                        ],
                      ),
                      10.column,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _closeThen(() => context.push(AppRouter.fanProfile));
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.greyButtonColor,
                            foregroundColor: AppColors.text,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.padding,
                              vertical: 8.padding,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'My Profile',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12.font,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            28.column,
            _DrawerRow(
              icon: Icons.shield_outlined,
              label: 'Account Verification',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('Account verification coming soon.');
              },
            ),
            _DrawerRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet & Payment',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('Wallet & payment coming soon.');
              },
            ),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.only(left: 8.padding, bottom: 8.padding),
                initiallyExpanded: true,
                leading: Icon(Icons.lock_outline, color: AppColors.text, size: 22.icon),
                title: Text(
                  'Security',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.font,
                  ),
                ),
                iconColor: AppColors.text,
                collapsedIconColor: AppColors.text,
                children: [
                  _SubRow(
                    label: 'PIN',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AppToast.showInfo('PIN settings coming soon.');
                    },
                  ),
                  _SubRow(
                    label: 'Password',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _closeThen(() => context.push(AppRouter.resetPassword));
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4.padding, top: 4.padding, bottom: 4.padding),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Biometric Login',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14.font,
                              color: AppColors.text.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: _biometricEnabled,
                          onChanged: (v) async {
                            HapticFeedback.selectionClick();
                            await LocalStorageService.setBiometricEnabled(v);
                            if (!mounted) return;
                            setState(() => _biometricEnabled = v);
                          },
                          activeTrackColor: AppColors.green.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _DrawerRow(
              icon: Icons.equalizer,
              label: 'About Muxify',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('About Muxify coming soon.');
              },
            ),
            _DrawerRow(
              icon: Icons.description_outlined,
              label: 'Privacy Policies',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('Privacy policies coming soon.');
              },
            ),
            _DrawerRow(
              icon: Icons.gavel_outlined,
              label: 'Legals',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('Legals coming soon.');
              },
            ),
            _DrawerRow(
              icon: Icons.headset_mic_outlined,
              label: 'Customer Services',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('Customer services coming soon.');
              },
            ),
            _DrawerRow(
              icon: Icons.menu_book_outlined,
              label: 'FAQ',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('FAQ coming soon.');
              },
            ),
            12.column,
            _DrawerRow(
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: _signOut,
            ),
            _DrawerRow(
              icon: Icons.person_off_outlined,
              label: 'Delete Account',
              danger: true,
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.showInfo('Delete account: contact support.');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatar});

  final String? avatar;

  @override
  Widget build(BuildContext context) {
    final url = avatar?.trim();
    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/pngs/profile_placeholder.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      'assets/pngs/profile_placeholder.png',
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
  }
}

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE57373) : AppColors.text;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4.padding),
      leading: Icon(icon, color: color, size: 22.icon),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 15.font,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 12.padding, right: 0),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14.font,
          color: AppColors.text.withValues(alpha: 0.9),
        ),
      ),
      onTap: onTap,
    );
  }
}
