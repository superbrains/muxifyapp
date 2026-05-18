import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/data/artists_repository.dart';
import 'package:muxify/features/fan_profile/data/fan_profile_repository.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';

class GiftMeModal extends StatefulWidget {
  const GiftMeModal({
    super.key,
    required this.recipientFanId,
    required this.recipientUsername,
  });

  final String recipientFanId;
  final String recipientUsername;

  @override
  State<GiftMeModal> createState() => _GiftMeModalState();

  static Future<bool?> show(
    BuildContext context, {
    required String recipientFanId,
    required String recipientUsername,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => GiftMeModal(
        recipientFanId: recipientFanId,
        recipientUsername: recipientUsername,
      ),
    );
  }
}

class _GiftMeModalState extends State<GiftMeModal> {
  final ArtistsRepository _artistsRepository = ArtistsRepository();
  final FanProfileRepository _fanRepository = FanProfileRepository();

  late Future<List<GiftItem>> _giftTypesFuture;
  int _selectedIndex = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _giftTypesFuture = _artistsRepository.getGiftTypes();
  }

  Future<void> _send(List<GiftItem> gifts) async {
    if (_sending || gifts.isEmpty) return;
    setState(() => _sending = true);
    HapticFeedback.lightImpact();

    final gift = gifts[_selectedIndex];
    try {
      await _fanRepository.sendFanGift(
        fanId: widget.recipientFanId,
        giftType: gift.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sent ${gift.name} to ${widget.recipientUsername}!',
          ),
          backgroundColor: AppColors.buttonColor,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send gift: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gift ${widget.recipientUsername}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displayText.copyWith(
                color: AppColors.text,
                fontSize: 24.font,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
            13.column,
            Text(
              'Pick a gift to send from your wallet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
                fontSize: 12.font,
              ),
            ),
            20.column,
            FutureBuilder<List<GiftItem>>(
              future: _giftTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Padding(
                    padding: EdgeInsets.all(24.padding),
                    child: const CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(16.padding),
                    child: Text(
                      'Could not load gift options.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }
                final gifts = snapshot.data ?? const <GiftItem>[];
                if (gifts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.padding),
                    child: Text(
                      'No gift options available.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }

                if (_selectedIndex >= gifts.length) {
                  _selectedIndex = 0;
                }

                return Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.9,
                      ),
                      itemCount: gifts.length,
                      itemBuilder: (context, index) {
                        final gift = gifts[index];
                        return _GiftTypeCard(
                          gift: gift,
                          isSelected: _selectedIndex == index,
                          onTap: () => setState(() => _selectedIndex = index),
                        );
                      },
                    ),
                    24.column,
                    SizedBox(
                      width: double.infinity,
                      height: 56.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _sending ? null : () => _send(gifts),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF94444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.radius),
                          ),
                          elevation: 0,
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Send Gift',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.text,
                                  fontSize: 16.font,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftTypeCard extends StatelessWidget {
  const _GiftTypeCard({
    required this.gift,
    required this.isSelected,
    required this.onTap,
  });

  final GiftItem gift;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final coinCost =
        gift.amount != null ? gift.amount!.toInt().toString() : '—';
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.padding,
          vertical: 8.padding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor.withValues(alpha: 0.1)
              : AppColors.greyButtonColor,
          borderRadius: BorderRadius.circular(10.radius),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonColor
                : AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 28.icon,
              height: 28.icon,
            ),
            8.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gift.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 11.font,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  2.column,
                  Text(
                    'm$coinCost',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10.font,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
