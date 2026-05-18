import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';

// Re-export wallet types so existing imports of
// `package:muxify/features/profile_menu/services/profile_menu_api_service.dart`
// keep working after the wallet logic was extracted to its own service.
export 'package:muxify/features/wallet/services/wallet_api_service.dart'
    show WalletSummary, WalletTransaction, WalletTxDirection, WalletTxKind;

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
  // Wallet — thin delegates to [WalletApiService]. Kept here so existing
  // callers (wallet_payment_screen) need not be re-wired during this slice.
  // ---------------------------------------------------------------------------

  Future<WalletSummary> fetchWalletSummary() =>
      _wallet.fetchWalletSummary();

  Future<List<WalletTransaction>> fetchWalletTransactions() =>
      _wallet.fetchWalletTransactions();

  late final WalletApiService _wallet = WalletApiService(requester: _requester);

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

// Wallet model types live in WalletApiService now and are re-exported above.
