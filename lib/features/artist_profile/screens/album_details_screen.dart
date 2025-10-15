import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/features/artist_profile/widgets/songs_list_widget.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';

class AlbumDetailsScreen extends StatefulWidget {
  const AlbumDetailsScreen({super.key});

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  // Sample album data
  final String _albumTitle = 'Boy Alone';
  final String _artistName = 'Omah Lay';
  final String _year = '2024';
  final String _albumArtUrl = 'assets/pngs/follows.png';

  // Sample songs data
  final List<GenreSongItem> _songs = [
    GenreSongItem(
      id: '1',
      title: 'Soso',
      artist: 'Omah Lay',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: '2',
      title: 'Never Forget',
      artist: 'Omah Lay',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    GenreSongItem(
      id: '3',
      title: 'Soso',
      artist: 'Omah Lay',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: '4',
      title: 'Never Forget',
      artist: 'Omah Lay',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    GenreSongItem(
      id: '5',
      title: 'Soso',
      artist: 'Omah Lay',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: '6',
      title: 'Never Forget',
      artist: 'Omah Lay',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarWidget(title: 'Boy Alone'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Album Header Section
            _buildAlbumHeader(),
            30.column,
            // Songs List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.padding),
              child: SongsListWidget(
                songs: _songs,
                onSongTap: (song) {
                  HapticFeedback.lightImpact();
                  // Navigate to song details
                },
                onPlayUnlockTap: (song) {
                  setState(() {
                    final index = _songs.indexOf(song);
                    if (index != -1) {
                      _songs[index] = _songs[index].copyWith(
                        isUnlocked: !_songs[index].isUnlocked,
                      );
                    }
                  });
                },
                onMenuTap: (song) {
                  HapticFeedback.lightImpact();
                  // Show song menu
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.padding,
        right: 20.padding,
        top: 20.padding,
        bottom: 20.padding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          transform: const GradientRotation(1.5),
          colors: [
            AppColors.playlistGradientStart,
            AppColors.playlistGradientStart.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0, 0.4, 0.8],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art
          Container(
            width: 159.maxWidth,
            height: 159.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.radius),
              image: DecorationImage(
                image: AssetImage(_albumArtUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          16.row,
          // Album Details and Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Title
                Text(
                  _albumTitle,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 30.font,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withValues(alpha: 0.75),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.column,
                // Artist Name
                Text(
                  _artistName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 18.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.8),
                  ),
                ),
                4.column,
                // Year
                Text(
                  _year,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w400,
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
                16.column,
                // Action Buttons Row
                Row(
                  children: [
                    // Menu Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Show album menu
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.text.withValues(alpha: 0.7),
                        size: 24.icon,
                      ),
                    ),
                    Spacer(),
                    // Unlock Album Button
                    UnlockButton(
                      text: 'Unlock Album',
                      iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                      // backgroundColor: AppColors.buttonColor,
                      // textColor: Colors.white,
                      // iconColor: Colors.white,
                      iconSize: 26.icon,
                      spacing: 5.padding,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.padding,
                        vertical: 8.padding,
                      ),
                      borderRadius: 20.radius,
                      onTap: () => _showUnlockAlbumModal(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlockAlbumModal() {
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
            // Handle album unlock
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            // Handle album unlock
          },
        );
      },
    );
  }
}
