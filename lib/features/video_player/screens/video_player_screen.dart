import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/home/data/video_feed_repository.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/video_cover_image.dart';
import 'package:muxify/features/video_player/data/video_repository.dart';
import 'package:muxify/features/video_player/models/video_detail.dart';
import 'package:muxify/features/video_player/widgets/youtube_style_video_controls.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/content_unlock_confirm_modal.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';
import 'package:muxify/shared/widgets/unlock_celebration_overlay.dart';
import 'package:video_player/video_player.dart';

/// One candidate stream source for the player. We try HLS (adaptive, served via
/// the authenticated proxy with a Bearer header) first, then fall back to the
/// self-contained presigned progressive MP4.
class _StreamCandidate {
  final String url;
  final Map<String, String> headers;
  final bool isHls;
  const _StreamCandidate(this.url, this.headers, this.isHls);
}

/// YouTube-style video experience: a 16:9 player with custom controls on top,
/// then a scrollable detail sheet (title, real artist row, like/share/gift
/// action bar, description) and an "Up Next" list. Premium videos follow the
/// exact same coin-unlock flow as music via [ContentUnlockConfirmModal].
class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String artistName;
  final String? artistId;
  final String? thumbnailUrl;
  final bool isUnlocked;
  final int? unlockCostCoins;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.artistName,
    this.artistId,
    this.thumbnailUrl,
    this.isUnlocked = true,
    this.unlockCostCoins,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final ApiRequester _api = ApiRequester();
  final VideoRepository _videoRepo = VideoRepository();
  final VideoFeedRepository _feedRepo = VideoFeedRepository();
  final WalletApiService _wallet = WalletApiService();

  // Authoritative server detail; seeded from route params for first paint.
  VideoDetail? _detail;
  late bool _isUnlocked;

  VideoPlayerController? _videoController;
  bool _isLoadingStream = false;
  String? _streamError;
  bool _playRecorded = false;
  bool _triedProgressiveFallback = false;

  // Like state (optimistic).
  bool _isLiked = false;
  int _likeCount = 0;
  bool _likeBusy = false;

  // Coin rate drives the locked overlay's ≈₦ value; the unlock modal fetches
  // its own live wallet balance.
  CoinRate _coinRate = CoinRate.fallback();

  // Up Next.
  List<VideoItem> _upNext = const [];
  bool _loadingUpNext = true;

  // Guards the one-shot auto-advance when the current video reaches its end.
  bool _advanced = false;

  String get _displayTitle =>
      (_detail?.title.trim().isNotEmpty ?? false)
          ? _detail!.title
          : (widget.title.trim().isEmpty ? 'Untitled' : widget.title);

  String get _displayArtist =>
      (_detail?.artistName.trim().isNotEmpty ?? false)
          ? _detail!.artistName
          : (widget.artistName.trim().isEmpty
              ? 'Unknown artist'
              : widget.artistName);

  String? get _displayThumb =>
      _detail?.thumbnailUrl ?? widget.thumbnailUrl;

  String? get _artistId =>
      (_detail?.artistId.trim().isNotEmpty ?? false)
          ? _detail!.artistId
          : widget.artistId;

  int get _unlockCost =>
      _detail?.unlockCostCoins ?? widget.unlockCostCoins ?? 0;

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.isUnlocked;
    // The video screen owns its own playback surface — keep the persistent mini
    // audio player hidden over it (portrait and fullscreen/landscape alike).
    _setMiniPlayerSuppressed(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final unlocked = context.read<UnlockedContentProvider>();
      if (!_isUnlocked && unlocked.isUnlocked(widget.videoId)) {
        _isUnlocked = true;
      }
      context.read<ArtistProfileProvider>().loadGiftTypes();
      _hydrateCoinRate();
      _hydrateDetail();
      _loadUpNext();
      if (_isUnlocked) _initializePlayback();
    });
  }

  @override
  void dispose() {
    // Restore the mini-player once the video screen is popped. A fullscreen
    // route pushed on top doesn't dispose this screen, so the bar stays hidden
    // until the player itself closes.
    _setMiniPlayerSuppressed(false);
    _videoController?.removeListener(_onPlayerTick);
    _videoController?.dispose();
    super.dispose();
  }

  /// Flip the global [AppRouter.miniPlayerSuppressed] notifier safely. If we're
  /// mid-frame (route transition runs inside build/layout), defer to the
  /// post-frame callback to avoid mutating the overlay's builder mid-build;
  /// otherwise apply immediately so the bar toggles without a one-frame flash.
  void _setMiniPlayerSuppressed(bool suppressed) {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.miniPlayerSuppressed.value = suppressed;
      });
    } else {
      AppRouter.miniPlayerSuppressed.value = suppressed;
    }
  }

  Future<void> _hydrateCoinRate() async {
    try {
      final rate = await _wallet.fetchCoinRate();
      if (!mounted) return;
      setState(() => _coinRate = rate);
    } catch (e, st) {
      Logger.error('VideoPlayerScreen.hydrateCoinRate failed', e, st);
    }
  }

  /// Fetches the authoritative [VideoDetail] and drives the UI from it: unlock
  /// state, pricing, the real artist avatar, counts, description and like state.
  Future<void> _hydrateDetail() async {
    if (widget.videoId.trim().isEmpty) return;
    try {
      final detail = await _videoRepo.getVideoDetail(widget.videoId);
      if (!mounted) return;
      final persisted =
          context.read<UnlockedContentProvider>().isUnlocked(widget.videoId);
      final unlocked = detail.isUnlocked || persisted;
      setState(() {
        _detail = detail;
        _isLiked = detail.isLiked;
        _likeCount = detail.likeCount;
        if (unlocked) _isUnlocked = true;
      });
      if (unlocked && _videoController == null && !_isLoadingStream) {
        _initializePlayback();
      }
    } catch (e, st) {
      // Non-fatal: route params already gave us enough to render + unlock.
      Logger.error('VideoPlayerScreen.hydrateDetail failed', e, st);
    }
  }

  Future<void> _loadUpNext() async {
    try {
      // Trending first; fall back to fresh/hot releases when trending is sparse
      // so "Up Next" reliably has something to advance to. De-dupe by id and
      // drop the current video.
      final items = <VideoItem>[];
      final seen = <String>{widget.videoId};

      void addAll(List<VideoItem> candidates) {
        for (final v in candidates) {
          if (v.id.isEmpty || !seen.add(v.id)) continue;
          items.add(v);
        }
      }

      addAll((await _feedRepo.getTrendingVideos(pageSize: 12))
          .map(VideoItem.fromFeedVideo)
          .toList());

      if (items.length < 5) {
        addAll((await _feedRepo.getNewReleaseVideos(pageSize: 12))
            .map(VideoItem.fromFeedVideo)
            .toList());
      }
      if (items.length < 5) {
        addAll((await _feedRepo.getHotReleaseVideos(pageSize: 12))
            .map(VideoItem.fromFeedVideo)
            .toList());
      }

      if (!mounted) return;
      setState(() {
        _upNext = items.take(10).toList();
        _loadingUpNext = false;
      });
    } catch (e, st) {
      Logger.error('VideoPlayerScreen.loadUpNext failed', e, st);
      if (mounted) setState(() => _loadingUpNext = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> _initializePlayback() async {
    final tag = 'VideoPlayer[${widget.videoId}]';
    if (widget.videoId.trim().isEmpty) {
      Logger.warning('$tag aborted: empty videoId');
      return;
    }
    if (_isLoadingStream || _videoController != null) return;

    setState(() {
      _isLoadingStream = true;
      _streamError = null;
      _advanced = false;
    });

    Map<String, dynamic> payload;
    try {
      payload = await _api.getJson(
        ApiConstants.videoStreamPath(widget.videoId),
        (json) => json,
        authenticate: true,
      );
    } catch (e, st) {
      Logger.error('$tag stream metadata fetch failed', e, st);
      if (!mounted) return;
      setState(() {
        _isLoadingStream = false;
        _streamError = _formatPlaybackError('Stream lookup failed', e);
      });
      return;
    }

    final candidates = await _resolveCandidates(payload);
    if (candidates.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoadingStream = false;
        _streamError =
            _formatPlaybackError('No streaming URL returned', 'payload=$payload');
      });
      return;
    }

    Object? lastError;
    for (final c in candidates) {
      Logger.info('$tag initializing (${c.isHls ? 'HLS' : 'progressive'}): ${c.url}');
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(c.url),
        httpHeaders: c.headers,
      );
      try {
        await controller.initialize();
      } catch (e) {
        lastError = e;
        Logger.warning('$tag init failed for ${c.isHls ? 'HLS' : 'MP4'}: $e');
        await controller.dispose();
        continue;
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _triedProgressiveFallback = !c.isHls;
      controller
        ..setLooping(false)
        ..addListener(_onPlayerTick)
        ..play();
      setState(() {
        _videoController = controller;
        _isLoadingStream = false;
      });
      return;
    }

    // Every candidate failed.
    if (!mounted) return;
    setState(() {
      _isLoadingStream = false;
      _streamError = _formatPlaybackError('Player init failed', lastError ?? 'unknown');
    });
  }

  /// Builds the ordered candidate list from the backend `StreamingUrlDto`.
  /// HLS (adaptive) first via the authed proxy with a Bearer header; then the
  /// self-contained presigned progressive MP4.
  Future<List<_StreamCandidate>> _resolveCandidates(
      Map<String, dynamic> payload) async {
    final progressive = (payload['url'] as String?)?.trim();
    final hlsRaw = (payload['hlsUrl'] as String?)?.trim();
    final hls = (hlsRaw != null && hlsRaw.isNotEmpty)
        ? ApiConstants.resolvePublicUrl(hlsRaw)
        : null;

    final token = await LocalStorageService.getAccessToken();
    final authHeaders = (token != null && token.trim().isNotEmpty)
        ? {ApiConstants.authorization: '${ApiConstants.bearer} ${token.trim()}'}
        : <String, String>{};

    final out = <_StreamCandidate>[];
    if (hls != null && hls.isNotEmpty) {
      out.add(_StreamCandidate(hls, authHeaders, true));
    }
    if (progressive != null && progressive.isNotEmpty) {
      out.add(_StreamCandidate(progressive, const {}, false));
    }
    return out;
  }

  String _formatPlaybackError(String stage, Object detail) {
    if (kDebugMode) return 'Cannot play this video.\n\n[$stage]\n$detail';
    return 'Could not load this video. Please try again.';
  }

  void _onPlayerTick() {
    final c = _videoController;
    if (c == null) return;

    // Recover a stalled HLS stream by falling back to the progressive MP4 once.
    if (c.value.hasError && !_triedProgressiveFallback) {
      _triedProgressiveFallback = true;
      Logger.warning('VideoPlayer error — falling back to progressive MP4');
      _recoverWithProgressive();
      return;
    }

    // Auto-advance to the next video when this one finishes (YouTube-style).
    if (!_advanced &&
        c.value.isInitialized &&
        !c.value.isLooping &&
        c.value.duration > Duration.zero &&
        !c.value.isBuffering &&
        c.value.position >= c.value.duration - const Duration(milliseconds: 350)) {
      _advanced = true;
      _playNextVideo();
      return;
    }

    if (_playRecorded) return;
    if (!c.value.isInitialized || !c.value.isPlaying) return;
    if (c.value.position.inMilliseconds < 250) return;
    _playRecorded = true;
    _recordPlay();
  }

  /// Navigate to the first Up Next entry when the current video ends. Does
  /// nothing when the list is empty (the video simply stops).
  void _playNextVideo() {
    if (_upNext.isEmpty) return;
    _openVideo(_upNext.first);
  }

  Future<void> _recoverWithProgressive() async {
    final old = _videoController;
    final lastPos = old?.value.position ?? Duration.zero;
    old?.removeListener(_onPlayerTick);
    await old?.dispose();
    if (mounted) setState(() => _videoController = null);

    try {
      final payload = await _api.getJson(
        ApiConstants.videoStreamPath(widget.videoId),
        (json) => json,
        authenticate: true,
      );
      final progressive = (payload['url'] as String?)?.trim();
      if (progressive == null || progressive.isEmpty) return;
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(progressive));
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _advanced = false;
      controller
        ..setLooping(false)
        ..addListener(_onPlayerTick)
        ..seekTo(lastPos)
        ..play();
      setState(() => _videoController = controller);
    } catch (e, st) {
      Logger.error('VideoPlayer progressive recovery failed', e, st);
    }
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
      Logger.error('VideoPlayerScreen.recordPlay failed', e, st);
    }
  }

  void _openFullscreen() {
    final c = _videoController;
    if (c == null || !c.value.isInitialized) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(controller: c, title: _displayTitle),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Unlock (identical to music)
  // ---------------------------------------------------------------------------

  void _handleUnlockTap() {
    final unlocked = context.read<UnlockedContentProvider>();
    if (unlocked.isUnlocked(widget.videoId) ||
        (_detail?.isUnlocked ?? false)) {
      if (!_isUnlocked) {
        setState(() => _isUnlocked = true);
        _initializePlayback();
      }
      return;
    }

    ContentUnlockConfirmModal.show(
      context,
      lockPrompt: 'Unlock this video?',
      contentTitle: _displayTitle,
      artistName: _displayArtist,
      unlockCostCoins: _unlockCost,
      coinsPerNairaMajor: _coinRate.coinsPerNairaMajor,
      successMessage: 'Video unlocked',
      onUnlock: () => _videoRepo.unlockVideo(widget.videoId),
      onUnlocked: () async {
        await context
            .read<UnlockedContentProvider>()
            .markUnlocked(widget.videoId);
        if (!mounted) return;
        setState(() {
          _isUnlocked = true;
          _detail = _detail?.copyWith(isUnlocked: true);
        });
        UnlockCelebrationOverlay.show(
          context,
          coverImage: _displayThumb ?? '',
          title: _displayTitle,
          subtitle: _displayArtist,
          caption: 'Video unlocked',
        );
        _initializePlayback();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Like / Share / Gift
  // ---------------------------------------------------------------------------

  Future<void> _toggleLike() async {
    if (_likeBusy || widget.videoId.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _likeBusy = true;
      _isLiked = !_isLiked;
      _likeCount = (_likeCount + (_isLiked ? 1 : -1)).clamp(0, 1 << 31);
    });
    try {
      final status = await _videoRepo.toggleLike(widget.videoId);
      if (!mounted) return;
      setState(() {
        _isLiked = status.liked;
        _likeCount = status.likeCount;
      });
    } catch (e, st) {
      Logger.error('VideoPlayerScreen.toggleLike failed', e, st);
      if (!mounted) return;
      // Revert the optimistic flip.
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = (_likeCount + (_isLiked ? 1 : -1)).clamp(0, 1 << 31);
      });
      await AppToast.showError('Could not update like. Try again.');
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    final deeplink = 'muxify://video/${widget.videoId}';
    await Share.share(
      'Check out "$_displayTitle" by $_displayArtist on Muxify\n$deeplink',
      subject: _displayTitle,
    );
  }

  void _showGiftBoxModal() {
    final provider = context.read<ArtistProfileProvider>();
    final artistId = (_artistId ?? '').trim();
    if (artistId.isEmpty) {
      AppToast.showError('We could not identify the artist to gift.');
      return;
    }
    if (provider.isLoadingGifts) {
      AppToast.showInfo('Loading gifts...');
      return;
    }
    if (provider.gifts.isEmpty) {
      provider.loadGiftTypes();
      AppToast.showError('No gifts available right now. Try again.');
      return;
    }

    final videoId = widget.videoId.trim();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return GiftBoxModal(
          headerText: 'GIFTBOX',
          subHeaderText: 'Tap to send gift',
          giftItems: provider.gifts,
          recipientArtistId: artistId,
          videoId: videoId.isEmpty ? null : videoId,
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _openVideo(VideoItem item) {
    final id = item.id.trim();
    if (id.isEmpty) return;
    final uri = Uri(
      path: AppRouter.videoPlayer,
      queryParameters: {
        'videoId': id,
        'title': item.title,
        'artistName': item.creator,
        if ((item.creatorId ?? '').isNotEmpty) 'artistId': item.creatorId,
        if (item.imageUrl.isNotEmpty) 'thumbnailUrl': item.imageUrl,
        'isUnlocked': '${item.isUnlocked}',
        if (item.unlockCostCoins > 0)
          'unlockCostCoins': '${item.unlockCostCoins}',
      },
    );
    context.push(uri.toString());
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 16:9 by width, but never taller than 70% of the viewport so the
            // detail list always has room. Without this cap a short (landscape)
            // viewport makes the fixed 16:9 player overflow the Column.
            final playerHeight =
                (constraints.maxWidth * 9 / 16).clamp(0.0, constraints.maxHeight * 0.7);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlayerArea(playerHeight),
                Expanded(
                  child: ListView(
                padding: EdgeInsets.fromLTRB(
                  18.padding,
                  16.padding,
                  18.padding,
                  // The persistent mini-player is suppressed on this screen, so
                  // only a normal bottom inset is needed.
                  24.padding,
                ),
                    children: [
                      _buildTitleBlock(),
                      16.column,
                      _buildActionBar(),
                      18.column,
                      _buildArtistRow(),
                      if ((_detail?.description ?? '').trim().isNotEmpty) ...[
                        16.column,
                        _Description(text: _detail!.description!.trim()),
                      ],
                      24.column,
                      _buildUpNextSection(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerArea(double height) {
    final controller = _videoController;
    final ready = _isUnlocked && controller != null && controller.value.isInitialized;

    return SizedBox(
      height: height,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster (until the first frame paints / while locked).
            if (!ready)
              VideoCoverImage(
                imageUrl: _displayThumb ?? '',
                fit: BoxFit.cover,
                fallbackAsset: 'assets/pngs/sabinus_background_image.png',
              ),

            if (ready)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio == 0
                      ? 16 / 9
                      : controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),

            if (ready)
              YouTubeStyleVideoControls(
                controller: controller,
                onToggleFullscreen: _openFullscreen,
                onBack: () => Navigator.of(context).maybePop(),
                title: _displayTitle,
              ),

            // Locked / loading / error overlays sit above the poster.
            if (!ready) ...[
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.35)),
              ),
              if (_isUnlocked && _isLoadingStream)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                  ),
                )
              else if (_isUnlocked && _streamError != null)
                _PlayerMessage(
                  message: _streamError!,
                  onRetry: () {
                    setState(() {
                      _streamError = null;
                      _triedProgressiveFallback = false;
                    });
                    _initializePlayback();
                  },
                )
              else if (!_isUnlocked)
                _LockedOverlay(
                  cost: _unlockCost,
                  coinRate: _coinRate,
                  onUnlock: _handleUnlockTap,
                ),

              // Back button (top-left) for the locked / loading states.
              Positioned(
                top: 6.padding,
                left: 6.padding,
                child: _CircleIcon(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    final views = _detail?.viewCount;
    final created = _detail?.createdAt;
    final meta = <String>[
      if (views != null) '${_formatCount(views)} views',
      if (created != null) _timeAgo(created),
    ].join('  ·  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayTitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.text,
            fontSize: 18.font,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (meta.isNotEmpty) ...[
          6.column,
          Text(
            meta,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
              fontSize: 12.font,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        _ActionChip(
          icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          iconColor: _isLiked ? AppColors.buttonColor : AppColors.text,
          label: _likeCount > 0 ? _formatCount(_likeCount) : 'Like',
          onTap: _toggleLike,
        ),
        12.row,
        _ActionChip(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: _share,
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
          width: 128.maxWidth,
          height: 48.maxHeight,
        ),
      ],
    );
  }

  Widget _buildArtistRow() {
    final avatar = _detail?.artistAvatarUrl;
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 42.maxWidth,
            height: 42.maxHeight,
            child: (avatar != null && avatar.isNotEmpty)
                ? AuthNetworkImage(
                    path: avatar,
                    fit: BoxFit.cover,
                    placeholder: _avatarFallback(),
                    errorWidget: _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
        ),
        12.row,
        Expanded(
          child: Text(
            _displayArtist,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text,
              fontSize: 15.font,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if ((_artistId ?? '').isNotEmpty)
          TextButton(
            onPressed: () {
              final id = _artistId!.trim();
              context.push('${AppRouter.artistProfile}?artistId=$id');
            },
            child: Text(
              'View',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.buttonColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColors.text.withValues(alpha: 0.12),
      child: Icon(
        Icons.person,
        size: 24.icon,
        color: AppColors.text.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _buildUpNextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Up Next',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w700,
          ),
        ),
        12.column,
        if (_loadingUpNext)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.padding),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
              ),
            ),
          )
        else if (_upNext.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.padding),
            child: Text(
              'No more videos right now.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ..._upNext.map(
            (v) => _UpNextRow(item: v, onTap: () => _openVideo(v)),
          ),
      ],
    );
  }

  static String _formatCount(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
  }

  static String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

// -----------------------------------------------------------------------------
// Small presentational widgets
// -----------------------------------------------------------------------------

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.padding, vertical: 9.padding),
        decoration: BoxDecoration(
          color: AppColors.text.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? AppColors.text, size: 20.icon),
            6.row,
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text,
                fontSize: 13.font,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final int cost;
  final CoinRate coinRate;
  final VoidCallback onUnlock;

  const _LockedOverlay({
    required this.cost,
    required this.coinRate,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final naira = cost > 0 ? coinRate.nairaLabel(cost) : null;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline, color: AppColors.text, size: 28.icon),
          ),
          12.column,
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 22.padding,
                vertical: 12.padding,
              ),
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                borderRadius: BorderRadius.circular(30.radius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/pngs/Bitcoin_musixfy.png',
                    width: 22.icon,
                    height: 22.icon,
                  ),
                  8.row,
                  Text(
                    cost > 0
                        ? 'Unlock Video · ${CoinRate.groupThousands(cost)}'
                        : 'Unlock Video',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (naira != null) ...[
            8.column,
            Text(
              naira,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.75),
                fontSize: 12.font,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _PlayerMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.text,
                fontSize: 13.font,
              ),
            ),
            12.column,
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.text),
              label: Text(
                'Retry',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Description extends StatefulWidget {
  final String text;
  const _Description({required this.text});

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.padding),
        decoration: BoxDecoration(
          color: AppColors.text.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.8),
                fontSize: 13.font,
                height: 1.4,
              ),
            ),
            4.column,
            Text(
              _expanded ? 'Show less' : 'Show more',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 12.font,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  final VideoItem item;
  final VoidCallback onTap;
  const _UpNextRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.radius),
              child: SizedBox(
                width: 150.maxWidth,
                height: 84.maxHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoCoverImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    if (!item.isUnlocked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.lock_outline,
                          color: AppColors.text,
                          size: 22.icon,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            12.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  6.column,
                  Text(
                    item.creator,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                      fontSize: 12.font,
                    ),
                  ),
                  if ((item.views ?? '').isNotEmpty) ...[
                    2.column,
                    Text(
                      '${item.views} views',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 11.font,
                      ),
                    ),
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
