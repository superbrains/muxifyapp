import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:uuid/uuid.dart';

/// One service for every wallet + coin-purchase backend call.
///
/// Kept separate from `ProfileMenuApiService` so the wallet + Brij payment
/// flow can grow without bloating the profile-menu facade. All API errors are
/// surfaced via [ApiRequestException]; screens decide whether to toast vs.
/// render an inline retry card.
class WalletApiService {
  WalletApiService({ApiRequester? requester, Uuid? uuid})
      : _requester = requester ?? ApiRequester(),
        _uuid = uuid ?? const Uuid();

  final ApiRequester _requester;
  final Uuid _uuid;

  // ---------------------------------------------------------------------------
  // Wallet (balance + rate + transactions)
  // ---------------------------------------------------------------------------

  Future<WalletSummary> fetchWalletSummary() async {
    try {
      return await _requester.getJson<WalletSummary>(
        '/api/v1/wallet/balance',
        WalletSummary.fromJson,
        authenticate: true,
      );
    } on ApiRequestException {
      return WalletSummary.empty();
    } catch (_) {
      return WalletSummary.empty();
    }
  }

  Future<CoinRate> fetchCoinRate() async {
    try {
      return await _requester.getJson<CoinRate>(
        '/api/v1/wallet/rate',
        CoinRate.fromJson,
        authenticate: true,
      );
    } catch (_) {
      return CoinRate.fallback();
    }
  }

  /// Transactions are returned by the backend wrapped in a
  /// `{ transactions: [...], totalCount, page, pageSize }` envelope.
  Future<List<WalletTransaction>> fetchWalletTransactions({
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      final history = await _requester.getJson<_TransactionHistoryEnvelope>(
        '/api/v1/wallet/transactions',
        _TransactionHistoryEnvelope.fromJson,
        queryParameters: {'page': page, 'pageSize': pageSize},
        authenticate: true,
      );
      return history.transactions;
    } on ApiRequestException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Coin packages
  // ---------------------------------------------------------------------------

  Future<List<CoinPackageDto>> fetchCoinPackages() async {
    return _requester.getJsonList<CoinPackageDto>(
      '/api/v1/wallet/packages',
      CoinPackageDto.fromJson,
      authenticate: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Brij payment collection flow
  // ---------------------------------------------------------------------------

  Future<List<CollectionMethod>> fetchPaymentMethods({
    String currency = 'NGN',
  }) async {
    final envelope = await fetchPaymentMethodsEnvelope(currency: currency);
    return envelope.methods;
  }

  /// Returns the full methods envelope including the active provider name —
  /// used to render the "Secured by …" label dynamically without hard-coding
  /// the gateway in the UI.
  Future<PaymentMethodsEnvelope> fetchPaymentMethodsEnvelope({
    String currency = 'NGN',
  }) async {
    final envelope = await _requester.getJson<_CollectionMethodsEnvelope>(
      '/api/v1/payments/collections/methods',
      _CollectionMethodsEnvelope.fromJson,
      queryParameters: {'currency': currency},
      authenticate: true,
    );
    return PaymentMethodsEnvelope(
      currency: envelope.currency,
      providerName: envelope.providerName,
      methods: envelope.methods,
    );
  }

  Future<SendOtpResult> sendPaymentOtp({required String customerContact}) async {
    return _requester.postJson<SendOtpResult>(
      '/api/v1/payments/collections/send-otp',
      {'customerContact': customerContact},
      SendOtpResult.fromJson,
      successStatus: ApiConstants.statusOk,
      authenticate: true,
    );
  }

  Future<InitiateCollectionResult> initiateCollection({
    required String packageId,
    required String paymentMethodId,
    required String customerContact,
    String? customerName,
    String? customerEmail,
    String? redirectUrl,
    Map<String, dynamic>? paymentDetails,
    String? idempotencyKey,
  }) async {
    final body = <String, dynamic>{
      'packageId': packageId,
      'paymentMethodId': paymentMethodId,
      'customerContact': customerContact,
      if (customerName != null) 'customerName': customerName,
      if (customerEmail != null) 'customerEmail': customerEmail,
      if (redirectUrl != null) 'redirectUrl': redirectUrl,
      if (paymentDetails != null) 'paymentDetails': paymentDetails,
    };
    return _requester.postJson<InitiateCollectionResult>(
      '/api/v1/payments/collections/initiate',
      body,
      InitiateCollectionResult.fromJson,
      successStatus: ApiConstants.statusOk,
      authenticate: true,
      extraHeaders: {
        'Idempotency-Key': idempotencyKey ?? _uuid.v4(),
      },
    );
  }

  Future<CollectionStatus> fetchCollectionStatus(String intentId) async {
    return _requester.getJson<CollectionStatus>(
      '/api/v1/payments/collections/$intentId',
      CollectionStatus.fromJson,
      authenticate: true,
    );
  }
}

// ===========================================================================
// Wallet + rate models
// ===========================================================================

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.tier,
    this.lifetimeSpent = 0,
    this.lifetimeEarned = 0,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    final balance = json['balance'] ?? json['coins'] ?? json['amount'] ?? 0;
    return WalletSummary(
      balance: (balance is num) ? balance.toInt() : 0,
      tier: (json['tier'] as String?) ?? 'Bronze',
      lifetimeSpent: (json['totalSpent'] is num)
          ? (json['totalSpent'] as num).toInt()
          : (json['lifetimeSpent'] is num)
              ? (json['lifetimeSpent'] as num).toInt()
              : 0,
      lifetimeEarned: (json['totalReceived'] is num)
          ? (json['totalReceived'] as num).toInt()
          : (json['lifetimeEarned'] is num)
              ? (json['lifetimeEarned'] as num).toInt()
              : 0,
    );
  }

  factory WalletSummary.empty() => const WalletSummary(balance: 0, tier: 'Bronze');

  final int balance;
  final String tier;
  final int lifetimeSpent;
  final int lifetimeEarned;
}

class CoinRate {
  const CoinRate({required this.coinsPerNairaMajor, required this.currency});

