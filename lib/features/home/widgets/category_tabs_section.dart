import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/widgets/category_tab_button.dart';

class CategoryTabsSection extends StatelessWidget {
  final List<CategoryTab> categories;
  final String selectedCategoryId;
  final Function(String) onCategoryChanged;

  const CategoryTabsSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
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
