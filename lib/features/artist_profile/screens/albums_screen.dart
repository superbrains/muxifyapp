import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/artist_profile/utils/release_playback_helper.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';

class AlbumsScreen extends StatefulWidget {
  final String? artistId;
  final String? artistName;

  const AlbumsScreen({super.key, this.artistId, this.artistName});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

    await context.read<ArtistProfileProvider>().loadArtistAlbums(
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
      appBar: const CustomAppBarWidget(title: 'Albums'),
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
            // Albums Grid
            Expanded(child: _buildAlbumsGrid()),
            30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumsGrid() {
    return Consumer<ArtistProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAlbums) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.albumsError != null) {
          return Center(
            child: Text(
              provider.albumsError!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.buttonColor,
              ),
            ),
          );
        }
        if (provider.albums.isEmpty) {
          return Center(
            child: Text(
              'No albums found',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text),
            ),
          );
        }

        final filteredAlbums = provider.albums.where((album) {
          if (_searchQuery.isEmpty) return true;
          return album.title.toLowerCase().contains(_searchQuery) ||
              album.artist.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredAlbums.isEmpty) {
          return Center(
            child: Text(
              'No albums match your search',
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
          itemCount: filteredAlbums.length,
          itemBuilder: (context, index) {
            final album = filteredAlbums[index].copyWith(isUnlocked: true);
            return ReleaseCardWidget(
              release: album,
              onTap: () async {
                HapticFeedback.lightImpact();
                await ReleasePlaybackHelper.openFromRelease(
                  context,
                  release: album,
                  albumName: 'Albums',
                  tryBackendStream: true,
                );
              },
              // TEMP: Unlock flow removed for now; always show Play button.
              // onUnlockTap: () => _showUnlockModal(album),
            );
          },
        );
      },
    );
  }
}