  factory CoinRate.fromJson(Map<String, dynamic> json) => CoinRate(
        coinsPerNairaMajor: (json['coinsPerNairaMajor'] is num)
            ? (json['coinsPerNairaMajor'] as num).toInt()
            : 50,
        currency: (json['currency'] as String?) ?? 'NGN',
      );

  factory CoinRate.fallback() =>
      const CoinRate(coinsPerNairaMajor: 10, currency: 'NGN');

  final int coinsPerNairaMajor;
  final String currency;

  /// Naira (major unit) value of [coins] at the current rate. Mirrors the
  /// integer division the wallet screen uses so every screen converts the same
  /// way (see [WalletApiService.fetchCoinRate]).
  int nairaFor(int coins) =>
      coinsPerNairaMajor <= 0 ? 0 : coins ~/ coinsPerNairaMajor;

  /// Secondary line shown under a coin amount, e.g. "≈ ₦1,234 value".
  String nairaLabel(int coins) => '≈ ₦${groupThousands(nairaFor(coins))} value';

  /// Inserts thousands separators (e.g. `100250` → `100,250`). Shared so coin
  /// and Naira figures across the unlock/gift screens render identically.
  static String groupThousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }
}

enum WalletTxDirection { credit, debit }

enum WalletTxKind { topUp, gift, unlock, refund, other }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.direction,
    required this.kind,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    final amountInt = (amount is num) ? amount.toInt().abs() : 0;
    // Backend uses `isCredit: bool` + `type: enum-name`. Falls back to
    // direction string for any legacy callers.
    final isCredit = json['isCredit'] is bool
        ? json['isCredit'] as bool
        : ((json['direction'] as String?)?.toLowerCase() != 'debit') &&
            !(amount is num && amount < 0);
    final dir = isCredit ? WalletTxDirection.credit : WalletTxDirection.debit;
    final typeStr =
        (json['type'] ?? json['kind'] ?? 'other').toString().toLowerCase();
    final created = DateTime.tryParse(
            json['transactionDate']?.toString() ?? json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      title: (json['description'] as String?) ??
          (json['title'] as String?) ??
          _titleFromKind(typeStr),
      amount: amountInt,
      direction: dir,
      kind: _kindFromString(typeStr),
      createdAt: created,
    );
  }

  final String id;
  final String title;
  final int amount;
  final WalletTxDirection direction;
  final WalletTxKind kind;
  final DateTime createdAt;

  static WalletTxKind _kindFromString(String s) {
    if (s.contains('purchase') || s.contains('topup') || s.contains('top_up')) {
      return WalletTxKind.topUp;
    }
    if (s.contains('gift')) return WalletTxKind.gift;
    if (s.contains('unlock')) return WalletTxKind.unlock;
    if (s.contains('refund')) return WalletTxKind.refund;
    return WalletTxKind.other;
  }

  static String _titleFromKind(String s) {
    final k = _kindFromString(s);
    return switch (k) {
      WalletTxKind.topUp => 'Coin top-up',
      WalletTxKind.gift => 'Gift sent',
      WalletTxKind.unlock => 'Content unlock',
      WalletTxKind.refund => 'Refund',
      WalletTxKind.other => 'Wallet activity',
    };
  }
}

