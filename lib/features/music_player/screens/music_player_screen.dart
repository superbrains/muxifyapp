import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
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
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  // Sample song data
  final String _songTitle = 'Moving';
  final String _artistName = 'Omah Lay';
  final String _albumName = 'Latest Release';
  final String _backgroundImageUrl = 'assets/pngs/music_player.png';

  // Player state
  bool _isPlaying = true;
  bool _isShuffled = false;
  bool _isRepeating = false;
  bool _isLiked = false;
  bool _isAdded = false;
  bool _isUnlocked = false; // Add this to control the conditional UI

  // Progress state
  double _currentPosition = 0.3; // 30 seconds
  final double _totalDuration = 5.01; // 5 minutes 1 second

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(_backgroundImageUrl, fit: BoxFit.cover),
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
                  artistName: _artistName,
                  albumName: _albumName,
                  isUnlocked: _isUnlocked,
                  onToggleUnlock: () {
                    setState(() {
                      _isUnlocked = !_isUnlocked;
                    });
                  },
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
                          songTitle: _songTitle,
                          artistName: _artistName,
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
                            HapticFeedback.lightImpact();
                            _showUnlockModal();
                          },
                          onShowLyrics: _showLyricsModal,
                        ),

                        30.column,
                        // Progress Bar
                        MusicProgressBar(
                          currentPosition: _currentPosition,
                          totalDuration: _totalDuration,
                          onChanged: (value) {
                            setState(() {
                              _currentPosition = value;
                            });
                          },
                          onChangeEnd: (value) {
                            setState(() {
                              _currentPosition = value;
                            });
                          },
                        ),
                        20.column,
                        // Playback Controls
                        PlaybackControls(
                          isPlaying: _isPlaying,
                          isRepeating: _isRepeating,
                          isShuffled: _isShuffled,
                          onTogglePlay: () {
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                          },
                          onPrevious: () {
                            HapticFeedback.lightImpact();
                          },
                          onNext: () {
                            HapticFeedback.lightImpact();
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
                        SendGiftsButton(
                          onTap: _showGiftBoxModal,
                        ),
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
            setState(() {
              _isUnlocked = true;
            });
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            setState(() {
              _isUnlocked = true;
            });
          },
        );
      },
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
}
