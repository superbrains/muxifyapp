import 'package:flutter/foundation.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';

/// Shared, app-wide source of truth for the fan's coin balance so the home
/// header (and anywhere else) can show the ACTUAL balance instead of a
/// hard-coded value.
///
/// Screens that already fetch a [WalletSummary] (the wallet page, the get-coins
/// screen) push it in via [setBalance] so we don't issue duplicate requests;
/// [ensureLoaded] does a one-off fetch the first time the header is shown.
class WalletBalanceProvider extends ChangeNotifier {
  WalletBalanceProvider({WalletApiService? api})
      : _api = api ?? WalletApiService();

  final WalletApiService _api;

  int _balance = 0;
  bool _loaded = false;
  bool _loading = false;

  int get balance => _balance;

  /// True once we have a real value from the backend (vs. the initial 0).
  bool get loaded => _loaded;

  /// Fetches the latest balance from the backend. Safe to call repeatedly;
  /// concurrent calls coalesce. Keeps the last known value on failure.
  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final summary = await _api.fetchWalletSummary();
      setBalance(summary.balance);
    } catch (_) {
      // Network blip — keep showing the last known balance.
    } finally {
      _loading = false;
    }
  }

  /// One-off load the first time a consumer (e.g. the header) appears, so we
  /// don't refetch on every rebuild. No-op once loaded or while loading.
  void ensureLoaded() {
    if (_loaded || _loading) return;
    refresh();
  }

  /// Updates the cached balance from a summary a screen already fetched.
  void setBalance(int balance) {
    final changed = !_loaded || balance != _balance;
    _balance = balance;
    _loaded = true;
    if (changed) notifyListeners();
  }
}
