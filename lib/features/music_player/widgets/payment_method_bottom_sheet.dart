import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:shimmer/shimmer.dart';

/// Bottom sheet that lists the live payment channels Brij currently supports
/// for the user's currency, then drives the initiate → status-screen handoff.
///
/// Replaces the older static seven-tile sheet (Paystack/PayPal/Stripe/…)
/// which only showed a dummy congratulations dialog.
class PaymentMethodBottomSheet extends StatefulWidget {
  const PaymentMethodBottomSheet({
    super.key,
    required this.onClose,
    required this.packageId,
    required this.packageLabel,
    required this.priceDisplay,
    required this.customerContact,
    this.customerName,
    this.customerEmail,
  });

  final VoidCallback onClose;
  final String packageId;
  final String packageLabel;
  final String priceDisplay;
  final String customerContact;
  final String? customerName;
  final String? customerEmail;

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  final _api = WalletApiService();
  List<CollectionMethod>? _methods;
  String? _loadError;
  CollectionMethod? _initiatingMethod;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() {
      _loadError = null;
      _methods = null;
    });
    try {
      final methods = await _api.fetchPaymentMethods(currency: 'NGN');
      if (!mounted) return;
      setState(() => _methods = methods);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Could not load payment methods. Try again.');
    }
  }

  Future<void> _onMethodTapped(CollectionMethod method) async {
    if (_initiatingMethod != null) return;
    HapticFeedback.lightImpact();
    setState(() => _initiatingMethod = method);

    // Capture the GoRouter before any await so we can navigate without
    // touching the BuildContext after the async gap.
    final router = GoRouter.of(context);

    try {
      if (method.requiresOtp) {
        // Fire-and-forget OTP send so Brij can SMS the user before we initiate.
        await _api.sendPaymentOtp(customerContact: widget.customerContact);
      }

      final result = await _api.initiateCollection(
        packageId: widget.packageId,
        paymentMethodId: method.id,
        customerContact: widget.customerContact,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        redirectUrl: 'muxify://payments/callback',
      );

      if (!mounted) return;
      widget.onClose();
      // Slight delay so the bottom-sheet pop animation finishes before push.
      Future.delayed(const Duration(milliseconds: 120), () {
        router.push(
          '${AppRouter.paymentStatus}?intentId=${Uri.encodeComponent(result.intentId)}',
          extra: result,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _initiatingMethod = null);
      await AppToast.showError('Could not start payment. Try another method.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      height: media.size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.radius),
          topRight: Radius.circular(20.radius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildSummaryStrip(),
          16.column,
          Expanded(child: _buildBody()),
          SizedBox(height: media.padding.bottom),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.padding,
        left: 16.padding,
        right: 16.padding,
        bottom: 10.padding,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onClose();
            },
            child: Icon(Icons.arrow_back, color: AppColors.text, size: 28.icon),
          ),
          Expanded(
            child: Text(
              'Funding Method',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 20.font,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 28.maxWidth),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.padding, vertical: 12.padding),
        decoration: BoxDecoration(
          color: AppColors.glassyDark,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 28.icon,
              height: 28.icon,
            ),
            10.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.packageLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  2.column,
                  Text(
                    'Funded by Brij',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.55),
                      fontSize: 11.font,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.padding, vertical: 6.padding),
              decoration: BoxDecoration(
                color: AppColors.darkGreyButtonColor,
                borderRadius: BorderRadius.circular(20.radius),
              ),
              child: Text(
                '₦${widget.priceDisplay}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontSize: 12.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadError != null) {
      return _buildErrorState(_loadError!, onRetry: _loadMethods);
    }
    final methods = _methods;
    if (methods == null) return _buildLoadingGrid();
    if (methods.isEmpty) {
      return _buildErrorState('No payment methods available right now.',
          onRetry: _loadMethods);
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.padding,
          mainAxisSpacing: 18.padding,
          childAspectRatio: 0.78,
        ),
        itemCount: methods.length,
        itemBuilder: (context, i) {
          final method = methods[i];
          final isLoading = _initiatingMethod?.id == method.id;
          return _PaymentMethodTile(
            method: method,
            isLoading: isLoading,
            disabled: _initiatingMethod != null && !isLoading,
            onTap: () => _onMethodTapped(method),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: Shimmer.fromColors(
        baseColor: AppColors.glassyDark,
        highlightColor: AppColors.glassyLight,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.padding,
            mainAxisSpacing: 18.padding,
            childAspectRatio: 0.78,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: AppColors.glassyDark,
              borderRadius: BorderRadius.circular(14.radius),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: AppColors.text.withValues(alpha: 0.5), size: 36.icon),
            12.column,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
                fontSize: 13.font,
              ),
            ),
            14.column,
            TextButton(
              onPressed: onRetry,
              child: Text('Retry',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.buttonColor,
                    fontSize: 14.font,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.isLoading,
    required this.disabled,
    required this.onTap,
  });

  final CollectionMethod method;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Column(
          children: [
            Container(
              width: 96.maxWidth,
              height: 96.maxHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2.4)
                    : _IconForMethod(method: method),
              ),
            ),
            10.column,
            Text(
              method.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontSize: 12.font,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves a logo for a given Brij channel by id. Falls back to a category
/// icon based on `fundType` so even brand-new channels render reasonably
/// without a code change.
class _IconForMethod extends StatelessWidget {
  const _IconForMethod({required this.method});

  final CollectionMethod method;

  static const Map<String, String> _logoById = {
    // Mobile money channels (Brij dispatch IDs)
    'mtn-momo': 'assets/pngs/momo.png',
    'airtel-money': 'assets/pngs/network.png',
    // Traditional banking
    'bank-transfer': 'assets/pngs/paystack.png',
    'card': 'assets/pngs/stripe.png',
    'ussd': 'assets/pngs/network.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _logoById[method.id.toLowerCase()];
    if (asset != null) {
      return Padding(
        padding: EdgeInsets.all(12.padding),
        child: Image.asset(asset, fit: BoxFit.contain, errorBuilder: _fallback),
      );
    }
    return _fallback(context, null, null);
  }

  Widget _fallback(BuildContext context, Object? _, StackTrace? __) {
    final iconData = switch (method.fundType.toLowerCase()) {
      'mobile_money' || 'mobilemoney' || 'wallet' => Icons.phone_iphone_outlined,
      'bank_transfer' || 'banktransfer' => Icons.account_balance_outlined,
      'card' => Icons.credit_card_outlined,
      'ussd' => Icons.dialpad_outlined,
      _ => Icons.payments_outlined,
    };
    return Center(
      child: Icon(iconData, size: 36.icon, color: AppColors.background),
    );
  }
}
