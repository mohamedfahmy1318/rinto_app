/// Single catalog of every REST path the app uses, grouped by backend
/// section. Data sources reference these constants (and methods for
/// parameterized paths) instead of raw string literals.
///
/// Paths are RELATIVE to [NetworkConfig.baseUrl] (no leading `/`),
/// except the two IAP verify endpoints which keep their legacy
/// absolute form for backend-coordination reasons.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // region auth
  static const String authRegister = 'auth/register';
  static const String authLogin = 'auth/login';
  static const String authForgotPassword = 'auth/forgot-password';
  static const String authVerifyPhone = 'auth/verify-phone';
  static const String authResendOtp = 'auth/resend-otp';
  static const String authResetPassword = 'auth/reset-password';
  static const String authDeleteAccount = 'auth/delete-account';
  static const String me = 'me';
  // endregion

  // region users
  static const String usersUpdate = 'users/update';
  static const String usersUpdateProfile = 'users/update-profile';
  static const String usersChangePassword = 'users/change-password';
  static const String usersChangeEmail = 'users/change-email';
  static const String usersChangePhone = 'users/change-phone';
  static const String usersMyListings = 'users/my-listings';
  static const String usersFcmToken = 'users/fcm-token';
  // endregion

  // region listings
  static const String listings = 'listings';
  static const String properties = 'properties';
  static const String cars = 'cars';
  static const String types = 'types';

  /// `type` is typically `'listings'`, `'properties'`, or `'cars'`.
  static String listingById(String type, int id) => '$type/$id';

  static String listingToggleRented(int id) => 'listings/$id/toggle-rented';

  static String listingRepublish(int id) => 'listings/$id/republish';
  // endregion

  // region favorites
  static const String favorites = 'favorites';

  /// `type` is the listing type qualifier (e.g. `'property'`, `'car'`).
  static String favoriteDelete(int id, String type) =>
      'favorites/$id?type=$type';
  // endregion

  // region chat
  static const String chatConversations = 'chat/conversations';
  static const String chatConversation = 'chat/conversation';
  static const String chatSend = 'chat/send';
  static const String chatUnread = 'chat/unread';

  static String chatConversationPage(int conversationId, int page) =>
      'chat/conversation/$conversationId?page=$page';
  // endregion

  // region checkout / subscriptions
  static const String plans = 'plans';
  static const String subscriptionsPurchase = 'subscriptions/purchase';

  /// Legacy absolute path preserved 1:1 from google_iap_service.dart.
  static const String subscriptionsVerifyGoogle =
      '/subscriptions/verify-google-purchase';

  /// Legacy absolute path preserved 1:1 from apple_iap_service.dart.
  static const String subscriptionsVerifyApple =
      '/subscriptions/verify-apple-purchase';

  static const String subscriptionsWarnings = 'subscriptions/warnings';
  // endregion

  // region regions / cities
  static const String regions = 'regions';
  static const String cities = 'cities';

  static String regionCities(int regionId) => 'regions/$regionId/cities';
  // endregion

  // region notifications
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String notificationsAllRead = 'notifications/all/read';

  static String notificationRead(int id) => 'notifications/$id/read';
  // endregion

  // region banners
  static const String banners = 'banners';
  // endregion

  // region uploads / misc
  static const String uploadsImage = 'uploads/image';
  static const String reports = 'reports';
  // endregion
}
