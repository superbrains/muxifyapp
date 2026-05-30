import 'package:flutter/material.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Renders the signed-in user's avatar from a remote URL or API proxy path.
///
/// Falls back to the brand placeholder asset when [avatar] is null, empty,
/// or fails to load.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.avatar,
    required this.size,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/pngs/profile_placeholder.png',
  });

  final String? avatar;
  final double size;
  final BoxFit fit;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final url = avatar?.trim();
    final placeholder = Image.asset(
      fallbackAsset,
      width: size,
      height: size,
      fit: fit,
    );

    if (url == null || url.isEmpty) {
      return ClipOval(child: placeholder);
    }

    // Avatars are usually served by the JWT-gated media proxy
    // (`/api/v1/media/cover/avatars/...`). AuthNetworkImage resolves the path,
    // attaches the bearer for Muxify-hosted URLs, and passes public URLs through.
    return ClipOval(
      child: AuthNetworkImage(
        path: url,
        width: size,
        height: size,
        fit: fit,
        placeholder: placeholder,
        errorWidget: placeholder,
      ),
    );
  }
}
