# Phase 0 Research: Core Networking & DI Foundation

Scope: resolve every open decision the plan depends on, so Phase 1 can
produce concrete contracts. One row per decision.

---

## R-001: `get_it` registration mode for the shared Dio client

**Question**: Should the Dio instance be registered as `registerSingleton`
(constructed eagerly at `setupLocator()`) or `registerLazySingleton`
(constructed on first resolution)?

**Decision**: `registerLazySingleton<Dio>`.

**Rationale**:
- Constructing Dio costs near-zero (it's just allocating a config + a
  list of interceptors) — so lazy doesn't measurably speed startup.
- But lazy removes any ordering risk during `setupLocator()` (no
  accidental await chains), and makes it trivial to override in tests
  via `getIt.resetLazySingleton<Dio>()` or a scoped `pushNewScope()`.
- Matches the standard `get_it` guidance for "cheap to construct, used
  by many consumers."

**Alternatives considered**:
- `registerSingleton<Dio>(Dio(...))`: slightly more predictable startup
  timing, but harder to reset in widget tests; not worth the rigidity.
- `registerFactory<Dio>`: wrong — we want a single shared client, not a
  new one per call.

---

## R-002: `get_it` version

**Question**: Which `get_it` major version?

**Decision**: `get_it ^7.7.0` (current stable at the time of writing,
2026-04-22).

**Rationale**: 7.x has been the stable Flutter-compatible line for
multiple years, has `pushNewScope` / `resetLazySingleton` APIs used by
the test strategy in R-001, and matches Dart SDK `^3.8.1`.

**Alternatives considered**:
- `injectable` + `get_it`: codegen layer on top; overkill for the
  ~5 registrations this feature introduces. Revisit if registrations
  grow past ~30.

---

## R-003: Interceptor pipeline order

**Question**: In what order do the four interceptors execute for outbound
requests and inbound responses?

**Decision**: Outbound order `Auth → Language → Logging → Error`;
inbound order reverses automatically via Dio's stack
(`Error → Logging → Language → Auth`).

| Phase    | 1st                | 2nd                | 3rd                | 4th                |
|----------|--------------------|--------------------|--------------------|--------------------|
| Request  | Auth               | Language           | Logging            | Error              |
| Response | Error              | Logging            | Language           | Auth               |

**Rationale**:
- **Auth first on request**: the token must be attached *before* any
  other interceptor can observe/log it. Logging intentionally runs
  after so log lines reflect what actually leaves the device.
- **Language second**: purely additive headers, order vs. Auth is
  inconsequential but placing it adjacent to Auth keeps "header
  injectors" grouped.
- **Logging third on request, second on response**: sees the final
  request shape going out, and the raw response shape coming in —
  before the Error interceptor rewrites failures. Debug-only, so order
  has no release impact.
- **Error last on request / first on response**: Error's purpose is
  outbound pass-through + inbound normalization. By running first
  inbound, it ensures typed-failure mapping happens before anything
  else inspects the response.

**Alternatives considered**:
- Logging first (sees every interceptor's mutations separately): more
  verbose, mixes infrastructure logs with app-level ones, rejected.
- Error between Auth and Language: would require Error to know about
  auth-specific recovery (401 → trigger refresh), which is explicitly
  out of scope per spec FR-011.

---

## R-004: Logging in debug vs release

**Question**: How do we guarantee logging is fully inert in release
builds, not just "quiet"?

**Decision**: Gate the entire interceptor body with `kDebugMode` from
`package:flutter/foundation.dart`. In release, `kDebugMode` is a
compile-time constant `false`, so the Dart tree-shaker drops the
interceptor's side effects. Add it to the chain in both modes (so the
pipeline shape is identical) but have every branch short-circuit when
`!kDebugMode`.

**Rationale**:
- Compile-time constant → zero cost and zero log writes in release.
- Identical pipeline shape across modes avoids "works in debug, breaks
  in release" surprises (a real concern with interceptor-order bugs).
- Matches the approach used elsewhere in the codebase
  ([lib/services/api_service.dart](../../lib/services/api_service.dart)
  uses `debugPrint` which already no-ops in release, but that project
  pattern is carried forward here).

**Alternatives considered**:
- Conditional addition (`if (kDebugMode) addInterceptor(...)`): works,
  but creates different pipeline shapes per build. Slight risk of
  behavioural drift. Rejected.
