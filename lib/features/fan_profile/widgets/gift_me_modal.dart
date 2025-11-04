import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/music_player/screens/get_coins_screen.dart';
import 'package:muxify/shared/widgets/buy_coin_button.dart';
import 'package:muxify/features/music_player/widgets/coin_package_card.dart';
import 'package:muxify/shared/widgets/large_coin_package_card.dart';
import 'package:muxify/shared/widgets/buy_coin_header.dart';

class GiftMeModal extends StatefulWidget {
  const GiftMeModal({super.key});

  @override
  State<GiftMeModal> createState() => _GiftMeModalState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GiftMeModal(),
    );
  }
}

class _GiftMeModalState extends State<GiftMeModal> {
  int _selectedCoinPackage = 0; // Index of selected package

  // Mock coin packages data
  final List<CoinPackage> _coinPackages = [
    CoinPackage(amount: '100250', price: '2,000'),
    CoinPackage(amount: '200500', price: '4,000'),
    CoinPackage(amount: '500750', price: '10,000'),
    CoinPackage(amount: '1000000', price: '20,000'),
    CoinPackage(amount: '5000000', price: '100,000'), // Large package
  ];
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.padding),
        padding: EdgeInsets.symmetric(
          horizontal: 14.padding,
          vertical: 29.padding,
        ),
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.circular(20.radius),
          // border: Border.all(
          //   color: AppColors.text.withValues(alpha: 0.1),
          //   width: 1,
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Gift Me',
              style: AppTextStyles.displayText.copyWith(
                color: AppColors.text,
                fontSize: 30.font,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),

            13.column,
            const BuyCoinHeader(title: 'Gift Me'),

            // // Medal Image
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12.radius),
            //   child: Image.asset(
            //     medalImagePath,
            //     width: 120.maxWidth,
            //     height: 120.maxHeight,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            27.column,
            _buildCoinPackagesGrid(),

            // // Medal Name
            // Text(
            //   textAlign: TextAlign.center,
            //   medalName,
            //   style: AppTextStyles.bodyLarge.copyWith(
            //     color: AppColors.text,
            //     fontSize: 20.font,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            53.column,

            // Buy Coin Button
            const BuyCoinButton(),

            // // Description
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 41.padding),
            //   child: Text(
            //     medalDescription,
            //     style: AppTextStyles.bodyMedium.copyWith(
            //       color: AppColors.text.withValues(alpha: 0.6),
            //       fontSize: 14.font,
            //       fontWeight: FontWeight.w400,
            //       height: 1.5,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            // 30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackagesGrid() {
    return Column(
      children: [
        // 2x3 Grid for first 6 packages
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final package = _coinPackages[index];
            return CoinPackageCard(
              amount: package.amount,
              price: package.price,
              isSelected: _selectedCoinPackage == index,
              onTap: () {
                setState(() {
                  _selectedCoinPackage = index;
                });
              },
            );
          },
        ),

        28.column,

        // Large package at bottom
        LargeCoinPackageCard(
          amount: _coinPackages[4].amount,
          price: _coinPackages[4].price,
          isSelected: _selectedCoinPackage == 4,
          onTap: () {
            setState(() {
              _selectedCoinPackage = 4;
            });
          },
        ),
      ],
    );
  }

  // static void show(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) => GiftMeModal(),
  //   );
  // }
}
