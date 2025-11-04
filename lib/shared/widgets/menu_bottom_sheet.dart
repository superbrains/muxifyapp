import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/centered_header_widget.dart';
import 'package:muxify/shared/widgets/menu_item_model.dart';

class MenuBottomSheet extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final List<MenuItemModel> menuItems;

  const MenuBottomSheet({
    super.key,
    this.title = 'Menu',
    required this.onClose,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.radius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              left: 20.padding,
              right: 20.padding,
              top: 16.padding,
              bottom: 24.padding,
            ),
            child: CenteredHeaderWidget(title: title, onBackTap: onClose),
          ),
          // Menu Items
          _buildMenuItems(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24.padding),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: menuItems.map((item) {
        return _buildMenuItem(item);
      }).toList(),
    );
  }

  Widget _buildMenuItem(MenuItemModel item) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onClose();
        item.onTap?.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.padding,
          vertical: 16.padding,
        ),
        child: Row(
          children: [
            if (item.iconPath != null)
              Image.asset(item.iconPath!, width: 24.icon, height: 24.icon)
            else if (item.icon != null)
              Icon(item.icon, color: AppColors.text, size: 24.icon),
            16.row,
            Expanded(
              child: Text(
                item.text,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.text,
                  fontSize: 16.font,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
