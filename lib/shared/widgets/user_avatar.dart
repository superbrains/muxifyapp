import 'package:flutter/material.dart';

/// Renders the signed-in user's avatar from a remote URL.
///
/// Falls back to the brand placeholder asset when [avatar] is null, empty,
/// not an http(s) URL, or fails to load.
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

    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: size,
              height: size,
              child: placeholder,
            );
          },
        ),
      );
    }

    return ClipOval(child: placeholder);
  }
}
