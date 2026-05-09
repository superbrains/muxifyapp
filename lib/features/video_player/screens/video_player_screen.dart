import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:muxify/features/home/widgets/video_cover_image.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/circular_icon_button.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';
import 'package:muxify/shared/widgets/menu_bottom_sheet.dart';
import 'package:muxify/shared/widgets/menu_item_model.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/shared/widgets/unlock_confirm_bottom_sheet.dart';
import 'package:muxify/shared/widgets/unlock_success_dialog.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String artistName;
  final String? artistId;
  final String? thumbnailUrl;
  final bool isUnlocked;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.artistName,
    this.artistId,
    this.thumbnailUrl,
    this.isUnlocked = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late bool _isUnlocked;
  final ApiRequester _api = ApiRequester();

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoadingStream = false;
  String? _streamError;
  bool _playRecorded = false;

  // Mock gift items for the gift box modal — replaced with real data
  // when the gifts feature ships its own provider.
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
  ];

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.isUnlocked;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Persisted unlock from a previous session/screen overrides the route param.
      final unlocked = context.read<UnlockedContentProvider>();
      if (!_isUnlocked && unlocked.isUnlocked(widget.videoId)) {
        setState(() => _isUnlocked = true);
        _initializePlayback();
      }
    });
    if (_isUnlocked) _initializePlayback();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayback() async {
    if (widget.videoId.trim().isEmpty) return;
    if (_isLoadingStream || _videoController != null) return;

    setState(() {
      _isLoadingStream = true;
      _streamError = null;
    });

    try {
      // Resolve the streaming URL via /api/v1/content/videos/{id}/stream.
      // The backend returns { streamingUrl, hlsPlaylistUrl, ... } — we prefer
      // HLS when present, falling back to the progressive URL.
      final streamPayload = await _api.getJson(
        ApiConstants.videoStreamPath(widget.videoId),
        (json) => json,
        authenticate: true,
      );

      final hls = (streamPayload['hlsPlaylistUrl'] as String?)?.trim();
      final progressive =
          (streamPayload['streamingUrl'] as String?)?.trim();
      final url = (hls != null && hls.isNotEmpty)
          ? hls
          : (progressive ?? '');
      if (url.isEmpty) {
        throw const FormatException('No streaming URL returned');
      }

      final controller =
          VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.buttonColor,
          handleColor: AppColors.buttonColor,
          bufferedColor: AppColors.text.withValues(alpha: 0.2),
          backgroundColor: AppColors.text.withValues(alpha: 0.08),
        ),
      );
      controller.addListener(_onPlayerTick);

      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _isLoadingStream = false;
      });
    } catch (e, st) {
      Logger.error('VideoPlayerScreen.initializePlayback failed', e, st);
      if (!mounted) return;
      setState(() {
        _isLoadingStream = false;
        _streamError = 'Could not load this video. Please try again.';
      });
    }
  }

  void _onPlayerTick() {
    if (_playRecorded) return;
    final c = _videoController;
    if (c == null || !c.value.isInitialized || !c.value.isPlaying) return;
    if (c.value.position.inMilliseconds < 250) return;
    _playRecorded = true;
    _recordPlay();
  }

  Future<void> _recordPlay() async {
    if (widget.videoId.trim().isEmpty) return;
    try {
      await _api.postJson<Map<String, dynamic>>(
        ApiConstants.videoRecordPlayPath(widget.videoId),
        const {'platform': 'mobile'},
        (json) => json,
        successStatus: ApiConstants.statusOk,
        authenticate: true,
      );
    } catch (e, st) {
      // Non-fatal — viewer experience must continue even if telemetry fails.
      Logger.error('VideoPlayerScreen.recordPlay failed', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background poster — visible while the video loads or while locked.
          Positioned.fill(
            child: VideoCoverImage(
              imageUrl: widget.thumbnailUrl ?? '',
              fit: BoxFit.cover,
              fallbackAsset: 'assets/pngs/sabinus_background_image.png',
            ),
          ),

          // Subtle blur/gradient overlay for readability.
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

          // Live player layered over the poster once initialized.
          if (_isUnlocked && _chewieController != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio == 0
                    ? 16 / 9
                    : _videoController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            ),

          if (_isUnlocked && _isLoadingStream)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                ),
              ),
            ),

          if (_isUnlocked && _streamError != null)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.padding),
                  child: Text(
                    _streamError!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                    ),
                  ),
                ),
              ),
            ),

          // Foreground UI (top bar, unlock button, gift CTA, etc.)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleIconButton(
                        context,
                        Icons.keyboard_arrow_down_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
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
                            _handleUnlockTap();
                          },
                        ),
                        const Spacer(),
                      ],

                      CircularIconButton(
                        onTap: () {},
                        icon: Icons.favorite_border_rounded,
                        iconSize: 24.icon,
                        iconColor: AppColors.text,
                        backgroundColor:
                            AppColors.text.withValues(alpha: 0.08),
                        buttonSize: 44,
                      ),
                      14.row,
                      CircularIconButton(
                        onTap: () {},
                        icon: Icons.share_outlined,
                        iconSize: 24.icon,
                        backgroundColor:
                            AppColors.text.withValues(alpha: 0.08),
                        buttonSize: 44,
                        iconColor: AppColors.text,
                      ),
                    ],
                  ),
                  10.column,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20.radius,
                        backgroundColor:
                            AppColors.text.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.person,
                          size: 24.icon,
                          color: AppColors.text.withValues(alpha: 0.45),
                        ),
                      ),
                      10.row,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title.isEmpty ? 'Untitled' : widget.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.text,
                                fontSize: 16.font,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.artistName.isEmpty
                                  ? 'Unknown artist'
                                  : widget.artistName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.text.withValues(alpha: 0.7),
                                fontSize: 13.font,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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

  /// Routes the user past the unlock modal if the video is already unlocked
  /// (persisted from a previous unlock). Otherwise opens the unlock flow.
  void _handleUnlockTap() {
    final unlocked = context.read<UnlockedContentProvider>();
    if (unlocked.isUnlocked(widget.videoId)) {
      if (!_isUnlocked) {
        setState(() => _isUnlocked = true);
        _initializePlayback();
      }
      return;
    }
    _showUnlockModal();
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20.radius)),
      ),
      builder: (context) {
        return UnlockConfirmBottomSheet(
          title: widget.title.isEmpty ? 'This video' : widget.title,
          subtitle: widget.artistName,
          imagePath: widget.thumbnailUrl ?? 'assets/pngs/sabinus.png',
          primaryButtonText: 'Unlock Video',
          isPremiumMode: false,
          onClose: () => Navigator.of(context).pop(),
          onConfirm: () async {
            Navigator.of(context).pop();
            await _unlockOnBackend();
            if (!mounted) return;
            setState(() => _isUnlocked = true);
            _initializePlayback();
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20.radius)),
      ),
      builder: (context) {
        final isDemo = ApiConstants.demoMode;
        return UnlockConfirmBottomSheet(
          title: widget.title.isEmpty ? 'This video' : widget.title,
          subtitle: widget.artistName,
          imagePath: widget.thumbnailUrl ?? 'assets/pngs/follows.png',
          primaryButtonText: 'Unlock Video',
          isPremiumMode: true,
          unlockTitle: 'Unlock Video',
          showInsufficientCoinsError: !isDemo,
          onClose: () => Navigator.of(context).pop(),
          onConfirm: () async {
            Navigator.of(context).pop();
            await _unlockOnBackend();
            if (!mounted) return;
            setState(() => _isUnlocked = true);
            _initializePlayback();
            _showSuccessDialog();
          },
          onGetCoins: isDemo
              ? null
              : () {
                  Navigator.of(context).pop();
                  context.push(AppRouter.getCoins);
                },
        );
      },
    );
  }

  Future<void> _unlockOnBackend() async {
    if (widget.videoId.trim().isEmpty) return;
    try {
      await _api.postJson<Map<String, dynamic>>(
        ApiConstants.videoUnlockPath(widget.videoId),
        const {},
        (json) => json,
        successStatus: ApiConstants.statusOk,
        authenticate: true,
      );
      if (!mounted) return;
      await context
          .read<UnlockedContentProvider>()
          .markUnlocked(widget.videoId);
    } catch (e, st) {
      // Demo mode silently allows unlock; in production this should bubble up.
      Logger.error('VideoPlayerScreen.unlockOnBackend failed', e, st);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => UnlockSuccessDialog(
        heading: 'Congratulation!',
        message: 'You have a unlocked',
        mediaTitle: widget.title.isEmpty ? 'This video' : widget.title,
        mediaSubtitle: widget.artistName,
        imagePath: widget.thumbnailUrl ?? 'assets/pngs/sabinus.png',
        primaryButtonText: 'Play Now',
        onPrimary: () {
          Navigator.of(context).pop();
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
          _handleUnlockTap();
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
        onTap: () {},
      ),
      MenuItemModel(
        text: 'Share with friends',
        icon: Icons.share_outlined,
        onTap: () {},
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
