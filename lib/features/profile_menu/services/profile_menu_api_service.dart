import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/utils/app_toast.dart';

/// Thin facade for every backend call surfaced from the Fan Profile menu.
///
/// All methods catch [ApiRequestException] and surface a toast so screens
/// can stay simple — they only need a bool/result and a "did it succeed"
/// branch. Errors are surfaced once here, not duplicated per screen.
class ProfileMenuApiService {
  ProfileMenuApiService({ApiRequester? requester})
      : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  // ---------------------------------------------------------------------------
  // Phone verification
  // ---------------------------------------------------------------------------

  Future<bool> startPhoneVerification(String phoneNumber) async {
    try {
      await _requester.postNoContent(
        '/api/v1/auth/phone/start',
        {'phoneNumber': phoneNumber},
        successStatus: ApiConstants.statusOk,
        alsoAcceptStatuses: const [
          ApiConstants.statusNoContent,
          ApiConstants.statusCreated,
        ],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      await AppToast.showError('Could not send verification code.');
      return false;
    }
  }

  Future<bool> confirmPhoneVerification(String code) async {
    try {
      await _requester.postNoContent(
        '/api/v1/auth/phone/confirm',
        {'code': code},
        successStatus: ApiConstants.statusOk,
        alsoAcceptStatuses: const [ApiConstants.statusNoContent],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      await AppToast.showError('Could not confirm phone code.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Transactional PIN
  // ---------------------------------------------------------------------------

  Future<bool> hasPin() async {
    try {
      final res = await _requester.getJson(
        '/api/v1/auth/pin/status',
        (json) => json,
        authenticate: true,
      );
      return res['hasPin'] == true;
    } on ApiRequestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    try {
      await _requester.postNoContent(
        '/api/v1/auth/pin',
        {'pin': pin},
        successStatus: ApiConstants.statusOk,
        alsoAcceptStatuses: const [
          ApiConstants.statusNoContent,
          ApiConstants.statusCreated,
        ],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      await _requester.postNoContent(
        '/api/v1/auth/pin/change',
        {'currentPin': currentPin, 'newPin': newPin},
        successStatus: ApiConstants.statusOk,
        alsoAcceptStatuses: const [ApiConstants.statusNoContent],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestForgotPin() async {
    try {
      await _requester.postNoContent(
        '/api/v1/auth/pin/forgot',
        const {},
        successStatus: ApiConstants.statusOk,
        alsoAcceptStatuses: const [ApiConstants.statusNoContent],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      await AppToast.showError('Could not send reset email.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Support tickets
  // ---------------------------------------------------------------------------

  Future<bool> submitSupportTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    try {
      await _requester.postNoContent(
        '/api/v1/support/tickets',
        {
          'subject': subject,
          'category': category,
          'message': message,
        },
        successStatus: ApiConstants.statusCreated,
        alsoAcceptStatuses: const [
          ApiConstants.statusOk,
          ApiConstants.statusNoContent,
        ],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      await AppToast.showError('Could not submit your ticket.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Wallet
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

  Future<List<WalletTransaction>> fetchWalletTransactions() async {
    try {
      return await _requester.getJsonList<WalletTransaction>(
        '/api/v1/wallet/transactions',
        WalletTransaction.fromJson,
        queryParameters: const {'page': 1, 'pageSize': 25},
        authenticate: true,
      );
    } on ApiRequestException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Account deactivation
  // ---------------------------------------------------------------------------

  Future<bool> deactivateAccount() async {
    try {
      await _requester.deleteNoContent(
        '/api/v1/users/me',
        successStatus: ApiConstants.statusNoContent,
        alsoAcceptStatuses: const [ApiConstants.statusOk],
        authenticate: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      return false;
    } catch (_) {
      await AppToast.showError('Could not delete your account.');
      return false;
    }
  }
}

// ===========================================================================
// Wallet models
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
      lifetimeSpent:
          (json['lifetimeSpent'] is num) ? (json['lifetimeSpent'] as num).toInt() : 0,
      lifetimeEarned:
          (json['lifetimeEarned'] is num) ? (json['lifetimeEarned'] as num).toInt() : 0,
    );
  }

  factory WalletSummary.empty() => const WalletSummary(balance: 0, tier: 'Bronze');

  final int balance;
  final String tier;
  final int lifetimeSpent;
  final int lifetimeEarned;
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
    final dir = (json['direction'] as String?)?.toLowerCase() ??
        ((amount is num && amount < 0) ? 'debit' : 'credit');
    final kindStr = (json['type'] ?? json['kind'] ?? 'other')
        .toString()
        .toLowerCase();
    final created = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ??
          (json['description'] as String?) ??
          _titleFromKind(kindStr),
      amount: amountInt,
      direction: dir == 'debit' ? WalletTxDirection.debit : WalletTxDirection.credit,
      kind: _kindFromString(kindStr),
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
    if (s.contains('topup') || s.contains('top_up') || s.contains('purchase')) {
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
