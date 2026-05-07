class CheckUsernameResponse {
  const CheckUsernameResponse({
    required this.available,
    required this.suggestions,
  });

  final bool available;
  final List<String> suggestions;

  factory CheckUsernameResponse.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'];
    return CheckUsernameResponse(
      available: json['available'] as bool? ?? false,
      suggestions: rawSuggestions is List
          ? rawSuggestions.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}