- A third-party package (e.g. `pretty_dio_logger`): adds a dependency
  purely for formatting. Our needs are minimal; a ~40-line interceptor
  suffices. Rejected to keep the dependency tree lean (constitution
  V: simplicity).

---

## R-005: Token read strategy from inside the AuthInterceptor

**Question**: Dio interceptors run on the request path (often
awaited, but ideally fast). `SharedPreferences.getInstance()` is async.
How does the interceptor read the token without blocking or race
conditions?

**Decision**: Introduce a thin `TokenReader` under
`lib/core/storage/token_reader.dart`. It holds an in-memory cached
`String? _cachedToken`, exposes:

```dart
abstract class TokenReader {
  String? get currentToken;              // sync — used by the interceptor
  Future<void> refreshFromStorage();     // called at startup + after login/logout
  void setToken(String? token);          // called by future AuthCubit on login/logout
}
```

At `setupLocator()`:
1. Register a `TokenReader` singleton.
2. Call `tokenReader.refreshFromStorage()` (reads `StorageKeys.token`
   from `SharedPreferences`).
3. Register Dio lazily (it will pick up the already-populated reader).

The AuthInterceptor calls `tokenReader.currentToken` synchronously —
zero async work on the hot request path.

During this feature, the **legacy** `AuthProvider` is the one that
writes/removes the token. We'll add a single one-liner in
`AuthProvider.login/logout` to call `getIt<TokenReader>().setToken(...)`
**if get_it is initialized** (guarded). This is the only legacy-code
edit the feature makes; it keeps the new interceptor and the old auth
flow in lockstep during the transition. When the auth feature is
migrated, the one-liner moves into the new `AuthCubit` and the legacy
edit is deleted.

**Rationale**:
- Interceptors MUST remain sync for request-path predictability.
- `TokenReader` is the "seam" that hides storage details — later, the
  move to `flutter_secure_storage` happens inside `TokenReader.refreshFromStorage`
  without touching the interceptor or any call site.
- Cold-start race (spec edge case) is handled explicitly: if
  `refreshFromStorage()` hasn't completed yet, `currentToken` returns
  `null`, the interceptor attaches no header, and the request proceeds
  unauthenticated — exactly the spec's stated behavior.

**Alternatives considered**:
- Make the interceptor `async` and `await SharedPreferences.getInstance()`
  on every request: adds async overhead per call and risks races;
  rejected.
- Read directly from the legacy `AuthProvider`: creates a reverse
  dependency from `lib/core/**` into `lib/providers/**`, violating
  the dependency rule even though providers are legacy. Rejected.
- Use `flutter_secure_storage` directly: async-only API, same problem;
  deferred to the separate secure-storage feature.

---

## R-006: Locale read strategy for the LanguageInterceptor

**Question**: The active locale currently lives in `AppProvider`
(`_locale`), backed by `SharedPreferences` at `StorageKeys.language`.
How does the interceptor read it without importing `provider` into
`lib/core/**`?

**Decision**: Mirror R-005 — add a `LocaleReader` in
`lib/core/storage/token_reader.dart`… actually in a sibling file
`lib/core/storage/locale_reader.dart` to keep single-responsibility:

```dart
abstract class LocaleReader {
  String get currentLanguageCode; // sync — used by the interceptor; defaults to 'ar'
  Future<void> refreshFromStorage();
  void setLanguageCode(String code);
}
```

Registered as a `get_it` singleton; `refreshFromStorage()` called in
`setupLocator()`. The legacy `AppProvider.setLocale` gets a one-liner
to push the new value into `LocaleReader` (same pattern as R-005, same
deletion trajectory).

Header shape: send `Accept-Language: ar|he|en` (IETF standard) **and**
a custom `X-App-Language` header (so the rento-go backend, which today
receives `preferred_language` as a body field, can pick either).

**Rationale**: keeps the interceptor sync, hides storage from `core/`,
matches the token pattern exactly so reviewers only learn one idiom.

**Alternatives considered**:
- Single `PrefsReader` bundling token + locale: convenient but
  conflates unrelated state into one class; rejected in favor of two
  narrow classes (constitution V: single responsibility).
- Only `Accept-Language`: simpler but may not match backend
  expectations (`preferred_language` in existing calls); sending both
  is cheap insurance.

---