class _TransactionHistoryEnvelope {
  const _TransactionHistoryEnvelope(this.transactions);
  factory _TransactionHistoryEnvelope.fromJson(Map<String, dynamic> json) {
    final list = json['transactions'];
    if (list is! List) return const _TransactionHistoryEnvelope(<WalletTransaction>[]);
    return _TransactionHistoryEnvelope(
      list
          .whereType<Map>()
          .map((m) => WalletTransaction.fromJson(Map<String, dynamic>.from(m)))
          .toList(growable: false),
    );
  }
  final List<WalletTransaction> transactions;
}

// ===========================================================================
// Coin package model
// ===========================================================================

class CoinPackageDto {
  const CoinPackageDto({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.bonusCoins,
    required this.totalCoins,
    required this.priceInSmallestUnit,
    required this.currency,
    required this.priceDisplay,
    this.description,
    this.isFeatured = false,
    this.badgeIcon,
    this.promoTag,
  });

  factory CoinPackageDto.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => (v is num) ? v.toInt() : 0;
    return CoinPackageDto(
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      coinAmount: asInt(json['coinAmount']),
      bonusCoins: asInt(json['bonusCoins']),
      totalCoins: asInt(json['totalCoins']) == 0
          ? asInt(json['coinAmount']) + asInt(json['bonusCoins'])
          : asInt(json['totalCoins']),
      priceInSmallestUnit: asInt(json['priceInSmallestUnit']),
      currency: (json['currency'] as String?) ?? 'NGN',
      priceDisplay: (json['priceDisplay'] is num)
          ? (json['priceDisplay'] as num).toDouble()
          : asInt(json['priceInSmallestUnit']) / 100.0,
      isFeatured: json['isFeatured'] == true,
      badgeIcon: json['badgeIcon'] as String?,
      promoTag: json['promoTag'] as String?,
    );
  }

  final String id;
  final String name;
  final String? description;
  final int coinAmount;
  final int bonusCoins;
  final int totalCoins;
  final int priceInSmallestUnit;
  final String currency;
  final double priceDisplay;
  final bool isFeatured;
  final String? badgeIcon;
  final String? promoTag;

  String get coinAmountDisplay => totalCoins.toString();
  String get priceDisplayText => priceDisplay.toStringAsFixed(0);
}

// ===========================================================================
// Brij payment-method model
// ===========================================================================

class CollectionMethod {
  const CollectionMethod({
    required this.id,
    required this.name,
    required this.fundType,
    required this.requiresOtp,
  });

  factory CollectionMethod.fromJson(Map<String, dynamic> json) =>
      CollectionMethod(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        fundType: (json['fundType'] as String?) ?? '',
        requiresOtp: json['requiresOtp'] == true,
      );

  final String id;
  final String name;
  final String fundType;
  final bool requiresOtp;
}

