import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/music_player/widgets/get_coins_header.dart';
import 'package:muxify/features/music_player/widgets/coin_balance_section.dart';
import 'package:muxify/features/music_player/widgets/buy_coin_header.dart';
import 'package:muxify/features/music_player/widgets/coin_package_card.dart';
import 'package:muxify/features/music_player/widgets/large_coin_package_card.dart';
import 'package:muxify/features/music_player/widgets/buy_coin_button.dart';

class GetCoinsScreen extends StatefulWidget {
  const GetCoinsScreen({super.key});

  @override
  State<GetCoinsScreen> createState() => _GetCoinsScreenState();
}

class _GetCoinsScreenState extends State<GetCoinsScreen> {
  int _selectedCoinPackage = 0; // Index of selected package
  final String _currentBalance = '0,000'; // Current coin balance

  // Mock coin packages data
  final List<CoinPackage> _coinPackages = [
    CoinPackage(amount: '100250', price: '2,000'),
    CoinPackage(amount: '200500', price: '4,000'),
    CoinPackage(amount: '500750', price: '10,000'),
    CoinPackage(amount: '1000000', price: '20,000'),
    CoinPackage(amount: '2500000', price: '50,000'),
    CoinPackage(amount: '5000000', price: '100,000'),
    CoinPackage(amount: '5000000', price: '100,000'), // Large package
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GetCoinsHeader(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.padding),
          child: Column(
            children: [
              30.column,

              // Coin Balance Section
              CoinBalanceSection(currentBalance: _currentBalance),

              42.column,

              // Buy Coin Section Header
              const BuyCoinHeader(),

              21.column,

              // Coin Packages Grid
              _buildCoinPackagesGrid(),

              Spacer(),
              // Buy Coin Button
              const BuyCoinButton(),

              // Bottom padding
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 20.padding,
              ),
            ],
          ),
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
          itemCount: 6,
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
          amount: _coinPackages[6].amount,
          price: _coinPackages[6].price,
          isSelected: _selectedCoinPackage == 6,
          onTap: () {
            setState(() {
              _selectedCoinPackage = 6;
            });
          },
        ),
      ],
    );
  }

  // void _handleBuyCoins() {
  //   final selectedPackage = _coinPackages[_selectedCoinPackage];

  //   // For demo purposes, add coins to balance
  //   setState(() {
  //     final currentBalanceInt = int.parse(_currentBalance);
  //     final packageAmountInt = int.parse(selectedPackage.amount);
  //     _currentBalance = (currentBalanceInt + packageAmountInt).toString();
  //   });

  //   // Show success message
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         'Successfully purchased m${selectedPackage.amount} coins!',
  //         style: AppTextStyles.bodySmall.copyWith(
  //           color: Colors.white,
  //           fontSize: 12.font,
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       backgroundColor: AppColors.buttonColor,
  //     ),
  //   );
  // }
}

class CoinPackage {
  final String amount;
  final String price;

  CoinPackage({required this.amount, required this.price});
}
