# Contract: `ApiEndpoints`

**File**: `lib/core/constants/api_endpoints.dart`
**Consumed by**: every data source under `lib/data/datasources/**`.
**Status**: stable shape — individual entries are additive-only until
renamed intentionally.

---

## 1. Shape

```dart
// lib/core/constants/api_endpoints.dart

abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ───────── auth ─────────
  static const String authRegister       = 'auth/register';
  static const String authLogin          = 'auth/login';
  static const String authDeleteAccount  = 'auth/delete-account';
  static const String me                 = 'me';

  // ───────── users ─────────
  static const String usersUpdate        = 'users/update';
  static const String usersUpdateProfile = 'users/update-profile';
  static const String usersChangePassword = 'users/change-password';
  static const String usersChangeEmail   = 'users/change-email';
  static const String usersChangePhone   = 'users/change-phone';
  static const String usersMyListings    = 'users/my-listings';

  // ───────── listings ─────────
  static const String listings           = 'listings';
  static const String properties         = 'properties';
  static const String cars               = 'cars';
  static const String types              = 'types';
  static String listingById(String type, int id)  => '$type/$id';
  static String listingToggleRented(int id)       => 'listings/$id/toggle-rented';
  static String listingRepublish(int id)          => 'listings/$id/republish';

  // ───────── favorites ─────────
  static const String favorites          = 'favorites';
  static String favoriteDelete(int id, String type) => 'favorites/$id?type=$type';

  // ───────── chat ─────────
  static const String chatConversations  = 'chat/conversations';
  static const String chatConversation   = 'chat/conversation';
  static const String chatSend           = 'chat/send';
  static const String chatUnread         = 'chat/unread';
  static String chatConversationPage(int conversationId, int page) =>
      'chat/conversation/$conversationId?page=$page';

  // ───────── checkout / subscriptions ─────────
  static const String plans                        = 'plans';
  static const String subscriptionsPurchase        = 'subscriptions/purchase';
  static const String subscriptionsVerifyApple     = '/subscriptions/verify-apple-purchase';
  static const String subscriptionsVerifyGoogle    = '/subscriptions/verify-google-purchase';
  static const String subscriptionsWarnings        = 'subscriptions/warnings';

  // ───────── regions / cities ─────────
  static const String regions            = 'regions';
  static const String cities             = 'cities';
  static String regionCities(int regionId) => 'regions/$regionId/cities';

  // ───────── notifications ─────────
  static const String notifications      = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String notificationsAllRead     = 'notifications/all/read';
  static String notificationRead(int id) => 'notifications/$id/read';

  // ───────── banners ─────────
  static const String banners            = 'banners';

  // ───────── uploads / misc ─────────
  static const String uploadsImage       = 'uploads/image';
  static const String reports            = 'reports';
}
```

---

## 2. Path conventions

- **Relative paths** (no leading `/`) for routes that concatenate onto
  `NetworkConfig.baseUrl`. Example: `'auth/login'`.
- **Absolute paths** (leading `/`) are allowed **only** where the
  current legacy code already uses them — specifically the two IAP
  verify endpoints (`/subscriptions/verify-apple-purchase`,
  `/subscriptions/verify-google-purchase`). This is an intentional 1:1
  preservation; changing them is a backend-coordinated fix and belongs
  in a separate feature.
- **Parameterized paths** use `static String` methods that accept the
  parameters typed (`int id`, `String type`) and return the formatted
  string.
- **Query strings**: allowed inline in the returned method result when
  the param is semantically part of the resource identity (e.g.
  `favoriteDelete(id, type)` where the backend disambiguates by
  `?type=`). Arbitrary filter/query params go in Dio's `queryParameters`
  argument, not in the catalog.

---

## 3. Extension rules

When adding a new endpoint:

1. Put the constant/method under the matching `// region <section>`
   group. Create a new region only when the backend introduces a new
   domain.
2. Name in `camelCase`, starting with the noun (`listings`,
   `favorites`) or the verb for write actions (`publishListing`,
   `verifyApple`). Prefer nouns — the HTTP verb already lives at the
   call site.
3. Do **not** prefix names with the verb (`getListings`) — that
   couples the catalog to a single HTTP method; an endpoint that
   accepts both GET and POST should have one catalog entry.
4. Keep the file ≤ 300 lines. If it exceeds that, split only by
   `// region` grouping into sibling files (`api_endpoints_listings.dart`,
   etc.), re-exported from `api_endpoints.dart` via `export`
   directives. Do **not** introduce nested classes for grouping.

---

## 4. Enforcement

- Grep guard (tasks.md will add a CI check): no raw endpoint string
  literals under `lib/data/**` outside this file. Any `'auth/'`,
  `'users/'`, etc. string constant in a data source is a review block.
- The legacy folders `lib/services/**` and `lib/providers/**` are
  **exempt** from this guard during the migration window — they still
  hold literal paths until each feature is migrated.

---

## 5. Verification

- Unit test: a "smoke" test imports `ApiEndpoints` and asserts every
  `String` field is non-empty and every method returns non-empty
  (guards against accidental empty constants).
- First migrated feature serves as the live acceptance: its data
  source references `ApiEndpoints` only, and the diff shows zero raw
  endpoint literals.
