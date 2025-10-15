import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';

class SinglesScreen extends StatefulWidget {
  const SinglesScreen({super.key});

  @override
  State<SinglesScreen> createState() => _SinglesScreenState();
}

class _SinglesScreenState extends State<SinglesScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for singles
  final List<NewReleaseItem> _singles = [
    NewReleaseItem(
      id: '1',
      title: 'Last Last',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '2',
      title: 'Ye',
      artist: 'Burna Boy',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '3',
      title: 'Essence',
      artist: 'Wizkid ft. Tems',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '4',
      title: 'Joro',
      artist: 'Wizkid',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '5',
      title: 'Fall',
      artist: 'Davido',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '6',
      title: 'If',
      artist: 'Davido',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '7',
      title: 'Peru',
      artist: 'Fireboy DML',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '8',
      title: 'Bandana',
      artist: 'Fireboy DML ft. Asake',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    NewReleaseItem(
      id: '9',
      title: 'Buga',
      artist: 'Kizz Daniel ft. Tekno',
      coverImageUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    NewReleaseItem(
      id: '10',
      title: 'Woju',
      artist: 'Kizz Daniel',
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
      appBar: const CustomAppBarWidget(title: 'Singles'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.padding),
        child: Column(
          children: [
            20.column,
            // Search Bar
            SearchContainerWidget(controller: _searchController),
            30.column,
            // Singles Grid
            Expanded(child: _buildSinglesGrid()),
            30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildSinglesGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 0.75,
      ),
      itemCount: _singles.length,
      itemBuilder: (context, index) {
        return ReleaseCardWidget(
          release: _singles[index],
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to single details
          },
          onUnlockTap: () => _showUnlockModal(_singles[index]),
        );
      },
    );
  }

  void _showUnlockModal(NewReleaseItem single) {
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
              single.isUnlocked = true;
            });
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            setState(() {
              single.isUnlocked = true;
            });
          },
        );
      },
    );
  }
}
