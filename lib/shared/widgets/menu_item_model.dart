import 'package:flutter/material.dart';

class MenuItemModel {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback? onTap;

  const MenuItemModel({
    required this.text,
    this.iconPath,
    this.icon,
    this.onTap,
  }) : assert(
         iconPath == null || icon == null,
         'Cannot provide both iconPath and icon. Use only one.',
       );
}
