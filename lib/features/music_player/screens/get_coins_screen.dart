import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/music_player/widgets/get_coins_header.dart';
import 'package:muxify/features/music_player/widgets/coin_balance_section.dart';
import 'package:muxify/features/music_player/widgets/coin_package_card.dart';
import 'package:muxify/features/music_player/widgets/payment_method_bottom_sheet.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:muxify/shared/widgets/buy_coin_header.dart';
import 'package:muxify/shared/widgets/buy_coin_button.dart';
import 'package:muxify/shared/widgets/large_coin_package_card.dart';
import 'package:shimmer/shimmer.dart';

class GetCoinsScreen extends StatefulWidget {
  const GetCoinsScreen({super.key});

  @override
  State<GetCoinsScreen> createState() => _GetCoinsScreenState();
}

class _GetCoinsScreenState extends State<GetCoinsScreen> {
  final _api = WalletApiService();

  List<CoinPackageDto>? _packages;
  String? _loadError;
  CoinPackageDto? _selected;
  WalletSummary _summary = WalletSummary.empty();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loadError = null;
      _packages = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchCoinPackages(),
        _api.fetchWalletSummary(),
      ]);
      if (!mounted) return;
      final pkgs = (results[0] as List<CoinPackageDto>)
        ..sort((a, b) => a.priceInSmallestUnit.compareTo(b.priceInSmallestUnit));
      setState(() {
        _packages = pkgs;
        _summary = results[1] as WalletSummary;
        // Default selection: featured if present, else first.
        _selected = pkgs.firstWhere(
          (p) => p.isFeatured,
          orElse: () => pkgs.isNotEmpty ? pkgs.first : _selected!,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Could not load coin packages. Try again.');
    }
  }

  void _openPaymentSheet() {
    final selected = _selected;
    if (selected == null) {
      AppToast.showError('Pick a coin package first.');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PaymentMethodBottomSheet(
        onClose: () => Navigator.of(context).pop(),
        packageId: selected.id,
        packageLabel: 'm${_formatNumber(selected.totalCoins)} • ${selected.name}',
        priceDisplay: _formatNumber(selected.priceDisplay.toInt()),
        // CustomerContact is only needed for mobile-money channels (OTP); the
        // payment sheet prompts the user for it when a channel requires it.
        // Bank-transfer / card channels don't use it, so an empty value is
        // fine here.
        customerContact: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GetCoinsHeader(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.buttonColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20.padding,
                  20.padding,
                  20.padding,
                  120.padding, // room for the sticky button
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    CoinBalanceSection(
                      currentBalance: _formatNumber(_summary.balance),
                    ),
                    32.column,
                    const BuyCoinHeader(),
                    20.column,
                    _buildBody(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.padding, 0, 20.padding, 16.padding),
          child: BuyCoinButton(
            enabled: _selected != null && _loadError == null,
            onPressed: _openPaymentSheet,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadError != null) {
      return _buildErrorState();
    }
    final packages = _packages;
    if (packages == null) return _buildLoadingState();
    if (packages.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.padding),
        child: Text(
          'No coin packages are available right now.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text.withValues(alpha: 0.6),
            fontSize: 13.font,
          ),
        ),
      );
    }
    // First N-1 in the 2-col grid, the last (highest-priced) in the big card.
    final gridItems = packages.length > 1
        ? packages.sublist(0, packages.length - 1)
        : packages;
    final feature = packages.length > 1 ? packages.last : null;
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.4,
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            final pkg = gridItems[index];
            return CoinPackageCard(
              amount: _formatNumber(pkg.totalCoins),
              price: _formatNumber(pkg.priceDisplay.toInt()),
              isSelected: _selected?.id == pkg.id,
              onTap: () => setState(() => _selected = pkg),
            );
          },
        ),
        if (feature != null) ...[
          22.column,
          LargeCoinPackageCard(
            amount: _formatNumber(feature.totalCoins),
            price: _formatNumber(feature.priceDisplay.toInt()),
            isSelected: _selected?.id == feature.id,
            onTap: () => setState(() => _selected = feature),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.glassyDark,
      highlightColor: AppColors.glassyLight,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: AppColors.glassyDark,
                borderRadius: BorderRadius.circular(10.radius),
              ),
            ),
          ),
          22.column,
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.glassyDark,
              borderRadius: BorderRadius.circular(12.radius),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.padding),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined,
              color: AppColors.text.withValues(alpha: 0.5), size: 40.icon),
          12.column,
          Text(
            _loadError ?? 'Could not load packages.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
              fontSize: 13.font,
            ),
          ),
          14.column,
          TextButton(
            onPressed: _load,
            child: Text('Retry',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.buttonColor,
                  fontSize: 14.font,
                )),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }
}
