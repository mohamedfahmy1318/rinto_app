import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Sync-accessible session token cache consumed by the [AuthInterceptor].
///
/// Reads live in-memory; the backing store is refreshed once at app
/// boot via [refreshFromStorage]. The legacy [AuthProvider] pushes
/// login/logout state through [setToken] until the auth feature is
/// migrated to a Cubit.
///
/// Empty strings are treated as absent (no header attached).
abstract class TokenReader {
  String? get currentToken;

  Future<void> refreshFromStorage();

  void setToken(String? token);

  void clear();
}

class SharedPreferencesTokenReader implements TokenReader {
  String? _cached;

  @override
  String? get currentToken {
    final value = _cached;
    if (value == null || value.isEmpty) return null;
    return value;
  }

  @override
  Future<void> refreshFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _cached = prefs.getString(StorageKeys.token);
  }

  @override
  void setToken(String? token) {
    _cached = token;
    _persist(token);
  }

  @override
  void clear() => setToken(null);

  Future<void> _persist(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(StorageKeys.token);
    } else {
      await prefs.setString(StorageKeys.token, token);
    }
  }
}
