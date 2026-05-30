import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders the post-initiate UX for a coin top-up:
///
/// - If Brij returned an `authorization_url`, embeds a `WebView` so the user
///   can complete card/3DS in-app. We detect the configured redirect URL to
///   know the user finished, then start status polling.
/// - If Brij returned virtual-account/USSD details, renders a "pay to this
///   account" card with copy-to-clipboard helpers and a countdown.
/// - In both cases the screen polls
///   `GET /api/v1/payments/collections/{intentId}` until the intent reaches
///   a terminal state (Succeeded / Failed / Expired) and then pivots to the
///   matching summary card.
class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({
    super.key,
    required this.intentId,
    this.initial,
  });

  final String intentId;

  /// Initial state passed from the bottom sheet so the first frame can render
  /// channel metadata immediately without waiting for the first poll.
  final InitiateCollectionResult? initial;

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  static const _redirectScheme = 'muxify://payments/callback';

  final _api = WalletApiService();

  Timer? _poller;
  CollectionStatus? _latest;
  bool _polling = false;
  int _consecutivePolls = 0;

  Map<String, dynamic>? get _channel =>
      _latest?.channelMetadata ?? widget.initial?.channelMetadata;
  DateTime? get _expiresAt => _latest?.expiresAt ?? widget.initial?.expiresAt;
  String? get _authorizationUrl {
    final c = _channel;
    final raw = c?['authorization_url'] ?? c?['authorizationUrl'];
    return raw is String && raw.isNotEmpty ? raw : null;
  }

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollOnce();
    _poller = Timer.periodic(const Duration(seconds: 4), (_) {
      _consecutivePolls += 1;
      // Back off to every 12s after 30 polls (~2 minutes) to be kind to the
      // server when payments naturally take a while (e.g. bank transfers).
      if (_consecutivePolls > 30 &&
          _poller?.tick != null &&
          (_poller!.tick % 3) != 0) {
        return;
      }
      _pollOnce();
    });
  }

  Future<void> _pollOnce() async {
    if (_polling) return;
    _polling = true;
    try {
      final status = await _api.fetchCollectionStatus(widget.intentId);
      if (!mounted) return;
      setState(() => _latest = status);
      if (status.isTerminal) _poller?.cancel();
    } catch (_) {
      // Network blips are non-fatal — the next tick will retry.
    } finally {
      _polling = false;
    }
  }

  void _onWebViewNavigated(NavigationRequest req) {
    if (req.url.startsWith(_redirectScheme)) {
      _pollOnce();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // If the payment succeeded, return true so the previous screen
            // (Get Coins or Wallet) can refresh on resume.
            context.pop(_latest?.isSucceeded ?? false);
          },
          icon: Icon(Icons.close, color: AppColors.text, size: 28.icon),
        ),
        title: Text(
          'Complete Payment',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.text,
            fontSize: 18.font,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final latest = _latest;
    if (latest?.isSucceeded == true) return _SuccessCard(coins: latest!.coinsAmount);
    if (latest?.isFailed == true) {
      return _FailureCard(
        title: 'Payment failed',
        message: latest!.failureReason ?? 'The payment did not go through.',
      );
    }
    if (latest?.isExpired == true) {
      return _FailureCard(
        title: 'Payment expired',
        message: 'This top-up window has expired. Try again from Get Coins.',
      );
    }

    final authUrl = _authorizationUrl;
    if (authUrl != null) return _WebViewBody(url: authUrl, onNavigate: _onWebViewNavigated);

    final account = _channel;
    if (_isVirtualAccount(account)) {
      return _VirtualAccountBody(
        details: account!,
        expiresAt: _expiresAt,
        onRefresh: _pollOnce,
      );
    }

    return const _GenericPendingBody();
  }

  bool _isVirtualAccount(Map<String, dynamic>? c) {
    if (c == null) return false;
    return c.containsKey('account_number') ||
        c.containsKey('accountNumber') ||
        c.containsKey('bank_name') ||
        c.containsKey('bankName');
  }
}

class _WebViewBody extends StatefulWidget {
  const _WebViewBody({required this.url, required this.onNavigate});

  final String url;
  final void Function(NavigationRequest) onNavigate;

  @override
  State<_WebViewBody> createState() => _WebViewBodyState();
}

