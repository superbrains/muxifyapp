import 'package:muxify/features/home/models/trending_artist.dart';

/// Pass via `context.push(route, extra: ...)` so the profile receives full discovery data.
class ArtistProfileRouteArgs {
  const ArtistProfileRouteArgs({
    required this.artist,
    this.mediaType,
  });

  final TrendingArtist artist;
  final String? mediaType;
}
