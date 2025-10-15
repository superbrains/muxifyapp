import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';

class NewReleaseScreen extends StatefulWidget {
  const NewReleaseScreen({super.key});

  @override
  State<NewReleaseScreen> createState() => _NewReleaseScreenState();
}

class _NewReleaseScreenState extends State<NewReleaseScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for new releases
  final List<NewReleaseItem> _releases = [
    NewReleaseItem(
      id: '1',
      title: 'Boy Alone',
      artist: 'Omah Lay',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '2',
      title: 'Boy Alone',
      artist: 'Davido ft. Omah Lay',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '3',
      title: 'African Giant',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '4',
      title: 'Twice As Tall',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '5',
      title: 'Love, Damini',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '6',
      title: 'I Told Them...',
      artist: 'Burna Boy',
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
      appBar: const CustomAppBarWidget(title: 'New Release'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.padding),
        child: Column(
          children: [
            // Header
            // _buildHeader(),
            20.column,
            // Search Bar
            SearchContainerWidget(controller: _searchController),
            30.column,
            // Releases Grid
            Expanded(child: _buildReleasesGrid()),
            30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildReleasesGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 0.75,
      ),
      itemCount: _releases.length,
      itemBuilder: (context, index) {
        return ReleaseCardWidget(
          release: _releases[index],
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to release details
          },
          onUnlockTap: () => _showUnlockModal(_releases[index]),
        );
      },
    );
  }

  void _showUnlockModal(NewReleaseItem release) {
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
              release.isUnlocked = true;
            });
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            setState(() {
              release.isUnlocked = true;
            });
          },
        );
      },
    );
  }
}
