import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muxify/core/constants/api_constants.dart';

/// Renders a video thumbnail. Accepts:
///  * a fully-qualified URL (`http://...`, `https://...`) — fetched as network image
///  * a backend-relative API path (`/api/v1/media/...`) — resolved against the
///    API base URL and fetched as a network image
///  * a local asset path (`assets/...`) — loaded as a Flutter asset
///  * empty — falls back to [fallbackAsset]
class VideoCoverImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;

  const VideoCoverImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/pngs/release_placeholder.png',
  });

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl.trim();
    if (raw.isEmpty) return _asset(fallbackAsset);

    if (raw.startsWith('assets/')) return _asset(raw);

    final url = (raw.startsWith('http://') || raw.startsWith('https://'))
        ? raw
        : ApiConstants.resolvePublicUrl(raw);

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => _asset(fallbackAsset),
      errorWidget: (_, __, ___) => _asset(fallbackAsset),
    );
  }

  Widget _asset(String path) =>
      Image.asset(path, width: width, height: height, fit: fit);
}