class _CollectionMethodsEnvelope {
  const _CollectionMethodsEnvelope({
    required this.currency,
    required this.providerName,
    required this.methods,
  });
  factory _CollectionMethodsEnvelope.fromJson(Map<String, dynamic> json) {
    final raw = json['methods'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((m) => CollectionMethod.fromJson(Map<String, dynamic>.from(m)))
            .toList(growable: false)
        : const <CollectionMethod>[];
    return _CollectionMethodsEnvelope(
      currency: (json['currency'] as String?) ?? 'NGN',
      providerName: (json['providerName'] as String?) ?? '',
      methods: list,
    );
  }
  final String currency;
  final String providerName;
  final List<CollectionMethod> methods;
}

/// Public-facing envelope returned by [WalletApiService.fetchPaymentMethodsEnvelope].
/// Carries the active gateway name so the UI can render a dynamic
/// "Secured by …" label instead of hard-coding the provider.
class PaymentMethodsEnvelope {
  const PaymentMethodsEnvelope({
    required this.currency,
    required this.providerName,
    required this.methods,
  });

  final String currency;
  final String providerName;
  final List<CollectionMethod> methods;
}

class SendOtpResult {
  const SendOtpResult({required this.status, this.message});
  factory SendOtpResult.fromJson(Map<String, dynamic> json) => SendOtpResult(
        status: (json['status'] as String?) ?? '',
        message: json['message'] as String?,
      );
  final String status;
  final String? message;
}

class InitiateCollectionResult {
  const InitiateCollectionResult({
    required this.intentId,
    required this.purchaseId,
    required this.status,
    this.externalReference,
    this.expiresAt,
    this.channelMetadata,
  });

  factory InitiateCollectionResult.fromJson(Map<String, dynamic> json) =>
      InitiateCollectionResult(
        intentId: (json['intentId'] as String?) ?? '',
        purchaseId: (json['purchaseId'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        externalReference: json['externalReference'] as String?,
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        channelMetadata: json['channelMetadata'] is Map
            ? Map<String, dynamic>.from(json['channelMetadata'] as Map)
            : null,
      );

  final String intentId;
  final String purchaseId;
  final String status;
  final String? externalReference;
  final DateTime? expiresAt;
  final Map<String, dynamic>? channelMetadata;
}

class CollectionStatus {
  const CollectionStatus({
    required this.intentId,
    required this.status,
    required this.amountMinor,
    required this.currency,
    this.externalReference,
    this.expiresAt,
    this.settledAt,
    this.failureReason,
    this.channelMetadata,
    this.coinsAmount,
  });

  factory CollectionStatus.fromJson(Map<String, dynamic> json) =>
      CollectionStatus(
        intentId: (json['intentId'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        amountMinor:
            (json['amountMinor'] is num) ? (json['amountMinor'] as num).toInt() : 0,
        currency: (json['currency'] as String?) ?? 'NGN',
        externalReference: json['externalReference'] as String?,
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        settledAt: DateTime.tryParse(json['settledAt']?.toString() ?? ''),
        failureReason: json['failureReason'] as String?,
        channelMetadata: json['channelMetadata'] is Map
            ? Map<String, dynamic>.from(json['channelMetadata'] as Map)
            : null,
        coinsAmount: (json['coinsAmount'] is num)
            ? (json['coinsAmount'] as num).toInt()
            : null,
      );

  final String intentId;
  final String status;
  final int amountMinor;
  final String currency;
  final String? externalReference;
  final DateTime? expiresAt;
  final DateTime? settledAt;
  final String? failureReason;
  final Map<String, dynamic>? channelMetadata;
  final int? coinsAmount;

  /// Status enum mirrors backend's PaymentIntentStatus.
  bool get isTerminal =>
      status == 'Succeeded' ||
      status == 'Failed' ||
      status == 'Expired' ||
      status == 'Cancelled';

  bool get isSucceeded => status == 'Succeeded';
  bool get isFailed => status == 'Failed' || status == 'Cancelled';
  bool get isExpired => status == 'Expired';
}
