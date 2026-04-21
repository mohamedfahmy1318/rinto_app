class AppConstants {
  static const String appName = 'Rento Go';
  static const String appVersion = '1.0.0';

  // ========== API Configuration ==========
  // Production (rento-go.com):
  static const String baseUrl = 'https://rento-go.com/backend/api';
  static const String uploadUrl = 'https://rento-go.com/uploads/';

  // For Local Development (Android Emulator - uncomment):
  // static const String baseUrl = 'http://10.0.2.2/rento_go/backend/api';
  // static const String uploadUrl = 'http://10.0.2.2/rento_go/uploads/';

  // Limits
  static const int maxImages = 5;
  static const int maxVideos = 1;
  static const int maxBioLength = 500;

  // Pagination
  static const int pageSize = 20;

  // Currency
  static const String defaultCurrency = 'ILS';
  static const String currencySymbol = '₪';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'user_data';
  static const String language = 'app_language';
  static const String themeMode = 'theme_mode';
  static const String onboardingComplete = 'onboarding_complete';
  static const String notificationsEnabled = 'notifications_enabled';
}