## R-007: Typed-failure stub for the Error interceptor seat

**Question**: The Error interceptor is wired now, but spec FR-011 says
concrete mapping is delivered later. What's the minimum stub?

**Decision**: Introduce a sealed class hierarchy skeleton in
`lib/core/error/failure.dart`:

```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure { /* timeout, no-connection */ }
class ServerFailure extends Failure  { /* 4xx/5xx */ }
class UnexpectedFailure extends Failure { /* anything else */ }
```

The Error interceptor catches `DioException` and converts only to
`UnexpectedFailure(e.message ?? 'Unexpected error')` for now,
re-throwing as a `DioException` whose `error` field holds the `Failure`
object. That keeps Dio's contract intact and lets the later typed-error
feature replace the body of the mapper without touching call sites.

**Rationale**:
- Gives repositories a stable type to catch against from day one (they
  can filter `e.error is Failure`).
- Avoids introducing `dartz` or a `Result` type speculatively —
  constitution V explicitly rejects premature abstraction. The choice
  between `Either` vs sealed `Result` is the follow-up feature's call.

**Alternatives considered**:
- Add `dartz` now and return `Either<Failure, Response>` from
  everywhere: large surface-area change, and the choice belongs to a
  separate, user-approved feature. Rejected.
- Skip the stub entirely: leaves the Error interceptor with nothing to
  do, which breaks the "pipeline order is fixed and documented"
  requirement (FR-011). Rejected.

---

## R-008: Pipeline composition location

**Question**: Where does the `Dio` instance get its interceptors
attached — in `ApiClient` (the factory) or in `setupLocator()`?

**Decision**: Inside `ApiClient.create()` (the factory constructor),
which receives already-resolved `TokenReader` / `LocaleReader`
instances via parameters. `setupLocator()` only wires dependencies
together; it doesn't know the pipeline order.

**Rationale**: single source of truth for pipeline order (R-003) lives
next to the `ApiClient` it belongs to; the DI file stays small and
obvious.

**Alternatives considered**:
- Build the list inline in `setupLocator()`: spreads pipeline knowledge
  across two files; rejected.

---

## R-009: Coexistence with legacy `ApiService`

**Question**: What stops the legacy static `ApiService` from breaking
when we add a new Dio client?

**Decision**: Nothing changes in `lib/services/api_service.dart`. The
legacy class uses its own static `_token` and `package:http` — fully
independent of Dio, `get_it`, or interceptors. The only legacy edit
made by this feature is the two one-liners in
[lib/providers/auth_provider.dart](../../lib/providers/auth_provider.dart)
and [lib/providers/app_provider.dart](../../lib/providers/app_provider.dart)
described in R-005 / R-006, each guarded with `if (GetIt.I.isRegistered<...>())`
so they no-op before `setupLocator()` runs.

**Rationale**: minimises risk; spec FR-012 makes this a hard
requirement; constitution "preserve-working-code" was revoked but the
refactor is "incremental" and "a feature is migrated only when all its
files move" — so during this PR we do not migrate the auth feature.

---

## R-010: ApiEndpoints catalog shape

**Question**: One flat class or grouped subclasses?

**Decision**: One class `ApiEndpoints` with static `const String`
fields grouped by `// region` comments matching the backend's sections:
`auth`, `users`, `listings`, `favorites`, `chat`, `checkout`, `packages`,
`notifications`, `regions`, `plans`, `banners`. Endpoints extracted
1:1 from [lib/services/api_service.dart](../../lib/services/api_service.dart)
call sites (current: ~30 paths).

```dart
class ApiEndpoints {
  ApiEndpoints._();
  // region auth
  static const String authRegister = 'auth/register';
  static const String authLogin    = 'auth/login';
  // endregion
  // region users
  static const String usersUpdate  = 'users/update';
  // ...
}
```

Paths are **relative** (no leading slash) to match Dio's base-URL join
behavior and the existing `ApiService` convention.

**Rationale**: one file, greppable, trivially refactorable. Subclasses
add hierarchy for no gain at this scale.

**Alternatives considered**:
- Nested classes (`ApiEndpoints.Auth.register`): forces import ceremony
  and two-level dotted access without clearer intent at 30 entries.
  Reconsider at ~100 entries.
- `enum` per domain: loses string-interpolation ergonomics for
  `/users/{id}`-style paths and complicates future templating.
  Rejected.

