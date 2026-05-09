import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// Shared scaffold for every fan profile-menu sub-page.
///
/// Provides the consistent visual shell (back button, centred title, dark
/// background, padded body) so the nine settings screens all feel like a
/// single product surface.
class ProfileSectionScaffold extends StatelessWidget {
  const ProfileSectionScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.scrollable = true,
    this.padding,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding ?? EdgeInsets.fromLTRB(20.padding, 8.padding, 20.padding, 24.padding),
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20.icon),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 18.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: scrollable ? SingleChildScrollView(child: body) : body,
      ),
    );
  }
}

/// Section card used inside [ProfileSectionScaffold] children.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.padding),
      decoration: BoxDecoration(
        color: AppColors.glassyDark,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: child,
    );
  }
}

/// Tappable row used inside [ProfileSectionCard] for menu-style lists.
class ProfileSectionRow extends StatelessWidget {
  const ProfileSectionRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE57373) : AppColors.text;
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      borderRadius: BorderRadius.circular(12.radius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.padding, horizontal: 4.padding),
        child: Row(
          children: [
            Container(
              width: 36.icon,
              height: 36.icon,
              decoration: BoxDecoration(
                color: AppColors.glassyAccent.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? color, size: 18.icon),
            ),
            12.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15.font,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    2.column,
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12.font,
                        color: AppColors.text.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.text.withValues(alpha: 0.4),
                size: 20.icon,
              ),
          ],
        ),
      ),
    );
  }
}

/// Status chip used to show verified / pending / unset states.
class ProfileStatusChip extends StatelessWidget {
  const ProfileStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.padding, vertical: 4.padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.radius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 11.font,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
