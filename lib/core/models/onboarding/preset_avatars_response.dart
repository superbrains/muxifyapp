/// Raw JSON uses relative paths; callers typically map to absolute URLs for network images.
class PresetAvatarsResponse {
  const PresetAvatarsResponse({
    required this.male,
    required this.female,
  });

  final List<String> male;
  final List<String> female;

  factory PresetAvatarsResponse.fromJson(Map<String, dynamic> json) {
    return PresetAvatarsResponse(
      male: _stringList(json['male']),
      female: _stringList(json['female']),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}
