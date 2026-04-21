import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ar');
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get languageCode => _locale.languageCode;
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeString = prefs.getString(StorageKeys.themeMode);
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    // Check if user has manually set a language before
    final savedLang = prefs.getString(StorageKeys.language);

    String langCode;
    if (savedLang != null) {
      // User has set language before, use saved preference
      langCode = savedLang;
    } else {
      // First time - detect device language
      // If device language is Hebrew, use Hebrew; otherwise use Arabic
      final deviceLocale = ui.PlatformDispatcher.instance.locale;
      langCode = deviceLocale.languageCode == 'he' ? 'he' : 'ar';
      // Save the detected language
      await prefs.setString(StorageKeys.language, langCode);
    }

    // Only allow Arabic, Hebrew and English
    if (langCode != 'ar' && langCode != 'he' && langCode != 'en') {
      langCode = 'ar';
    }
    _locale = Locale(langCode);

    // Load notifications setting
    _notificationsEnabled =
        prefs.getBool(StorageKeys.notificationsEnabled) ?? true;

    _isInitialized = true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.themeMode,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.language, locale.languageCode);
    notifyListeners();

    // Sync language to server for push notifications
    _syncLanguageToServer(locale.languageCode);
  }

  Future<void> _syncLanguageToServer(String langCode) async {
    try {
      await ApiService.put(
        'users/update',
        body: {'preferred_language': langCode},
      );
    } catch (_) {
      // Ignore errors - user might not be logged in
    }
  }

  Future<void> setLanguage(String langCode) async {
    await setLocale(Locale(langCode));
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.notificationsEnabled, enabled);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!_notificationsEnabled);
  }
}
