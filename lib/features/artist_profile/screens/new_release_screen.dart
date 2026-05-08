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

class NewReleaseScreen extends StatefulWidget {
  final String? mediaType;
  final String? artistId;
  final String? artistName;

  const NewReleaseScreen({
    super.key,
    this.mediaType,
    this.artistId,
    this.artistName,
  });

  @override
  State<NewReleaseScreen> createState() => _NewReleaseScreenState();
}

class _NewReleaseScreenState extends State<NewReleaseScreen> {
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

    await context.read<ArtistProfileProvider>().loadArtistNewReleases(
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
      appBar: const CustomAppBarWidget(title: 'New Release'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.padding),
        child: Column(
          children: [
            20.column,
            SearchContainerWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            30.column,
            Expanded(child: _buildReleasesGrid()),
            30.column,
          ],
        ),
      ),
    );
  }

  Widget _buildReleasesGrid() {
    return Consumer<ArtistProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingReleases) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.releasesError != null) {
          return Center(
            child: Text(
              provider.releasesError!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.buttonColor,
              ),
            ),
          );
        }
        if (provider.releases.isEmpty) {
          return Center(
            child: Text(
              'No new releases found',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text),
            ),
          );
        }

        final filteredReleases = provider.releases.where((release) {
          if (_searchQuery.isEmpty) return true;
          return release.title.toLowerCase().contains(_searchQuery) ||
              release.artist.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredReleases.isEmpty) {
          return Center(
            child: Text(
              'No releases match your search',
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
          itemCount: filteredReleases.length,
          itemBuilder: (context, index) {
            final release = filteredReleases[index].copyWith(isUnlocked: true);
            return ReleaseCardWidget(
              release: release,
              onTap: () async {
                HapticFeedback.lightImpact();
                await ReleasePlaybackHelper.openFromRelease(
                  context,
                  release: release,
                  albumName: 'New Release',
                  tryBackendStream: true,
                );
              },
              // TEMP: Unlock flow removed for now; always show Play button.
              // onUnlockTap: () => _showUnlockModal(release),
            );
          },
        );
      },
    );
  }
}
