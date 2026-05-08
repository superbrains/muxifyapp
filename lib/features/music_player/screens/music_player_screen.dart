import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:muxify/features/music_player/widgets/lyrics_modal.dart';
import 'package:muxify/features/music_player/widgets/music_player_top_bar.dart';
import 'package:muxify/features/music_player/widgets/lyrics_button_widget.dart';
import 'package:muxify/features/music_player/widgets/locked_song_image_list.dart';
import 'package:muxify/features/music_player/widgets/song_info_overlay.dart';
import 'package:muxify/features/music_player/widgets/music_progress_bar.dart';
import 'package:muxify/features/music_player/widgets/playback_controls.dart';
import 'package:muxify/features/music_player/widgets/send_gifts_button.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String? trackId;
  final String? title;
  final String? artistName;
  final String? albumName;
  final String? backgroundImageUrl;
  final String? audioUrl;
  final bool? isUnlocked;

  const MusicPlayerScreen({
    super.key,
    this.trackId,
    this.title,
    this.artistName,
    this.albumName,
    this.backgroundImageUrl,
    this.audioUrl,
    this.isUnlocked,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  // Player state
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  bool _isLiked = false;
  bool _isAdded = false;
  bool _isUnlocked = true;

  // Progress state
  double _currentPosition = 0;
  double _totalDuration = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  // Mock images for locked song horizontal list
  final List<String> _lockedSongImages = [
    'assets/pngs/follows.png',
    'assets/pngs/latest_release.png',
    'assets/pngs/active_play.png',
    'assets/pngs/follows.png',
    'assets/pngs/latest_release.png',
    'assets/pngs/active_play.png',
  ];

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
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '11',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg3.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '12',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '13',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg5.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '14',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg6.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '15',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '16',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg7.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // TEMP: lock feature disabled for now.
    _isUnlocked = true;
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (!mounted) return;
        setState(() {
          _totalDuration = (duration ?? Duration.zero).inMilliseconds / 1000;
        });
      });

      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (!mounted) return;
        final seconds = position.inMilliseconds / 1000;
        setState(() {
          _currentPosition = seconds.clamp(
            0,
            _totalDuration > 0 ? _totalDuration : seconds,
          );
        });
      });

      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state.playing;
        });

        if (state.processingState == ProcessingState.completed) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }
      });

      final requestedAudioUrl = widget.audioUrl?.trim() ?? '';
      if (requestedAudioUrl.isEmpty) {
        Logger.warning('Music player missing stream URL; skipping playback');
        if (mounted) {
          await AppToast.showError('Missing stream URL for this track.');
        }
        return;
      }

      Logger.debug('Music player setUrl: $requestedAudioUrl');
      await _audioPlayer.setUrl(requestedAudioUrl);
      await _audioPlayer.play();
    } catch (e, st) {
      Logger.error('Music player audio setup failed', e, st);
      // Keep UI responsive even if audio initialization fails.
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = (widget.backgroundImageUrl ?? '').trim();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: background.isEmpty
                ? Image.asset('assets/pngs/music_player.png', fit: BoxFit.cover)
                : _buildBackgroundImage(background),
          ),

          // Dark overlay for unlocked songs only
          if (_isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

          // Blur effect for locked songs only
          if (!_isUnlocked)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // Content
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                // Top Bar
                MusicPlayerTopBar(
                  artistName: widget.artistName ?? 'Omah Lay',
                  albumName: widget.albumName ?? 'Latest Release',
                  isUnlocked: _isUnlocked,
                  // TEMP: lock feature disabled for now.
                  onToggleUnlock: () {},
                ),

                // Lyrics Button
                LyricsButtonWidget(
                  icon: Icons.music_note_outlined,
                  text: 'Lyrics',
                  onTap: _showLyricsModal,
                ),

                // Horizontal image list for locked songs
                if (!_isUnlocked) ...[
                  20.column,
                  LockedSongImageList(images: _lockedSongImages),
                  20.column,
                ] else
                  Spacer(),
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 22.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Song Info Overlay
                        SongInfoOverlay(
                          songTitle: widget.title ?? 'Moving',
                          artistName: widget.artistName ?? 'Omah Lay',
                          isUnlocked: _isUnlocked,
                          isLiked: _isLiked,
                          isAdded: _isAdded,
                          onToggleLike: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          onToggleAdd: () {
                            setState(() {
                              _isAdded = !_isAdded;
                            });
                          },
                          onShare: () {
                            HapticFeedback.lightImpact();
                          },
                          onUnlockSong: () {
                            // TEMP: lock feature disabled for now.
                          },
                          onShowLyrics: _showLyricsModal,
                        ),

                        30.column,
                        // Progress Bar
                        MusicProgressBar(
                          currentPosition: _currentPosition,
                          totalDuration: _totalDuration <= 0 ? 1 : _totalDuration,
                          onChanged: (value) {
                            setState(() {
                              _currentPosition = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _audioPlayer.seek(
                              Duration(milliseconds: (value * 1000).toInt()),
                            );
                          },
                        ),
                        20.column,
                        // Playback Controls
                        PlaybackControls(
                          isPlaying: _isPlaying,
                          isRepeating: _isRepeating,
                          isShuffled: _isShuffled,
                          onTogglePlay: () {
                            if (_isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                          onPrevious: () {
                            HapticFeedback.lightImpact();
                            _audioPlayer.seek(Duration.zero);
                          },
                          onNext: () {
                            HapticFeedback.lightImpact();
                            _audioPlayer.seek(Duration.zero);
                          },
                          onToggleRepeat: () {
                            setState(() {
                              _isRepeating = !_isRepeating;
                            });
                          },
                          onToggleShuffle: () {
                            setState(() {
                              _isShuffled = !_isShuffled;
                            });
                          },
                        ),
                        54.column,
                        // Send Gifts Button
                        SendGiftsButton(onTap: _showGiftBoxModal),
                        20.column, // Extra padding at bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLyricsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const LyricsModal();
      },
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

  Widget _buildBackgroundImage(String source) {
    final lower = source.toLowerCase();
    if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        source.startsWith('/')) {
      return Image.network(
        ApiConstants.resolvePublicUrl(source),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/pngs/music_player.png', fit: BoxFit.cover),
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Image.asset('assets/pngs/music_player.png', fit: BoxFit.cover),
    );
  }
}
