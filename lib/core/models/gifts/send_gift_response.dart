class SendGiftResponse {
  final bool success;
  final String giftId;
  final int coinsSpent;
  final int newBalance;
  final String? message;

  SendGiftResponse({
    required this.success,
    required this.giftId,
    required this.coinsSpent,
    required this.newBalance,
    this.message,
  });

  factory SendGiftResponse.fromJson(Map<String, dynamic> json) {
    return SendGiftResponse(
      success: json['success'] as bool? ?? false,
      giftId: (json['giftId'] as String?) ?? '',
      coinsSpent: (json['coinsSpent'] as num?)?.toInt() ?? 0,
      newBalance: (json['newBalance'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );
  }
}
