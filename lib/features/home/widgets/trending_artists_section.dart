import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/trending_artist_card.dart';

class TrendingArtistsSection extends StatelessWidget {
  final List<TrendingArtist> artists;
  final VoidCallback? onTap;
  final String title;
  final bool showLeadingIcon;
  final String? mediaType;

  const TrendingArtistsSection({
    super.key,
    required this.artists,
    required this.title,
    this.showLeadingIcon = true,
    this.onTap,
    this.mediaType,
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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            separatorBuilder: (context, index) => 14.row,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return TrendingArtistCard(
                artist: artist,
                onTap: () {
                  onTap?.call();
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
