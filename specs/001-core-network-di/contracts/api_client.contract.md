# Contract: `ApiClient` / shared `Dio` instance

**File**: `lib/core/network/api_client.dart`
**Consumed by**: every data source under `lib/data/datasources/**` (future
features).
**Status**: stable — breaking changes require a constitution amendment.

---

## 1. Public surface

Only **one** symbol crosses this file's boundary publicly:

```dart
// lib/core/network/api_client.dart
abstract final class ApiClient {
  ApiClient._();

  /// Builds a fully-configured [Dio] instance:
  ///   - BaseOptions from [NetworkConfig]
  ///   - Interceptors attached in the canonical order (see §3)
  ///
  /// Called exclusively from [setupLocator] in
  /// `lib/core/di/service_locator.dart`. Data sources MUST NOT call
  /// this directly — they resolve the shared [Dio] via `getIt<Dio>()`.
  static Dio create({
    required TokenReader tokenReader,
    required LocaleReader localeReader,
  });
}
```

The `Dio` type itself is the value crossing the boundary. There is no
app-defined wrapper type around `Dio` in v1 — the Clean-Architecture
dependency rule is protected by convention (data sources import
`package:dio/dio.dart`; Domain & Presentation never do) and by review.

---

## 2. `BaseOptions` produced

`ApiClient.create()` sets, at minimum:

| Field              | Source                                     |
|--------------------|--------------------------------------------|
| `baseUrl`          | `NetworkConfig.baseUrl` (→ `AppConstants.baseUrl`) |
| `connectTimeout`   | `NetworkConfig.connectTimeout` (30s)       |
| `receiveTimeout`   | `NetworkConfig.receiveTimeout` (30s)       |
| `sendTimeout`      | `NetworkConfig.sendTimeout` (30s)          |
| `headers`          | `NetworkConfig.defaultHeaders` (JSON in/out)|
| `responseType`     | `ResponseType.json` (explicit, not default) |

`validateStatus` is **not** overridden in v1 (Dio's default: accept 2xx,
throw `DioException` for others) — the Error interceptor handles the
rest.

---

## 3. Interceptor pipeline order (IMMUTABLE)

Attached in this exact order by `ApiClient.create()`:

```text
#0  AuthInterceptor      (reads TokenReader)
#1  LanguageInterceptor  (reads LocaleReader)
#2  LoggingInterceptor   (kDebugMode-gated)
#3  ErrorInterceptor     (Dio → Failure stub)
```

**Outbound direction** (request): `#0 → #1 → #2 → #3 → network`.
**Inbound direction** (response/error): reversed automatically by Dio:
`network → #3 → #2 → #1 → #0`.

Rationale lives in [../research.md](../research.md) § R-003. Changing
the order is a contract-breaking change — it requires updating this
file **and** re-running the acceptance tests for US2 (auth) and US4
(language).

---

## 4. Consumption contract (for data sources)

```dart
// lib/data/datasources/some_remote_datasource.dart
class SomeRemoteDataSource {
  SomeRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<SomeDto>> fetchAll() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.someList);
    return (res.data ?? const []).map(SomeDto.fromJson).toList();
  }
}

// lib/core/di/service_locator.dart (feature-specific wiring elsewhere)
getIt.registerFactory(() => SomeRemoteDataSource(getIt<Dio>()));
```

Rules:
- Data sources receive `Dio` via constructor injection. No `GetIt.instance`
  inside data source methods.
- Data sources pass `ApiEndpoints.xxx` as the path argument. No string
  literals at call sites (see
  [api_endpoints.contract.md](api_endpoints.contract.md)).
- Data sources do not attach headers or configure timeouts locally —
  that's the interceptors'/base-options' job.
- Data sources catch `DioException` at the outermost boundary (in the
  repository implementation, not in the data source itself) and map
  `e.error as Failure` upward. The data source layer remains "plumbing."

---

## 5. Error surface

Every failed request arrives at the caller as a `DioException` whose
`error` field is a `Failure` (v1: always `UnexpectedFailure`; later
versions will populate `NetworkFailure` / `ServerFailure` per type).

Callers MUST NOT rely on any specific `DioExceptionType` value — that
is implementation detail of the Error interceptor and may change when
the typed-failure feature lands.

---

## 6. Guarantees this contract provides

| Guarantee                                                                                       | Verified by                                              |
|-------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| Base URL, timeouts, default headers are identical across all requests in the app                | `test/core/network/api_client_test.dart`                 |
| Logged-in requests carry `Authorization: Bearer <token>`; signed-out requests carry no such header | `test/core/network/interceptors/auth_interceptor_test.dart` |
| Every request carries the active locale                                                         | `test/core/network/interceptors/language_interceptor_test.dart` |
| Release builds emit zero network payload content to log sinks                                   | Manual release-build check (documented in `quickstart.md`) |
| Failed requests surface a `Failure` via `DioException.error`                                    | `test/core/network/interceptors/error_interceptor_test.dart` (stub-level) |
