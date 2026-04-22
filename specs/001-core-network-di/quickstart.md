# Quickstart: Using the Core Networking & DI Foundation

This file is the runtime-level guide for engineers who are **about to
migrate a feature** onto the new network core (or add a brand-new data
source). It deliberately skips architectural justification — see
[spec.md](spec.md) and [research.md](research.md) for that.

---

## TL;DR

1. Add an entry (or method) to `ApiEndpoints`.
2. Inject `Dio` into your data source via constructor.
3. Call `_dio.get/post/put/delete(ApiEndpoints.xxx, ...)`.
4. Wire the data source factory into `setupLocator()` (or your feature's
   local wiring file).

That's it. Auth, language, logging, and error-mapping are already
attached to every request.

---

## Add a new endpoint

Open [lib/core/constants/api_endpoints.dart](../../lib/core/constants/api_endpoints.dart)
and add under the matching `// region` group:

```dart
// region listings
...
static const String listingsFeatured = 'listings/featured';
// endregion
```

For a parameterized path:

```dart
static String listingsByCategory(String slug) => 'listings/category/$slug';
```

Rules (full list in [contracts/api_endpoints.contract.md](contracts/api_endpoints.contract.md)):

- Relative path, no leading `/` (unless you're intentionally preserving
  a legacy absolute path).
- Name after the resource, not the HTTP verb.
- Never raw-string an endpoint inside a data source — if you do, the
  grep guard in CI rejects your PR.

---

## Write a new data source

```dart
// lib/data/datasources/listings_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/listing_dto.dart';

class ListingsRemoteDataSource {
  ListingsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<ListingDto>> fetchAll({Map<String, dynamic>? filters}) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.listings,
      queryParameters: filters,
    );
    return (res.data ?? const []).map(ListingDto.fromJson).toList();
  }

  Future<void> toggleRented(int id) async {
    await _dio.post<void>(ApiEndpoints.listingToggleRented(id));
  }
}
```

Do:
- Receive `Dio` via constructor injection.
- Reference `ApiEndpoints.xxx` for every path.
- Convert `response.data` to DTOs and return DTOs upward.

Don't:
- `GetIt.instance.get<Dio>()` inside methods — inject at construction
  time.
- Attach headers manually — the interceptors already do it.
- Catch `DioException` here — let the **repository** catch it and map
  `e.error as Failure` upward.

---

## Wire the data source into DI

Each feature adds its own registrations. Do it in a feature-local
`<feature>_locator.dart` file (created when the first feature is
migrated) or directly in `setupLocator()` for v1:

```dart
// lib/core/di/service_locator.dart — inside setupLocator() or via a
// feature-local wiring function called from there.
getIt.registerFactory(() => ListingsRemoteDataSource(getIt<Dio>()));
```

Factory (not singleton) for data sources: they're cheap to construct,
should not hold state, and making them factories avoids cross-test
pollution in Cubit tests.

---

## Inspect traffic during development

Run the app in debug (`flutter run`). Every outbound request yields a
block like this in the debug console:

```text
[API] → POST /auth/login
       headers: Authorization=Bearer ***  X-App-Language=ar  ...
       body   : {"email":"...","password":"..."}
[API] ← 200 /auth/login
       body   : {"token":"...","user":{...}}
```

The `Authorization` header value is redacted to `Bearer ***` in logs.
In release builds, this block is absent entirely — the logging
interceptor short-circuits on `!kDebugMode` at the top of its methods.

**Manual release-silence check** (run at least once per release cut):

```bash
flutter build apk --release
flutter install
# observe adb logcat while performing a login → no payloads in logs
```

---

## Handle errors in a repository

Data sources raise `DioException`. Repositories catch and map:

```dart
// lib/data/repositories/listings_repository_impl.dart
class ListingsRepositoryImpl implements ListingsRepository {
  ListingsRepositoryImpl(this._remote);
  final ListingsRemoteDataSource _remote;

  @override
  Future<List<Listing>> fetchAll() async {
    try {
      final dtos = await _remote.fetchAll();
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error as Failure
          : const UnexpectedFailure('Network error');
      throw failure;            // Cubits catch Failure, not DioException
    }
  }
}
```

(Once the typed-failure feature lands, the `e.error` branch handles
`NetworkFailure` / `ServerFailure` / `UnexpectedFailure` in a single
`switch`.)

---

## FAQ

**Q: Where's the base URL?**
`AppConstants.baseUrl` in [lib/core/constants/app_constants.dart](../../lib/core/constants/app_constants.dart).
Changing it is a one-line edit; every request picks it up.

**Q: How do I change a timeout?**
Edit `NetworkConfig` in `lib/core/network/network_config.dart`. There
is intentionally no per-call override in v1 — if you think you need
one, file an issue before coding it.

**Q: How do I test a Cubit that depends on a repo that depends on a
data source that depends on Dio?**
Inject a fake at the repository boundary. Do NOT inject a mock `Dio`
into your Cubit — that leaks the data layer into a Presentation test.

**Q: How do I run with a different base URL (e.g. localhost on
emulator)?**
Uncomment the local-dev `baseUrl` line in `app_constants.dart` (same
workflow as today). Environment flavors are explicitly out of scope for
this feature.

**Q: The interceptor order is wrong for my feature.**
It isn't. If you think it is, re-read [research.md § R-003](research.md#r-003-interceptor-pipeline-order),
then open a constitution amendment if you're still sure.
