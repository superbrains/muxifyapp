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

  static bool _targetsMuxifyApi(String url) {
    final target = Uri.tryParse(url);
    if (target == null || !target.hasAuthority) return false;
    final apiHost = Uri.tryParse(ApiConstants.resolvedBaseUrl)?.host;
    return apiHost != null && apiHost.isNotEmpty && target.host == apiHost;
  }

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
        // Wait for the async token read to finish before constructing
        // CachedNetworkImage. The media proxy (/api/v1/media/cover/...) is
        // JWT-gated; firing during the `waiting` frame sends the request with
        // no Authorization header -> 401. Because the image cache is keyed by
        // URL (not headers), that unauthed failure is then reused even after
        // the token resolves, so the cover never loads. Mirrors the web's
        // useAuthedImageSrc, which renders nothing until the authed fetch is ready.
        if (snapshot.connectionState != ConnectionState.done) {
          return placeholder ?? const SizedBox.shrink();
        }

        final token = snapshot.data?.trim() ?? '';
        // Only attach the JWT when the image is served by the Muxify API host;
        // sending the bearer to a third-party/CDN image URL would leak it.
        final headers = (token.isEmpty || !_targetsMuxifyApi(resolvedUrl))
            ? const <String, String>{}
            : {
                ApiConstants.authorization: '${ApiConstants.bearer} $token',
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
