import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/services/local_storage_service.dart';

/// Loads an image that may be served by the Muxify API's authenticated proxy
/// (e.g. `/api/v1/media/cover/...`). Attaches `Authorization: Bearer <jwt>`
/// only when the resolved URL targets the Muxify API host. Public CDN URLs and
/// asset paths bypass this widget — pass them through `Image.network` /
/// `Image.asset` directly at the call site.
class AuthNetworkImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AuthNetworkImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    final resolvedUrl = ApiConstants.resolvePublicUrl(trimmed);

    return FutureBuilder<String?>(
      future: LocalStorageService.getAccessToken(),
      builder: (context, snapshot) {
        final token = snapshot.data?.trim() ?? '';
        final headers = token.isEmpty
            ? const <String, String>{}
            : {
                ApiConstants.authorization:
                    '${ApiConstants.bearer} $token',
              };

        return CachedNetworkImage(
          imageUrl: resolvedUrl,
          fit: fit,
          width: width,
          height: height,
          alignment: alignment,
          httpHeaders: headers,
          placeholder: placeholder == null
              ? null
              : (context, _) => placeholder!,
          errorWidget: (context, _, __) =>
              errorWidget ?? placeholder ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
