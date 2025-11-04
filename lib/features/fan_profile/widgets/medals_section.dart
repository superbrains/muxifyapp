import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/widgets/medal_info_modal.dart';

class MedalsSection extends StatelessWidget {
  const MedalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final medals = [
      {
        'name': 'Iron Fan',
        'description':
            'Lorem ipsum dolor sit amet consectetur. Vulputate magna lobortis sed ultrices cras blandit ipsum est eget. Nibh interdum semper velit erat ultrices sed auctor etiam. Nunc sit neque urna sed mauris nec. Ac suscipit faucibus ac sed porta facilisis cursus nec consectetur. Eu quis sit enim nullam etiam fermentum urna. Blandit vitae sed lacus cursus in sed velit. Velit cras pellentesque consectetur neque etiam non nibh auctor accumsan. Sociis ultrices amet adipiscing vitae egestas ullamcorper ligula eget consectetur. Nibh non augue orci sed.',
        'image': 'assets/pngs/earned_badge.png',
      },
      {
        'name': 'Crown Fan',
        'description':
            'Lorem ipsum dolor sit amet consectetur. Vulputate magna lobortis sed ultrices cras blandit ipsum est eget. Nibh interdum semper velit erat ultrices sed auctor etiam. Nunc sit neque urna sed mauris nec. Ac suscipit faucibus ac sed porta facilisis cursus nec consectetur. Eu quis sit enim nullam etiam fermentum urna. Blandit vitae sed lacus cursus in sed velit. Velit cras pellentesque consectetur neque etiam non nibh auctor accumsan. Sociis ultrices amet adipiscing vitae egestas ullamcorper ligula eget consectetur. Nibh non augue orci sed.',
        'image': 'assets/pngs/earned_badge.png',
      },
      {
        'name': 'Gold Fan',
        'description':
            'Lorem ipsum dolor sit amet consectetur. Vulputate magna lobortis sed ultrices cras blandit ipsum est eget. Nibh interdum semper velit erat ultrices sed auctor etiam. Nunc sit neque urna sed mauris nec. Ac suscipit faucibus ac sed porta facilisis cursus nec consectetur. Eu quis sit enim nullam etiam fermentum urna. Blandit vitae sed lacus cursus in sed velit. Velit cras pellentesque consectetur neque etiam non nibh auctor accumsan. Sociis ultrices amet adipiscing vitae egestas ullamcorper ligula eget consectetur. Nibh non augue orci sed.',
        'image': 'assets/pngs/earned_badge.png',
      },
      {
        'name': 'Platinum Fan',
        'description':
            'Lorem ipsum dolor sit amet consectetur. Vulputate magna lobortis sed ultrices cras blandit ipsum est eget. Nibh interdum semper velit erat ultrices sed auctor etiam. Nunc sit neque urna sed mauris nec. Ac suscipit faucibus ac sed porta facilisis cursus nec consectetur. Eu quis sit enim nullam etiam fermentum urna. Blandit vitae sed lacus cursus in sed velit. Velit cras pellentesque consectetur neque etiam non nibh auctor accumsan. Sociis ultrices amet adipiscing vitae egestas ullamcorper ligula eget consectetur. Nibh non augue orci sed.',
        'image': 'assets/pngs/earned_badge.png',
      },
      {
        'name': 'Diamond Fan',
        'description':
            'Lorem ipsum dolor sit amet consectetur. Vulputate magna lobortis sed ultrices cras blandit ipsum est eget. Nibh interdum semper velit erat ultrices sed auctor etiam. Nunc sit neque urna sed mauris nec. Ac suscipit faucibus ac sed porta facilisis cursus nec consectetur. Eu quis sit enim nullam etiam fermentum urna. Blandit vitae sed lacus cursus in sed velit. Velit cras pellentesque consectetur neque etiam non nibh auctor accumsan. Sociis ultrices amet adipiscing vitae egestas ullamcorper ligula eget consectetur. Nibh non augue orci sed.',
        'image': 'assets/pngs/earned_badge.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medals',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        10.column,
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.radius),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.text.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: 0.2),
              ],
            ),
          ),
          height: 95.maxHeight,
          child: ListView.separated(
            separatorBuilder: (context, index) => 15.row,
            padding: EdgeInsets.symmetric(horizontal: 17.padding),
            scrollDirection: Axis.horizontal,
            itemCount: medals.length,
            itemBuilder: (context, index) {
              final medal = medals[index];
              return GestureDetector(
                onTap: () {
                  MedalInfoModal.show(
                    context,
                    medalName: medal['name']!,
                    medalDescription: medal['description']!,
                    medalImagePath: medal['image']!,
                  );
                },
                child: SizedBox(
                  width: 57.maxWidth,
                  height: 61.maxHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.radius),
                    child: Image.asset(medal['image']!),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
