import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';

class AllVideosScreen extends StatefulWidget {
  const AllVideosScreen({super.key});

  @override
  State<AllVideosScreen> createState() => _AllVideosScreenState();
}

class _AllVideosScreenState extends State<AllVideosScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Video releases data (same as NewReleaseScreen video data)
  final List<NewReleaseItem> _videos = [
    NewReleaseItem(
      id: 'v1',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      coverImageUrl: 'assets/pngs/sabinus.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: 'v2',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      coverImageUrl: 'assets/pngs/sabinus.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: 'v3',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      coverImageUrl: 'assets/pngs/sabinus.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: 'v4',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      coverImageUrl: 'assets/pngs/sabinus.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: 'v5',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      coverImageUrl: 'assets/pngs/sabinus.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: 'v6',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      coverImageUrl: 'assets/pngs/sabinus.png',
      isUnlocked: true,
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
      appBar: const CustomAppBarWidget(title: 'All Videos'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.padding),
        child: Column(
          children: [
            20.column,
            // Search Bar
            SearchContainerWidget(controller: _searchController),
            30.column,
            // Videos Grid
            Expanded(child: _buildVideosGrid()),
            30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 0.75,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return ReleaseCardWidget(
          release: _videos[index],
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to video details
          },
          onUnlockTap: () => _showUnlockModal(_videos[index]),
        );
      },
    );
  }

  void _showUnlockModal(NewReleaseItem video) {
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
              final index = _videos.indexOf(video);
              if (index != -1) {
                _videos[index] = _videos[index].copyWith(isUnlocked: true);
              }
            });
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            setState(() {
              final index = _videos.indexOf(video);
              if (index != -1) {
                _videos[index] = _videos[index].copyWith(isUnlocked: true);
              }
            });
          },
        );
      },
    );
  }
}

