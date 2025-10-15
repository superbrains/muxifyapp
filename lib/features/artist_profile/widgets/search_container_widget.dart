import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class SearchContainerWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const SearchContainerWidget({
    super.key,
    required this.controller,
    this.hintText = 'Search here',
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 50.maxHeight,
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(48.radius),
        border: Border.all(
          color: AppColors.text.withValues(alpha: 0.3),
          width: 1.5.border,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 16.font,
          color: AppColors.text,
        ),
        cursorColor: AppColors.text.withValues(alpha: 0.5),
        decoration: InputDecoration(
          fillColor: AppColors.text.withValues(alpha: 0.05),
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.font,
            color: AppColors.text.withValues(alpha: 0.56),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.padding,
            vertical: 15.padding,
          ),
        ),
      ),
    );
  }
}
