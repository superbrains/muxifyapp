import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/music_player/widgets/earned_badge_dialog.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final VoidCallback onClose;

  const PaymentMethodBottomSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.radius),
          topRight: Radius.circular(20.radius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          _buildHeader(),

          // Title and Subtitle
          _buildTitleSection(),
          30.column,
          // Payment Methods Grid
          Expanded(child: _buildPaymentMethodsGrid()),

          // // Bottom padding
          // SizedBox(height: MediaQuery.of(context).padding.bottom + 20.padding),
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
              onClose();
            },
            child: Icon(Icons.arrow_back, color: AppColors.text, size: 30.icon),
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

          SizedBox(width: 20.maxWidth),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      'Choose how you want to buy your coins.',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.text,
        fontSize: 14.font,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPaymentMethodsGrid() {
    final paymentMethods = [
      PaymentMethod(name: 'Paystack', logoPath: 'assets/pngs/paystack.png'),
      PaymentMethod(
        name: 'Flutterwave',
        logoPath: 'assets/pngs/flutterwave.png',
      ),
      PaymentMethod(name: 'Fincra', logoPath: 'assets/pngs/fincra.png'),
      PaymentMethod(name: 'MTN - MoMo', logoPath: 'assets/pngs/momo.png'),
      PaymentMethod(name: 'Stripe', logoPath: 'assets/pngs/stripe.png'),
      PaymentMethod(name: 'PayPal', logoPath: 'assets/pngs/paypal.png'),
      PaymentMethod(name: 'Airtime', logoPath: 'assets/pngs/network.png'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 23,
          childAspectRatio: 0.85,
        ),
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          final method = paymentMethods[index];
          return _buildPaymentMethodCard(method, context);
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _handlePaymentMethodSelection(method, context);
      },
      child: Column(
        children: [
          // Logo Container
          Container(
            width: 109.maxWidth,
            height: 109.maxHeight,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Padding(
                padding: EdgeInsets.all(12.padding),
                child: Image.asset(method.logoPath, fit: BoxFit.contain),
              ),
            ),
          ),

          8.column,

          // Method Name
          Text(
            method.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 12.font,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _handlePaymentMethodSelection(
    PaymentMethod method,
    BuildContext context,
  ) {
    // Close sheet then show earned badge dialog
    onClose();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (context.mounted) {
        showDialog(context: context, builder: (_) => const EarnedBadgeDialog());
      }
    });
  }
}

class PaymentMethod {
  final String name;
  final String logoPath;

  PaymentMethod({required this.name, required this.logoPath});
}
