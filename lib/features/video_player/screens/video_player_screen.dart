import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/circular_icon_button.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/shared/widgets/unlock_confirm_bottom_sheet.dart';
import 'package:muxify/shared/widgets/unlock_success_dialog.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/menu_bottom_sheet.dart';
import 'package:muxify/shared/widgets/menu_item_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isUnlocked = false;

  // Mock gift items for the gift box modal
  final List<GiftItem> _giftItems = [
    GiftItem(
      id: '1',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj1.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '2',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj4.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '3',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg3.png',
      emojiImage: 'assets/pngs/emoj3.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '4',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
    ),
    GiftItem(
      id: '5',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '6',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '7',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg3.png',
      emojiImage: 'assets/pngs/emoj1.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '8',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '9',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '10',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
    ),
    GiftItem(
      id: '11',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '12',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '13',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
    ),
    GiftItem(
      id: '14',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '15',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj1.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '16',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj4.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/pngs/sabinus_background_image.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Subtle blur/gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.2),
                    AppColors.background.withValues(alpha: 0.35),
                    AppColors.background.withValues(alpha: 0.55),
                    AppColors.background.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleIconButton(
                        context,
                        Icons.keyboard_arrow_down_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      // Text(
                      //   'Now Playing',
                      //   style: TextStyle(
                      //     color: AppColors.text,
                      //     fontSize: 16.font,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      _circleIconButton(
                        context,
                        Icons.more_vert_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showMenuBottomSheet();
                        },
                      ),
                    ],
                  ),

                  const Spacer(),
                  if (!_isUnlocked) ...[
                    SizedBox(
                      height: 124.maxHeight,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/pngs/ads_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    20.column,
                  ],
                  // Creator/info row + actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!_isUnlocked) ...[
                        UnlockButton(
                          backgroundColor: AppColors.text.withValues(
                            alpha: 0.75,
                          ),
                          height: 44.buttonHeight,
                          width: 158.maxWidth,
                          text: 'Unlock Video',
                          iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                          iconSize: 32.icon,
                          spacing: 6.padding,
                          borderRadius: 20.radius,
                          border: Border.all(
                            width: 1.45.border,
                            color: AppColors.text,
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showUnlockModal();
                          },
                        ),
                        const Spacer(),
                      ],

                      CircularIconButton(
                        onTap: () {},
                        icon: Icons.favorite_border_rounded,
                        iconSize: 24.icon,
                        iconColor: AppColors.text,
                        backgroundColor: AppColors.text.withValues(alpha: 0.08),
                        buttonSize: 44,
                      ),
                      14.row,
                      CircularIconButton(
                        onTap: () {},
                        icon: Icons.share_outlined,
                        iconSize: 24.icon,
                        backgroundColor: AppColors.text.withValues(alpha: 0.08),
                        buttonSize: 44,
                        iconColor: AppColors.text,
                      ),
                    ],
                  ),
                  10.column,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20.radius,
                        backgroundImage: const AssetImage(
                          'assets/pngs/follows.png',
                        ),
                      ),
                      10.row,
                      // Name
                      Expanded(
                        child: Text(
                          'Mr Funny',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.text,
                            fontSize: 20.font,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      GlassButtonWidget(
                        showGiftIcon: true,
                        iconColor: AppColors.text,
                        text: 'Gift Me',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showGiftBoxModal();
                        },
                        backgroundColor: AppColors.buttonColor,
                        width: 136.maxWidth,
                        height: 52.maxHeight,
                      ),
                    ],
                  ),
                  10.column,
                  // Description
                  Text(
                    'Lorem ipsum dolor sit amet consectetur. Consectetur aliquam varius tortor fermentum at purus. Sodales eget in tristique duis pulvinar nibh ornare amet.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  11.column,
                  // Bottom nav mock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _bottomNavItem(Icons.home_outlined, 'Home'),
                      _bottomNavItem(Icons.explore_outlined, 'Discover'),
                      _bottomNavItem(Icons.search_outlined, 'Search'),
                      _bottomNavItem(
                        Icons.video_library_outlined,
                        'Library',
                        selected: true,
                      ),
                    ],
                  ),
                  18.column,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.maxWidth,
        height: 40.maxHeight,
        decoration: BoxDecoration(
          color: AppColors.text.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.text, size: 18.icon),
      ),
    );
  }

  // Widget _bottomAction(IconData icon, String label) {
  Widget _bottomNavItem(IconData icon, String label, {bool selected = false}) {
    final Color color = selected
        ? AppColors.text
        : AppColors.text.withValues(alpha: 0.40);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24.icon),
        8.column,
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontSize: 14.font,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showUnlockModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UnlockAllSongsModal(
          onClose: () {
            Navigator.of(context).pop();
          },
          onUnlockPremium: () {
            Navigator.of(context).pop();
            _showPremiumUnlockSheet();
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            _showFreeUnlockSheet();
          },
        );
      },
    );
  }

  void _showFreeUnlockSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.modalBackground,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.radius)),
      ),
      builder: (context) {
        return UnlockConfirmBottomSheet(
          title: 'But Why Sabinus',
          subtitle: 'Sabinus',
          imagePath: 'assets/pngs/sabinus.png',
          primaryButtonText: 'Unlock Video',
          isPremiumMode: false,
          onClose: () => Navigator.of(context).pop(),
          onConfirm: () {
            Navigator.of(context).pop();
            setState(() {
              _isUnlocked = true;
            });
            _showSuccessDialog();
          },
        );
      },
    );
  }

  void _showPremiumUnlockSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.modalBackground,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.radius)),
      ),
      builder: (context) {
        return UnlockConfirmBottomSheet(
          title: 'With You ft. Omah Lay',
          subtitle: 'Davido',
          imagePath: 'assets/pngs/follows.png',
          primaryButtonText: 'Unlock Video',
          isPremiumMode: true,
          unlockTitle: 'Unlock Song',
          // coinCost: '100,250',
          showInsufficientCoinsError: true,
          onClose: () => Navigator.of(context).pop(),
          onConfirm: () {
            // This will only be called if user has enough coins
            Navigator.of(context).pop();
            setState(() {
              _isUnlocked = true;
            });
            _showSuccessDialog();
          },
          onGetCoins: () {
            Navigator.of(context).pop();
            context.push(AppRouter.getCoins);
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => UnlockSuccessDialog(
        heading: 'Congratulation!',
        message: 'You have a unlocked',
        mediaTitle: 'But Why Sabinus',
        mediaSubtitle: 'Davido',
        imagePath: 'assets/pngs/sabinus.png',
        primaryButtonText: 'Play Now',
        onPrimary: () {
          Navigator.of(context).pop();
          // Optionally start playback here
        },
      ),
    );
  }

  void _showGiftBoxModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GiftBoxModal(
          headerText: 'GIFTBOX',
          subHeaderText: 'Tap to send gift',
          giftItems: _giftItems,
          onClose: () {
            Navigator.of(context).pop();
          },
          onGiftSelected: (GiftItem gift) {},
        );
      },
    );
  }

  void _showMenuBottomSheet() {
    final menuItems = [
      MenuItemModel(
        text: 'Unlock',
        iconPath: 'assets/pngs/unlock_icon.png',
        onTap: () {
          _showUnlockModal();
        },
      ),
      MenuItemModel(
        text: 'Share gift',
        icon: Icons.card_giftcard_outlined,
        onTap: () {
          _showGiftBoxModal();
        },
      ),
     
      MenuItemModel(
        text: 'Add to favourite',
        icon: Icons.favorite_outline,
        onTap: () {
          // Handle add to favourite
        },
      ),
      MenuItemModel(
        text: 'Share with friends',
        icon: Icons.share_outlined,
        onTap: () {
          // Handle share with friends
        },
      ),
      
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return MenuBottomSheet(
          title: 'Menu',
          onClose: () => Navigator.of(context).pop(),
          menuItems: menuItems,
        );
      },
    );
  }
}
