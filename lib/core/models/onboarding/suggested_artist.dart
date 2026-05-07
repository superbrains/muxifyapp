import 'package:muxify/core/constants/api_constants.dart';

class SuggestedArtist {
  const SuggestedArtist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final bool isVerified;

  factory SuggestedArtist.fromJson(Map<String, dynamic> json) {
    return SuggestedArtist(
      id: json['id']?.toString() ?? '',
      name: json['name'] == null ? '' : json['name'].toString().trim(),
      imageUrl: switch (json['imageUrl']) {
        final String s => s.trim().isEmpty ? null : s.trim(),
        _ => null,
      },
      isVerified: json['isVerified'] == true,
    );
  }

  /// Absolute URL for network images; empty when there is no image — use fallback UI.
  String get resolvedImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    return ApiConstants.resolvePublicUrl(imageUrl!);
  }
}
