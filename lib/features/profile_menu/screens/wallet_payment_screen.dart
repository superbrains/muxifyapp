import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/profile_menu/services/profile_menu_api_service.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:muxify/shared/widgets/profile_section_scaffold.dart';

class WalletPaymentScreen extends StatefulWidget {
  const WalletPaymentScreen({super.key});

  @override
  State<WalletPaymentScreen> createState() => _WalletPaymentScreenState();
}

class _WalletPaymentScreenState extends State<WalletPaymentScreen> {
  final _api = WalletApiService();

  WalletSummary? _summary;
  List<WalletTransaction>? _transactions;
  CoinRate _rate = CoinRate.fallback();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchWalletSummary(),
        _api.fetchWalletTransactions(),
        _api.fetchCoinRate(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as WalletSummary;
        _transactions = results[1] as List<WalletTransaction>;
        _rate = results[2] as CoinRate;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'We could not load your wallet. Pull to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: 'Wallet & Payment',
      scrollable: false,
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.buttonColor,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.padding, 8.padding, 20.padding, 24.padding),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _BalanceCard(
              loading: _loading,
              summary: _summary,
              rate: _rate,
              onTopUp: () {
                HapticFeedback.lightImpact();
                context.push(AppRouter.getCoins);
              },
            ),
            18.column,
            Row(
              children: [
                Text(
                  'Recent activity',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withValues(alpha: 0.85),
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                if (!_loading && (_transactions?.isNotEmpty ?? false))
                  Text(
                    '${_transactions!.length} entries',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
            10.column,
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32.padding),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              ProfileSectionCard(
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.cautionIcon, size: 32.icon),
                    8.column,
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.font,
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else if ((_transactions?.isEmpty ?? true))
              ProfileSectionCard(
                padding: EdgeInsets.symmetric(vertical: 28.padding, horizontal: 16.padding),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: AppColors.text.withValues(alpha: 0.5), size: 36.icon),
                    10.column,
                    Text(
                      'No transactions yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.font,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.column,
                    Text(
                      'Top up coins or unlock content to see your activity here.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12.font,
                        color: AppColors.text.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              )
            else
              ProfileSectionCard(
                padding: EdgeInsets.symmetric(vertical: 4.padding, horizontal: 4.padding),
                child: Column(
                  children: [
                    for (var i = 0; i < _transactions!.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 56.padding,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      _TransactionRow(tx: _transactions![i]),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.loading,
    required this.summary,
    required this.rate,
    required this.onTopUp,
  });

  final bool loading;
  final WalletSummary? summary;
  final CoinRate rate;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.buttonColor.withValues(alpha: 0.85),
            AppColors.headerGradient,
          ],
        ),
        borderRadius: BorderRadius.circular(22.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/pngs/Bitcoin_musixfy.png',
                height: 28.icon,
                width: 28.icon,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.monetization_on, color: AppColors.text, size: 28.icon),
              ),
              8.row,
              Text(
                'Muxify Coins',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.font,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.padding, vertical: 4.padding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20.radius),
                ),
                child: Text(
                  loading ? '—' : 'Tier ${summary?.tier ?? 'Bronze'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          18.column,
          Text(
            'Balance',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.font,
              color: AppColors.text.withValues(alpha: 0.7),
            ),
          ),
          4.column,
          Text(
            loading ? '••••' : 'm${_format(summary?.balance ?? 0)}',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 38.font,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          4.column,
          Text(
            loading
                ? ' '
                : '≈ ₦${_format((summary?.balance ?? 0) ~/ rate.coinsPerNairaMajor)} value',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.font,
              color: AppColors.text.withValues(alpha: 0.7),
            ),
          ),
          18.column,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onTopUp,
                  icon: Icon(Icons.add, size: 18, color: AppColors.background),
                  label: Text(
                    'Top up',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: 14.font,
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.text,
                    foregroundColor: AppColors.background,
                    minimumSize: Size.fromHeight(46.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.radius),
                    ),
                  ),
                ),
              ),
              10.row,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: Text(
                    'Send',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 14.font),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                    minimumSize: Size.fromHeight(46.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.radius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _format(int n) {
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

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});

  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.direction == WalletTxDirection.credit;
    final color = isCredit ? AppColors.green : const Color(0xFFE57373);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.padding, vertical: 12.padding),
      child: Row(
        children: [
          Container(
            width: 40.icon,
            height: 40.icon,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(tx.kind), color: color, size: 20.icon),
          ),
          12.row,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                2.column,
                Text(
                  _formatDate(tx.createdAt),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11.font,
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}m${tx.amount}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(WalletTxKind k) => switch (k) {
        WalletTxKind.topUp => Icons.add_circle_outline,
        WalletTxKind.gift => Icons.card_giftcard_outlined,
        WalletTxKind.unlock => Icons.lock_open_outlined,
        WalletTxKind.refund => Icons.undo_outlined,
        WalletTxKind.other => Icons.receipt_long_outlined,
      };

  static String _formatDate(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} · ${two(l.hour)}:${two(l.minute)}';
  }
}
