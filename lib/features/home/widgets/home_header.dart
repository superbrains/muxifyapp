import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/tab_option.dart';
import 'package:muxify/features/home/widgets/tab_option_button.dart';

class HomeHeader extends StatelessWidget {
  final String selectedTab;
  final List<TabOption> toggleOptions;
  final Function(String) onTabChanged;

  const HomeHeader({
    super.key,
    required this.selectedTab,
    required this.toggleOptions,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 47.buttonHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          transform: const GradientRotation(1.5),
          colors: [
            const Color(0xFF6E1E1E).withValues(alpha: 0.4),
            const Color(0xFF6E1E1E).withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0, 0.4, 0.8],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 26.padding, right: 21.padding),
            child: Row(
              children: [
                // Left: Logo
                Image.asset(
                  'assets/pngs/Bitcoin_musixfy.png',
                  height: 40.buttonHeight,
                  width: 40.buttonHeight,
                ),
                4.row,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'm100,250',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.font,
                      ),
                    ),
                    Text(
                      'Wallet Balance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.font,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildHeaderIcons(),
              ],
            ),
          ),
          34.column,
          _buildToggleButtons(),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 24.padding),
      child: Row(
        children: toggleOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return Row(
            children: [
              if (index > 0) 12.row,
              TabOptionButton(
                title: option.title,
                icon: option.icon,
                isSelected: selectedTab == option.title,
                onTap: () {
                  onTabChanged(option.title);
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderIcons() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to stats
          },
          child: Image.asset(
            'assets/pngs/bar-2.png',
            height: 30.icon,
            width: 27.icon,
            color: AppColors.text,
          ),
        ),
        16.row,
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to notifications
          },
          child: Image.asset(
            'assets/pngs/bell.png',
            height: 24.icon,
            width: 24.icon,
            color: AppColors.text,
          ),
        ),
        16.row,
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to profile or show menu
          },
          child: ClipOval(
            child: Image.asset(
              'assets/pngs/profile_placeholder.png',
              height: 38.icon,
              width: 38.icon,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
