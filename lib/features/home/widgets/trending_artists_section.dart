import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/trending_artist_card.dart';
import 'package:shimmer/shimmer.dart';

class TrendingArtistsSection extends StatelessWidget {
  final List<TrendingArtist> artists;
  final ValueChanged<TrendingArtist>? onArtistTap;
  final String title;
  final bool showLeadingIcon;
  final String? mediaType;
  final bool isLoading;

  const TrendingArtistsSection({
    super.key,
    required this.artists,
    required this.title,
    this.showLeadingIcon = true,
    this.onArtistTap,
    this.mediaType,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          leadingIcon: showLeadingIcon
              ? Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.text,
                  size: 24.icon,
                )
              : null,
        ),
        16.column,
        SizedBox(
          height: 100.buttonHeight,
          child: isLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  separatorBuilder: (context, index) => 14.row,
                  itemBuilder: (context, index) => const _TrendingArtistShimmerCard(),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: artists.length,
                  separatorBuilder: (context, index) => 14.row,
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    return TrendingArtistCard(
                      artist: artist,
                      onTap: () {
                        if (onArtistTap != null) {
                          onArtistTap!(artist);
                        }
                      },
                      mediaType: mediaType,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TrendingArtistShimmerCard extends StatelessWidget {
  const _TrendingArtistShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3A3A3A),
      child: SizedBox(
        width: 64.buttonHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.buttonHeight,
              height: 64.buttonHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            8.column,
            Container(
              width: 52.maxWidth,
              height: 12.buttonHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.radius),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
