import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders a video thumbnail that may be either a local asset path
/// (e.g. `assets/pngs/release_placeholder.png`) or a fully-qualified
/// network URL — VideoItem.fromFeedVideo emits HTTP URLs from the backend
/// and asset paths only as a fallback when the backend has no thumbnail.
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
    final url = imageUrl.trim();
    if (url.isEmpty) return _asset(fallbackAsset);

    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    if (!isNetwork) return _asset(url);

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
