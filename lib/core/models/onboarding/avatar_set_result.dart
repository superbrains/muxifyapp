class AvatarSetResult {
  const AvatarSetResult({required this.avatarUrl});

  final String avatarUrl;

  factory AvatarSetResult.fromJson(Map<String, dynamic> json) {
    final url = json['avatarUrl'];
    return AvatarSetResult(
      avatarUrl: url == null ? '' : url.toString().trim(),
    );
  }
}
