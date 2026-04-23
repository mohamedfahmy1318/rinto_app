import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Sync-accessible active-locale cache consumed by the
/// [LanguageInterceptor].
///
/// Mirrors [TokenReader]'s pattern: populated at boot via
/// [refreshFromStorage], updated by the legacy [AppProvider] via
/// [setLanguageCode] until the settings feature is migrated.
///
/// Only `ar`, `he`, `en` are accepted; anything else falls back to
/// the default `ar`.
abstract class LocaleReader {
  String get currentLanguageCode;

  Future<void> refreshFromStorage();

  void setLanguageCode(String code);
}

class SharedPreferencesLocaleReader implements LocaleReader {
  static const String _defaultLanguageCode = 'ar';
  static const Set<String> _supported = <String>{'ar', 'he', 'en'};

  String _cached = _defaultLanguageCode;

  @override
  String get currentLanguageCode => _cached;

  @override
  Future<void> refreshFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(StorageKeys.language);
    _cached = _normalize(stored);
  }

  @override
  void setLanguageCode(String code) {
    _cached = _normalize(code);
    _persist(_cached);
  }

  String _normalize(String? code) {
    if (code == null || !_supported.contains(code)) {
      return _defaultLanguageCode;
    }
    return code;
  }

  Future<void> _persist(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.language, code);
  }
}
