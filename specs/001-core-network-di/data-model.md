# Phase 1 Data Model: Core Networking & DI Foundation

This feature introduces no user-facing domain entities. The "data model"
here captures the **infrastructure objects** the feature creates, their
fields, their relationships, and how they compose at startup.

## Entity diagram (relationships)

```text
                       ┌─────────────────────┐
                       │   AppConstants      │  (existing — unchanged)
                       │  + baseUrl          │
                       └─────────────────────┘
                                 │
                                 ▼
┌──────────────────┐     ┌─────────────────────┐
│  NetworkConfig   │────▶│     ApiClient       │
│ + timeouts       │     │ + dio: Dio          │
│ + default headers│     │ + pipeline (ordered)│
└──────────────────┘     └─────────────────────┘
                                 ▲           ▲
                                 │           │
                       ┌─────────┴────┐  ┌───┴──────────┐
                       │ TokenReader  │  │ LocaleReader │
                       └──────┬───────┘  └──────┬───────┘
                              │                 │
                              ▼                 ▼
                      (SharedPreferences: StorageKeys.token / .language)

                       ┌────────────────────────────┐
                       │  Interceptor pipeline       │
                       │   1. AuthInterceptor        │  uses TokenReader
                       │   2. LanguageInterceptor    │  uses LocaleReader
                       │   3. LoggingInterceptor     │  kDebugMode-gated
                       │   4. ErrorInterceptor       │  maps → Failure
                       └────────────────────────────┘

                       ┌────────────────────────────┐
                       │  ServiceLocator (getIt)     │
                       │  - TokenReader  (singleton) │
                       │  - LocaleReader (singleton) │
                       │  - Dio          (lazy sing.)│
                       └────────────────────────────┘

                       ┌────────────────────────────┐
                       │  ApiEndpoints               │  (consumed by
                       │  (static string catalog)    │   future data sources)
                       └────────────────────────────┘
```

---

## 1. `NetworkConfig` (value holder)

**Purpose**: single source of truth for base options.

| Field              | Type        | Value                                    | Notes                               |
|--------------------|-------------|------------------------------------------|-------------------------------------|
| `baseUrl`          | `String`    | `AppConstants.baseUrl`                   | Read through, not duplicated        |
| `connectTimeout`   | `Duration`  | 30 seconds                               | Matches legacy `ApiService` timeout |
| `receiveTimeout`   | `Duration`  | 30 seconds                               |                                     |
| `sendTimeout`      | `Duration`  | 30 seconds                               |                                     |
| `defaultHeaders`   | `Map<String,String>` | `{'Content-Type': 'application/json', 'Accept': 'application/json'}` | Matches legacy headers |

**Validation rules**:
- `baseUrl` MUST be non-empty at construction (assert in debug).
- Timeouts MUST be strictly positive.

**State transitions**: none — immutable `const` class.

---

## 2. `TokenReader` (interface + `SharedPreferencesTokenReader` impl)

**Purpose**: sync-accessible, mutable token cache used by
`AuthInterceptor`. Hides the storage mechanism so secure-storage
migration later is a one-class change.

**Interface**:

| Member                  | Signature                           | Notes                              |
|-------------------------|-------------------------------------|------------------------------------|
| `currentToken`          | `String? get`                       | Returns `null` if unset/empty      |
| `refreshFromStorage()`  | `Future<void>`                      | Called once at `setupLocator()`    |
| `setToken(String?)`     | `void`                              | Called by `AuthProvider` on login/logout; writes both in-memory cache and persistent store |
| `clear()`               | `void`                              | Convenience for `setToken(null)`   |

**Validation rules**:
- Empty string is treated as `null` (no auth header attached).
- `currentToken` is safe to call before `refreshFromStorage()` completes — returns `null`.

**State transitions**:

```text
            ┌──────────┐   setToken(t)    ┌──────────┐
   start ──▶│  unset   │─────────────────▶│  present │
            │ (null)   │◀─────────────────│          │
            └──────────┘  setToken(null)  └──────────┘
```

---

## 3. `LocaleReader` (interface + `SharedPreferencesLocaleReader` impl)

**Purpose**: sync-accessible language code for `LanguageInterceptor`.

| Member                      | Signature                          | Notes                                      |
|-----------------------------|------------------------------------|--------------------------------------------|
| `currentLanguageCode`       | `String get`                       | One of `ar`, `he`, `en`; defaults to `ar`  |
| `refreshFromStorage()`      | `Future<void>`                     | Reads `StorageKeys.language` once          |
| `setLanguageCode(String)`   | `void`                             | Called by `AppProvider.setLocale`          |

**Validation rules**:
- Unknown/malformed values fall back to `ar` (matches existing default
  in [lib/providers/app_provider.dart](../../lib/providers/app_provider.dart)).
- Never returns `null`.

**State transitions**: three-state enum-like (ar / he / en); default
is `ar`.

