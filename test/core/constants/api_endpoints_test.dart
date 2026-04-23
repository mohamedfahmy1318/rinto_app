import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('every fixed-path constant is non-empty', () {
      // Representative sample per backend section. Adding new constants
      // should add a line here so the smoke test stays meaningful.
      final constants = <String>[
        ApiEndpoints.authRegister,
        ApiEndpoints.authLogin,
        ApiEndpoints.authForgotPassword,
        ApiEndpoints.authDeleteAccount,
        ApiEndpoints.me,
        ApiEndpoints.usersUpdate,
        ApiEndpoints.usersUpdateProfile,
        ApiEndpoints.usersChangePassword,
        ApiEndpoints.usersChangeEmail,
        ApiEndpoints.usersChangePhone,
        ApiEndpoints.usersMyListings,
        ApiEndpoints.usersFcmToken,
        ApiEndpoints.listings,
        ApiEndpoints.properties,
        ApiEndpoints.cars,
        ApiEndpoints.types,
        ApiEndpoints.favorites,
        ApiEndpoints.chatConversations,
        ApiEndpoints.chatConversation,
        ApiEndpoints.chatSend,
        ApiEndpoints.chatUnread,
        ApiEndpoints.plans,
        ApiEndpoints.subscriptionsPurchase,
        ApiEndpoints.subscriptionsVerifyGoogle,
        ApiEndpoints.subscriptionsVerifyApple,
        ApiEndpoints.subscriptionsWarnings,
        ApiEndpoints.regions,
        ApiEndpoints.cities,
        ApiEndpoints.notifications,
        ApiEndpoints.notificationsUnreadCount,
        ApiEndpoints.notificationsAllRead,
        ApiEndpoints.banners,
        ApiEndpoints.uploadsImage,
        ApiEndpoints.reports,
      ];

      for (final path in constants) {
        expect(path, isNotEmpty);
      }
    });

    test('parameterized methods return non-empty strings with sensible inputs',
        () {
      expect(ApiEndpoints.listingById('listings', 42), 'listings/42');
      expect(ApiEndpoints.listingToggleRented(42), 'listings/42/toggle-rented');
      expect(ApiEndpoints.listingRepublish(42), 'listings/42/republish');
      expect(
        ApiEndpoints.favoriteDelete(42, 'property'),
        'favorites/42?type=property',
      );
      expect(
        ApiEndpoints.chatConversationPage(7, 2),
        'chat/conversation/7?page=2',
      );
      expect(ApiEndpoints.regionCities(3), 'regions/3/cities');
      expect(ApiEndpoints.notificationRead(99), 'notifications/99/read');
    });

    test('relative paths do not start with "/"', () {
      final relativePaths = <String>[
        ApiEndpoints.authLogin,
        ApiEndpoints.listings,
        ApiEndpoints.favorites,
        ApiEndpoints.chatConversations,
        ApiEndpoints.regions,
        ApiEndpoints.notifications,
      ];
      for (final path in relativePaths) {
        expect(path.startsWith('/'), isFalse,
            reason: '$path must be relative (no leading slash)');
      }
    });

    test('legacy absolute IAP paths keep their leading "/"', () {
      expect(ApiEndpoints.subscriptionsVerifyGoogle.startsWith('/'), isTrue);
      expect(ApiEndpoints.subscriptionsVerifyApple.startsWith('/'), isTrue);
    });
  });
}
