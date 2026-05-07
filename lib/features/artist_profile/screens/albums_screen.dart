import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/release_card_widget.dart';
import 'package:muxify/features/artist_profile/widgets/search_container_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';

class AlbumsScreen extends StatefulWidget {
  final String? artistId;
  final String? artistName;

  const AlbumsScreen({super.key, this.artistId, this.artistName});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final TextEditingController _searchController = TextEditingController();

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
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20.padding,
            mainAxisSpacing: 20.padding,
            childAspectRatio: 0.75,
          ),
          itemCount: provider.albums.length,
          itemBuilder: (context, index) {
            return ReleaseCardWidget(
              release: provider.albums[index],
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to album details
              },
              onUnlockTap: () => _showUnlockModal(provider.albums[index]),
            );
          },
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
            // TODO: Implement unlocking in provider if needed
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            // TODO: Implement unlocking in provider if needed
          },
        );
      },
    );
  }
}