---

## 4. `ApiClient` (factory)

**Purpose**: builds a single configured `Dio` instance.

| Member                              | Signature                                                                                    |
|-------------------------------------|----------------------------------------------------------------------------------------------|
| `ApiClient.create({readers...})`    | `static Dio create({required TokenReader tokenReader, required LocaleReader localeReader})`  |

**What it does**:
1. Constructs `Dio(BaseOptions(...))` from `NetworkConfig` values.
2. Registers interceptors in the canonical order (see R-003 /
   `contracts/api_client.contract.md`).
3. Returns the configured `Dio`.

**Validation rules**:
- Constitution III: MUST only be called via the DI container for the
  shared instance. Calling `ApiClient.create(...)` outside
  `setupLocator()` is a policy violation (reviewable, not enforceable
  in code).

---

## 5. Interceptors (four)

### `AuthInterceptor`

| Input                   | Output                                              |
|-------------------------|-----------------------------------------------------|
| Outbound `RequestOptions` | Same options with `Authorization: Bearer <token>` added iff `tokenReader.currentToken != null && != ''` |
| Inbound response / error | Pass-through (no 401 recovery in v1)                |

### `LanguageInterceptor`

| Input                   | Output                                              |
|-------------------------|-----------------------------------------------------|
| Outbound `RequestOptions` | Same options with `Accept-Language: <code>` and `X-App-Language: <code>` added using `localeReader.currentLanguageCode` |
| Inbound response / error | Pass-through                                        |

### `LoggingInterceptor`

| Input                   | Output                                              |
|-------------------------|-----------------------------------------------------|
| Outbound `RequestOptions` | If `kDebugMode`: `debugPrint` method/URL/headers/body summary; else no-op. Pass-through always. |
| Inbound response        | If `kDebugMode`: `debugPrint` status + body summary; else no-op. |
| Inbound error           | If `kDebugMode`: `debugPrint` summary; else no-op.  |

**Constraint**: MUST NOT log the `Authorization` header value — redact
to `Bearer ***` in debug output.

### `ErrorInterceptor`

| Input                   | Output                                              |
|-------------------------|-----------------------------------------------------|
| Outbound `RequestOptions` | Pass-through                                      |
| Inbound response (2xx)  | Pass-through                                        |
| Inbound `DioException`  | Wraps `e.error = UnexpectedFailure(e.message ?? 'Unexpected error')` and rethrows. Preserves `e.type`, `e.response`, `e.requestOptions`. |

---

## 6. `Failure` (sealed stub)

| Class              | Purpose                                               |
|--------------------|-------------------------------------------------------|
| `sealed Failure`   | Root — has `String message`                           |
| `NetworkFailure`   | Connectivity, timeout, DNS — **not wired in v1**      |
| `ServerFailure`    | Non-2xx responses — **not wired in v1**               |
| `UnexpectedFailure`| Fallback — **the only variant actually emitted in v1**|

Concrete mapping (which `DioExceptionType` → which `Failure`) is
delivered by a follow-up feature.

---

## 7. `ApiEndpoints` (catalog)

A single class under `lib/core/constants/api_endpoints.dart`:

- Private constructor `ApiEndpoints._();` (prevent instantiation).
- `static const String <name> = '<path>';` entries, grouped by backend
  section with `// region` / `// endregion` comments.
- `static String <name>ById(int id) => '<path>/$id';` methods for
  parameterized paths.
- Paths are **relative** (no leading slash), matching existing
  `ApiService` conventions — so joining with `NetworkConfig.baseUrl`
  via Dio works correctly.

**Initial contents (v1)**: 1:1 extraction of the paths referenced by
the current [lib/services/api_service.dart](../../lib/services/api_service.dart)
call sites in the repo. Exact list is enumerated in
[contracts/api_endpoints.contract.md](contracts/api_endpoints.contract.md).

---

## 8. `ServiceLocator`

**Single variable**: `final GetIt getIt = GetIt.instance;`

**Single function**: `Future<void> setupLocator() async { ... }`

Registration order (order matters because lazy Dio reads the readers
on first resolution):

1. `getIt.registerSingleton<TokenReader>(SharedPreferencesTokenReader());`
2. `getIt.registerSingleton<LocaleReader>(SharedPreferencesLocaleReader());`
3. `await getIt<TokenReader>().refreshFromStorage();`
4. `await getIt<LocaleReader>().refreshFromStorage();`
5. `getIt.registerLazySingleton<Dio>(() => ApiClient.create(tokenReader: getIt(), localeReader: getIt()));`

**Idempotency**: `setupLocator()` checks `if (getIt.isRegistered<Dio>()) return;`
at the top — safe to call multiple times (tests; hot-reload edge cases).

**Tear-down for tests**: `Future<void> resetLocator() async { await getIt.reset(); }` is exposed.
