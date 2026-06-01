import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/artist_profile/utils/release_playback_helper.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';

class SinglesScreen extends StatefulWidget {
  final String? artistId;
  final String? artistName;

  const SinglesScreen({super.key, this.artistId, this.artistName});

  @override
  State<SinglesScreen> createState() => _SinglesScreenState();
}

class _SinglesScreenState extends State<SinglesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isOpeningPlayer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final artistId = widget.artistId?.trim() ?? '';
    if (artistId.isEmpty) return;

    await context.read<ArtistProfileProvider>().loadArtistTracks(
      artistId,
      widget.artistName ?? 'Artist',
    );
  }

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
            SearchContainerWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
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
    return Consumer<ArtistProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTracks) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.tracksError != null) {
          return Center(
            child: Text(
              provider.tracksError!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.buttonColor,
              ),
            ),
          );
        }
        if (provider.tracks.isEmpty) {
          return Center(
            child: Text(
              'No singles found',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text),
            ),
          );
        }

        final filteredTracks = provider.tracks.where((track) {
          if (_searchQuery.isEmpty) return true;
          return track.title.toLowerCase().contains(_searchQuery) ||
              track.artist.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredTracks.isEmpty) {
          return Center(
            child: Text(
              'No singles match your search',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text),
            ),
          );
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20.padding,
            mainAxisSpacing: 20.padding,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredTracks.length,
          itemBuilder: (context, index) {
            final sourceTrack = filteredTracks[index];
            final displayTrack = sourceTrack.copyWith(isUnlocked: true);
            return ReleaseCardWidget(
              release: displayTrack,
              onTap: () async {
                if (_isOpeningPlayer) return;
                setState(() {
                  _isOpeningPlayer = true;
                });
                await ReleasePlaybackHelper.openFromRelease(
                  context,
                  release: sourceTrack,
                  albumName: 'Singles',
                  artistId: widget.artistId,
                  tryBackendStream: true,
                );
                if (!mounted) return;
                setState(() {
                  _isOpeningPlayer = false;
                });
              },
              // TEMP: Unlock flow removed for now; always show Play button.
              // onUnlockTap: () => _showUnlockModal(track),
            );
          },
        );
      },
    );
  }

}