class _WebViewBodyState extends State<_WebViewBody> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          widget.onNavigate(req);
          if (req.url.startsWith('muxify://')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class _VirtualAccountBody extends StatelessWidget {
  const _VirtualAccountBody({
    required this.details,
    required this.expiresAt,
    required this.onRefresh,
  });

  final Map<String, dynamic> details;
  final DateTime? expiresAt;
  final VoidCallback onRefresh;

  String _readString(List<String> keys, {String fallback = '—'}) {
    for (final k in keys) {
      final v = details[k];
      if (v is String && v.isNotEmpty) return v;
      if (v is num) return v.toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final accountNumber = _readString(['account_number', 'accountNumber']);
    final bankName = _readString(['bank_name', 'bankName']);
    final accountName = _readString(['account_name', 'accountName'], fallback: 'Muxify');
    final amount = _readString(['amount', 'amountDisplay'], fallback: '');

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.padding, 24.padding, 20.padding, 24.padding),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
              borderRadius: BorderRadius.circular(20.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay to virtual account',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text.withValues(alpha: 0.85),
                    fontSize: 12.font,
                  ),
                ),
                8.column,
                Text(
                  'Send the exact amount below from any bank app.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontSize: 13.font,
                  ),
                ),
                16.column,
                _DetailRow(label: 'Bank', value: bankName, copyable: false),
                10.column,
                _DetailRow(label: 'Account number', value: accountNumber),
                10.column,
                _DetailRow(label: 'Account name', value: accountName, copyable: false),
                if (amount.isNotEmpty) ...[
                  10.column,
                  _DetailRow(label: 'Amount', value: '₦$amount', copyable: false),
                ],
              ],
            ),
          ),
          18.column,
          if (expiresAt != null)
            _ExpiryCountdown(expiresAt: expiresAt!),
          18.column,
          Container(
            padding: EdgeInsets.all(16.padding),
            decoration: BoxDecoration(
              color: AppColors.glassyDark,
              borderRadius: BorderRadius.circular(14.radius),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24.icon,
                  height: 24.icon,
                  child: const CircularProgressIndicator(strokeWidth: 2.4),
                ),
                14.row,
                Expanded(
                  child: Text(
                    'Waiting for payment confirmation…',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 13.font,
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.column,
          TextButton.icon(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh, size: 18.icon, color: AppColors.buttonColor),
            label: Text(
              'Check now',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.buttonColor,
                fontSize: 14.font,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = true,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
              fontSize: 12.font,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontSize: 14.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (copyable) ...[
                6.row,
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    AppToast.showError('Copied');
                  },
                  child: Icon(Icons.copy, size: 16.icon, color: AppColors.text),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpiryCountdown extends StatefulWidget {
  const _ExpiryCountdown({required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<_ExpiryCountdown> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return Text(
        'Window expired — start a fresh top-up.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.cautionIcon,
          fontSize: 12.font,
        ),
      );
    }
    final mm = remaining.inMinutes.toString().padLeft(2, '0');
    final ss = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      'Expires in $mm:$ss',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.text.withValues(alpha: 0.7),
        fontSize: 12.font,
      ),
    );
  }
}

class _GenericPendingBody extends StatelessWidget {
  const _GenericPendingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          16.column,
          Text(
            'Awaiting payment confirmation…',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text,
              fontSize: 13.font,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.coins});

  final int? coins;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(28.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.green, size: 72.icon),
          18.column,
          Text(
            'Payment successful',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.text,
              fontSize: 22.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.column,
          Text(
            coins != null
                ? 'You received ${_format(coins!)} coins. Enjoy!'
                : 'Coins have been credited to your wallet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
              fontSize: 14.font,
            ),
          ),
          28.column,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Reset to Home, then push the wallet on top so its Back button
                // returns to Home. Using go() alone would replace the whole
                // stack and leave the wallet page with nothing to pop back to.
                final router = GoRouter.of(context);
                router.go(AppRouter.home);
                router.push(AppRouter.walletPayment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: EdgeInsets.symmetric(vertical: 16.padding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.radius),
                ),
              ),
              child: Text(
                'Back to Wallet',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.text,
                  fontSize: 14.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(28.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined,
              color: const Color(0xFFE57373), size: 72.icon),
          18.column,
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.text,
              fontSize: 22.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.column,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
              fontSize: 14.font,
            ),
          ),
          28.column,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.pop(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: EdgeInsets.symmetric(vertical: 16.padding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.radius),
                ),
              ),
              child: Text(
                'Try a different method',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.text,
                  fontSize: 14.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
