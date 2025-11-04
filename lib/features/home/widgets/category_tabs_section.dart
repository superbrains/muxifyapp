import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/widgets/category_tab_button.dart';

class CategoryTabsSection extends StatelessWidget {
  final List<CategoryTab> categories;
  final String selectedCategoryId;
  final Function(String) onCategoryChanged;
  final double? width;
  final double? height;
  final double? paddingHorizontal;
  final double? paddingVertical;

  const CategoryTabsSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    this.width,
    this.height,
    this.paddingHorizontal,
    this.paddingVertical,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // padding: EdgeInsets.symmetric(horizontal: 24.padding),
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return Row(
            children: [
              if (index > 0) 12.row,
              CategoryTabButton(
                width: width,
                height: height,
                paddingHorizontal: paddingHorizontal,
                paddingVertical: paddingVertical,
                title: category.title,
                icon: category.icon,
                isSelected: selectedCategoryId == category.id,
                onTap: () {
                  onCategoryChanged(category.id);
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
