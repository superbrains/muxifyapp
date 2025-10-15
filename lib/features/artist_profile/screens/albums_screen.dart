import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for albums
  final List<NewReleaseItem> _albums = [
    NewReleaseItem(
      id: '1',
      title: 'African Giant',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '2',
      title: 'Twice As Tall',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '3',
      title: 'Love, Damini',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '4',
      title: 'I Told Them...',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '5',
      title: 'Made in Lagos',
      artist: 'Wizkid',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '6',
      title: 'More Love, Less Ego',
      artist: 'Wizkid',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '7',
      title: 'A Better Time',
      artist: 'Davido',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '8',
      title: 'Timeless',
      artist: 'Davido',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarWidget(title: 'Albums'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.padding),
        child: Column(
          children: [
            20.column,
            // Search Bar
            SearchContainerWidget(controller: _searchController),
            30.column,
            // Albums Grid
            Expanded(child: _buildAlbumsGrid()),
            30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumsGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 0.75,
      ),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        return ReleaseCardWidget(
          release: _albums[index],
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to album details
          },
          onUnlockTap: () => _showUnlockModal(_albums[index]),
        );
      },
    );
  }

  void _showUnlockModal(NewReleaseItem album) {
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
              album.isUnlocked = true;
            });
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            setState(() {
              album.isUnlocked = true;
            });
          },
        );
      },
    );
  }
}