---

## R-011: Path templating for parameterized endpoints

**Question**: How do dynamic paths (e.g. `listings/{id}/favorite`) live
in the catalog?

**Decision**: As small static methods returning `String`:

```dart
static String listingById(int id) => 'listings/$id';
static String listingFavorite(int id) => 'listings/$id/favorite';
```

Constant strings for fixed paths, static methods for templated ones.
Still one file, still one import.

**Rationale**: uniform call-site shape (`ApiEndpoints.xxx`), no
string-interpolation duplication in data sources, compile-time
parameter types.

---

## R-012: Tightened lints

**Question**: Constitution V says "Lint is a gate" and names specific
rules. Which do we enable in this PR?

**Decision**: Keep `include: package:flutter_lints/flutter.yaml` and add:

```yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_final_locals: true
    always_declare_return_types: true
    unnecessary_lambdas: true
    avoid_classes_with_only_static_members: false   # ApiEndpoints is one
    avoid_dynamic_calls: true
    require_trailing_commas: true
```

**Rationale**: Every rule on the constitution's example list, plus a
few adjacent ones that cost nothing at this file count. `avoid_classes_with_only_static_members`
is explicitly disabled — `ApiEndpoints` is intentionally a
static-members namespace. `require_trailing_commas` improves diff
quality across the refactor.

**Alternatives considered**:
- `very_good_analysis` or `lint`: bigger ruleset, more churn in legacy
  files this PR doesn't touch. Defer to a dedicated lint-tightening
  feature.

---

## R-013: Testing depth for v1

**Question**: What's worth unit-testing now, given the feature ships
no business logic?

**Decision**: Test the **behavioral contracts** only:
- `AuthInterceptor`: attaches header when token present; attaches
  nothing when `null`; attaches nothing when empty string.
- `LanguageInterceptor`: attaches `Accept-Language` and `X-App-Language`
  matching the current `LocaleReader` value; picks up changes to the
  reader without rebuilding the client.
- `ErrorInterceptor`: maps a `DioException` to a `DioException` whose
  `error` is a `Failure` (stub verification).
- `ApiClient`: exposes a `Dio` whose `options.baseUrl`,
  `options.connectTimeout`, `options.receiveTimeout`, `options.sendTimeout`
  equal the constants from `NetworkConfig`.
- `ServiceLocator`: `setupLocator()` followed by two resolutions of the
  same `Dio` returns the same instance; `setupLocator()` is safely
  idempotent (or fails loudly on re-register — decide in tasks.md).

Logging interceptor's release-silence is verified manually on a
release build (can't be meaningfully unit-tested since `kDebugMode` is
a compile-time constant).

**Rationale**: covers every acceptance scenario in the spec (US1–US5)
except the release-silence check, with ~5 small test files. No mocking
of `SharedPreferences` needed if `TokenReader`/`LocaleReader` are
abstract and we inject fakes.

**Alternatives considered**:
- Skip tests, rely on first-migrated-feature integration: leaves
  regressions invisible until that PR lands. Rejected — constitution V
  implies testability at unit level where cheap.

---

## Consolidated decisions summary

| Area | Decision |
|------|----------|
| DI lib | `get_it ^7.7.0` |
| Dio registration | `registerLazySingleton<Dio>` |
| Pipeline order | Auth → Language → Logging → Error (request) |
| Logging gate | `kDebugMode` compile-time constant, always in pipeline |
| Token read | Sync `TokenReader` seam, SP-backed, populated at startup + via legacy `AuthProvider` one-liner |
| Locale read | Sync `LocaleReader` seam, same pattern |
| Failure stub | Sealed `Failure` + 3 subclasses; `UnexpectedFailure` only wired now |
| Pipeline composed in | `ApiClient.create()` factory |
| Legacy coexistence | Guarded one-liners in `auth_provider.dart` / `app_provider.dart`; no other legacy edits |
| Endpoint catalog | Single `ApiEndpoints` class, static consts + static methods for parameterized paths |
| Lints added | `prefer_const_constructors`, `prefer_final_locals`, `always_declare_return_types`, `unnecessary_lambdas`, `avoid_dynamic_calls`, `require_trailing_commas` |
| Tests | Interceptor unit tests + DI singleton test + base-options test |

No `NEEDS CLARIFICATION` items remain.
