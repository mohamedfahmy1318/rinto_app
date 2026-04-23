---

description: "Task list for feature 001-core-network-di implementation"
---

# Tasks: Core Networking & DI Foundation

**Input**: Design documents from `/specs/001-core-network-di/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Included. Research § R-013 defines unit-test coverage for
every interceptor plus the service locator. Tests live alongside the
code under `test/core/**`.

**Organization**: Tasks are grouped by user story (US1–US5). Each story
produces an independently testable increment on top of the one before
it, so each story's checkpoint is a valid stopping/merge point.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story the task belongs to (US1…US5)
- Every task includes an exact file path

## Path Conventions

Flutter mobile-app single-project layout (plan.md § Project Structure).
All paths are repo-relative. New code lands under `lib/core/**`; tests
under `test/core/**`. Empty `lib/{data,domain,presentation}/` folders
are created with `.gitkeep` for the first migrated feature to use.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the one new dependency and tighten lints before any
production code is written.

- [X] T001 Add `get_it: ^7.7.0` to `dependencies` in [pubspec.yaml](../../pubspec.yaml) and run `flutter pub get`
- [X] T002 [P] Tighten lints in [analysis_options.yaml](../../analysis_options.yaml) per research § R-012 (add `prefer_const_constructors`, `prefer_final_locals`, `always_declare_return_types`, `unnecessary_lambdas`, `avoid_dynamic_calls`, `require_trailing_commas`)
- [X] T003 [P] Create empty layer directories with `.gitkeep` files: `lib/data/.gitkeep`, `lib/domain/.gitkeep`, `lib/presentation/.gitkeep` (so the Clean-Architecture target layout is present for the first migrated feature)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the pieces every user story downstream depends on —
`NetworkConfig`, the reader seams, the `Failure` stub, the service
locator skeleton, and the `main.dart` boot wiring.

**⚠️ CRITICAL**: No user story may begin until this phase is complete.

- [X] T004 [P] Create `NetworkConfig` (immutable const holder for baseUrl / 3 timeouts / default JSON headers) in `lib/core/network/network_config.dart`, reading `AppConstants.baseUrl` from [lib/core/constants/app_constants.dart](../../lib/core/constants/app_constants.dart); see data-model § 1
- [X] T005 [P] Create `TokenReader` abstract class + `SharedPreferencesTokenReader` impl (sync `currentToken`, async `refreshFromStorage`, sync `setToken`, `clear`) backed by `StorageKeys.token` in `lib/core/storage/token_reader.dart`; see data-model § 2 and research § R-005
- [X] T006 [P] Create `LocaleReader` abstract class + `SharedPreferencesLocaleReader` impl (sync `currentLanguageCode` defaulting to `'ar'`, async `refreshFromStorage`, sync `setLanguageCode`) backed by `StorageKeys.language` in `lib/core/storage/locale_reader.dart`; see data-model § 3 and research § R-006
- [X] T007 [P] Create sealed `Failure` hierarchy stub (`Failure` + `NetworkFailure`, `ServerFailure`, `UnexpectedFailure`) in `lib/core/error/failure.dart`; only `UnexpectedFailure` is instantiated in v1; see data-model § 6 and research § R-007
- [X] T008 Create `getIt` accessor + `setupLocator()` skeleton in `lib/core/di/service_locator.dart` — idempotency guard (`if (getIt.isRegistered<Dio>()) return;`), register `TokenReader` and `LocaleReader` as singletons, call `refreshFromStorage()` on both, expose `resetLocator()` for tests; see contracts/service_locator.contract.md § 2. **Does not yet register Dio** — US1 adds that
- [X] T009 Wire `await setupLocator();` into [lib/main.dart](../../lib/main.dart) immediately after `WidgetsFlutterBinding.ensureInitialized()` and before the Firebase block, per contracts/service_locator.contract.md § 3
- [X] T010 [P] Unit test: `setupLocator()` registers `TokenReader` and `LocaleReader`; second call is a no-op; `resetLocator()` followed by `setupLocator()` re-registers cleanly — in `test/core/di/service_locator_test.dart`

**Checkpoint**: Foundation ready. All readers are populated at app boot; the
service locator is safe to resolve against. No network client yet.

---

## Phase 3: User Story 1 — Single Network Client, Shared Across Features (Priority: P1) 🎯 MVP

**Goal**: Any layer can resolve a correctly-configured `Dio` instance
through `getIt<Dio>()`. Base URL and timeouts are applied; no
interceptors yet.

**Independent Test**: Build the app. In a throwaway call site, do
`final dio = getIt<Dio>(); final res = await dio.get('regions');`
Confirm the GET hits the real `AppConstants.baseUrl` and the timeouts
match `NetworkConfig` (verified via debugger or the unit test below).
No crash; no additional per-call config code.

### Tests for User Story 1

- [X] T011 [P] [US1] Unit test: `ApiClient.create(...)` returns a `Dio` whose `options.baseUrl`, `options.connectTimeout`, `options.receiveTimeout`, `options.sendTimeout`, and `options.headers` equal the values from `NetworkConfig` — in `test/core/network/api_client_test.dart`
- [X] T012 [P] [US1] Unit test: two consecutive `getIt<Dio>()` resolutions return the identical instance (lazy-singleton semantics) — extend `test/core/di/service_locator_test.dart`

### Implementation for User Story 1

- [X] T013 [P] [US1] Create `ApiClient.create({tokenReader, localeReader})` factory that returns a `Dio` wired with `NetworkConfig` `BaseOptions` and an **empty** `Interceptors` list — in `lib/core/network/api_client.dart`; see contracts/api_client.contract.md § 1–2
- [X] T014 [US1] Register `Dio` as `registerLazySingleton<Dio>` in [lib/core/di/service_locator.dart](../../lib/core/di/service_locator.dart) using `ApiClient.create(tokenReader: getIt(), localeReader: getIt())`; depends on T008 and T013

**Checkpoint**: `getIt<Dio>()` works end-to-end. Client sends real requests
with correct base URL + timeouts. No auth, logging, or language yet —
those land in US2/US3/US4 as independent additions. **This is the MVP
cut-line.**

---

## Phase 4: User Story 2 — Auth Token Attached Transparently (Priority: P1)

**Goal**: Logged-in requests carry `Authorization: Bearer <token>`;
signed-out requests carry no `Authorization` header at all (not a
malformed one).

**Independent Test**: Sign in on a debug build, call an authenticated
endpoint, confirm via the debug log (once US3 lands) or the unit test
below that the request carries `Authorization: Bearer <token>`. Sign
out and confirm the next request carries no such header.

### Tests for User Story 2

- [X] T015 [P] [US2] Unit test: `AuthInterceptor` attaches header when `tokenReader.currentToken` is a non-empty string; attaches no header when `null`; attaches no header when empty string — using a fake `TokenReader`, in `test/core/network/interceptors/auth_interceptor_test.dart`

### Implementation for User Story 2

- [X] T016 [P] [US2] Create `AuthInterceptor` that reads `TokenReader.currentToken` synchronously and conditionally injects `Authorization: Bearer <token>` into outbound requests — in `lib/core/network/interceptors/auth_interceptor.dart`; see data-model § 5 and research § R-005
- [X] T017 [US2] Insert `AuthInterceptor(getIt<TokenReader>())` as pipeline position **#0** (first) in [lib/core/network/api_client.dart](../../lib/core/network/api_client.dart); depends on T013 and T016
- [X] T018 [US2] Guarded one-liner edits in [lib/providers/auth_provider.dart](../../lib/providers/auth_provider.dart): on successful login call `getIt<TokenReader>().setToken(_token);` wrapped in `if (getIt.isRegistered<TokenReader>())`; in `logout()` call `getIt<TokenReader>().clear();` with the same guard; see contracts/service_locator.contract.md § 5 (NOTE: this is the **only** legacy-auth-provider edit this feature makes)

**Checkpoint**: Authenticated requests work. US1 + US2 together cover the
authenticated-feature path.

---

## Phase 5: User Story 3 — Debuggable Traffic in Dev, Silent in Release (Priority: P2)

**Goal**: Debug builds print readable request/response traces with the
`Authorization` header value redacted; release builds emit nothing.

**Independent Test**: Run `flutter run` (debug), issue any request,
observe the `[API] → METHOD /path` and `[API] ← status` blocks in the
console. Then `flutter build apk --release && flutter install`,
perform a login, watch `adb logcat`, confirm zero request/response
payload lines appear.

### Tests for User Story 3

- [X] T019 [P] [US3] Unit test: `LoggingInterceptor` in a `kDebugMode`-true harness writes a request line and a response line; the `Authorization` header value is rendered as `Bearer ***` (never the raw token) — in `test/core/network/interceptors/logging_interceptor_test.dart`

### Implementation for User Story 3

- [X] T020 [P] [US3] Create `LoggingInterceptor` with `kDebugMode` short-circuit at the top of every handler method (request / response / error), using `debugPrint` for output, redacting `Authorization` to `Bearer ***` — in `lib/core/network/interceptors/logging_interceptor.dart`; see data-model § 5 and research § R-004
- [X] T021 [US3] Insert `LoggingInterceptor()` as pipeline position **#2** (after `AuthInterceptor` and `LanguageInterceptor` seat) in [lib/core/network/api_client.dart](../../lib/core/network/api_client.dart); depends on T017 and T020

**Checkpoint**: Debug logs readable; release logs silent. Release-silence
check is a **manual** verification documented in
[quickstart.md](quickstart.md) and revisited in polish T033.

---

## Phase 6: User Story 4 — Correct Language-Tagged Responses (Priority: P2)

**Goal**: Every request carries `Accept-Language: <code>` and
`X-App-Language: <code>` matching the user's current in-app language.
Language changes at runtime take effect on the next request.

**Independent Test**: Change language Arabic → Hebrew in the app, issue
any endpoint that returns localized text (e.g. `notifications`),
confirm the response text is in Hebrew. Via the unit test below,
confirm both headers are present and match the active reader value.

### Tests for User Story 4

- [X] T022 [P] [US4] Unit test: `LanguageInterceptor` attaches `Accept-Language` and `X-App-Language` headers whose values equal the current `localeReader.currentLanguageCode`; after `localeReader.setLanguageCode('he')`, the next intercepted request carries `'he'` — using a fake `LocaleReader`, in `test/core/network/interceptors/language_interceptor_test.dart`

### Implementation for User Story 4

- [X] T023 [P] [US4] Create `LanguageInterceptor` that reads `LocaleReader.currentLanguageCode` on every outbound request and injects both `Accept-Language` and `X-App-Language` headers — in `lib/core/network/interceptors/language_interceptor.dart`; see data-model § 5 and research § R-006
- [X] T024 [US4] Insert `LanguageInterceptor(getIt<LocaleReader>())` as pipeline position **#1** (between `AuthInterceptor` and `LoggingInterceptor`) in [lib/core/network/api_client.dart](../../lib/core/network/api_client.dart); depends on T017 and T023
- [X] T025 [US4] Guarded one-liner edit in [lib/providers/app_provider.dart](../../lib/providers/app_provider.dart) `setLocale()`: add `if (getIt.isRegistered<LocaleReader>()) getIt<LocaleReader>().setLanguageCode(locale.languageCode);`; see contracts/service_locator.contract.md § 5 (NOTE: this is the **only** legacy-app-provider edit this feature makes)

**Checkpoint**: All four P1/P2 stories landed. Client sends correctly
authenticated, correctly language-tagged requests; logs are debug-only.

---

## Phase 7: User Story 5 — One Place for URL Paths (Priority: P3)

**Goal**: A single `ApiEndpoints` catalog holds every URL path used by
the app. New data sources and new endpoints live here, not in call-site
string literals.

**Independent Test**: Open [contracts/api_endpoints.contract.md](contracts/api_endpoints.contract.md),
confirm every path in the contract is reflected in `ApiEndpoints`.
Rename one constant and confirm call sites (once any exist in `lib/data/**`)
compile against the new name. For v1, the smoke test below is sufficient.

### Tests for User Story 5

- [X] T026 [P] [US5] Smoke test: every `static const String` field in `ApiEndpoints` is non-empty and non-null; every `static String` method returns a non-empty string when called with a valid argument (e.g. `ApiEndpoints.listingById('listings', 1)`) — in `test/core/constants/api_endpoints_test.dart`

### Implementation for User Story 5

- [X] T027 [P] [US5] Create `ApiEndpoints` class (private constructor, static `const String` fields + static `String` methods for parameterized paths) in `lib/core/constants/api_endpoints.dart`, containing every entry enumerated in [contracts/api_endpoints.contract.md § 1](contracts/api_endpoints.contract.md), grouped by `// region <section>` / `// endregion` per research § R-010

**Checkpoint**: Catalog in place. No data source is migrated in this
feature, so the catalog has no consumers yet; the first migrated
feature will be its first caller.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Land the Error-interceptor seat (FR-011), verify release
silence manually, run the linter, and validate the quickstart walk-through.

- [X] T028 [P] Create `ErrorInterceptor` that catches `DioException` in the response-error branch and rethrows a new `DioException` whose `error` field holds `UnexpectedFailure(originalException.message ?? 'Unexpected error')`, preserving `type`, `response`, and `requestOptions` — in `lib/core/network/interceptors/error_interceptor.dart`; see data-model § 5 and research § R-007
- [X] T029 Insert `ErrorInterceptor()` as pipeline position **#3** (last) in [lib/core/network/api_client.dart](../../lib/core/network/api_client.dart); depends on T017, T021, T024, and T028
- [X] T030 [P] Unit test: `ErrorInterceptor` rewrites `DioException.error` to a `Failure` instance; preserves other `DioException` fields — in `test/core/network/interceptors/error_interceptor_test.dart`
- [X] T031 Run `flutter analyze` against the full project and resolve any warnings introduced by the tightened lints from T002 (only in new files under `lib/core/{network,di,error,storage,constants/api_endpoints.dart}` — do NOT fix legacy-file warnings in this feature). **Result**: 7 warnings, all in pre-existing legacy files (`lib/core/localization/app_localizations.dart` — 4× `equal_keys_in_map`; `lib/core/theme/app_theme.dart` — 3× deprecated `withOpacity`). Zero warnings in new code — per the task's own scope restriction, legacy warnings are left untouched.
- [X] T032 Run `flutter test test/core/` end-to-end and confirm all interceptor + DI + endpoints tests pass on both a clean `getIt` and after a `resetLocator()` cycle. **Result**: 32/32 tests pass.
- [ ] T033 **DEFERRED (manual)** Release-silence verification per [quickstart.md](quickstart.md) § "Inspect traffic during development": `flutter build apk --release`, install, log in, perform an authenticated request, verify `adb logcat` shows zero `[API]` or payload lines; record the result as a one-line note in the PR description. Cannot be automated — `kDebugMode` is a compile-time constant. Responsibility passes to the human reviewer before merge.
- [X] T034 Quickstart walk-through: create a disposable data source in a scratch file that imports `Dio` + `ApiEndpoints`, resolves via `getIt<Dio>()`, calls `ApiEndpoints.regions`, confirm the flow compiles and runs end-to-end; delete the scratch file before merge. **Adapted**: kept as a permanent test file at `test/core/quickstart_walkthrough_test.dart` instead of a throwaway — it guards the pipeline order and the data-source-shape compilation contract on every future test run, which is strictly more valuable than a one-shot scratch file.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. T001 (pubspec.yaml) unlocks every `package:get_it` / `package:dio` import downstream. T002 and T003 are independent.
- **Phase 2 (Foundational)**: Depends on Phase 1. BLOCKS every user story.
  - T004, T005, T006, T007 are independent ([P]).
  - T008 depends on T005 + T006 (imports both).
  - T009 depends on T008.
  - T010 is independent.
- **Phase 3 (US1)**: Depends on Phase 2. MVP cut-line. After US1 ships, subsequent stories are additive.
- **Phase 4 (US2)**, **Phase 5 (US3)**, **Phase 6 (US4)**, **Phase 7 (US5)**: Each depends on Phase 2 + US1 (all need the `ApiClient`/`Dio` seat in place).
  - Interceptor creation tasks (T016, T020, T023, T028) are `[P]` — different files, independent.
  - Interceptor *insertion* tasks (T017, T021, T024, T029) all edit `api_client.dart` — serialized.
  - Legacy-provider edits (T018, T025) edit different files — independent ([P]) and unrelated to the Dio pipeline ordering.
  - US5 (T026, T027) has zero dependency on any other user story; can be done any time after Phase 2.
- **Phase 8 (Polish)**: Depends on US1–US4 landing their pipeline positions. T033 additionally requires a release build of the full pipeline.

### Within Each User Story

- Tests are written **first** and observed to fail (red) before the implementation lands — per Constitution V ("Lint is a gate") interpreted for unit tests.
- Interceptor file created (new file) → pipeline insertion (edit `api_client.dart`).
- Legacy-provider one-liners can land independently of the interceptor insertion (no ordering coupling).

### Parallel Opportunities

- Phase 1: T002 and T003 can run in parallel after T001.
- Phase 2: T004, T005, T006, T007, T010 can all run in parallel. T008 waits for T005 + T006. T009 waits for T008.
- Phase 3 (US1): T011, T012, T013 can start in parallel (T012 extends an existing test file but adds new cases; if that becomes a conflict, treat as sequential). T014 depends on T008 and T013.
- Phases 4–7 (US2, US3, US4, US5) after US1: interceptor *creation* tasks (T016, T020, T023) and US5 tasks (T026, T027) are all parallelizable; *insertion* tasks (T017, T021, T024) serialize on `api_client.dart`.
- Phase 8: T028 and T030 are parallel; T029 depends on all four interceptor insertions.

---

## Parallel Example: User Story 1

```text
# Kick off US1 tests and implementation together; all edit different files:
Task T011 [P] [US1] Unit test ApiClient BaseOptions → test/core/network/api_client_test.dart
Task T012 [P] [US1] Extend service_locator_test with Dio-singleton-identity case
Task T013 [P] [US1] Create ApiClient.create() → lib/core/network/api_client.dart

# Then, sequentially:
Task T014 [US1] Register Dio in setupLocator() → edit lib/core/di/service_locator.dart
```

## Parallel Example: US2 + US3 + US4 (after US1 lands)

```text
# All three interceptors can be created in parallel (different new files):
Task T016 [P] [US2] Create AuthInterceptor       → lib/core/network/interceptors/auth_interceptor.dart
Task T020 [P] [US3] Create LoggingInterceptor    → lib/core/network/interceptors/logging_interceptor.dart
Task T023 [P] [US4] Create LanguageInterceptor   → lib/core/network/interceptors/language_interceptor.dart

# Then insertions serialize on api_client.dart (positions #0, #1, #2):
Task T017 [US2] Insert #0 AuthInterceptor        → edit lib/core/network/api_client.dart
Task T024 [US4] Insert #1 LanguageInterceptor    → edit lib/core/network/api_client.dart
Task T021 [US3] Insert #2 LoggingInterceptor     → edit lib/core/network/api_client.dart

# Legacy-provider edits are independent and can run any time after Phase 2:
Task T018 [US2] Guarded setToken/clear           → edit lib/providers/auth_provider.dart
Task T025 [US4] Guarded setLanguageCode          → edit lib/providers/app_provider.dart
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Complete Phase 1: Setup (pubspec dep, lints, layer stubs).
2. Complete Phase 2: Foundational (readers, Failure, locator skeleton, main.dart wiring).
3. Complete Phase 3: US1 (bare `Dio` resolvable via `getIt`).
4. **Stop and validate**: Unit tests green; manual GET against `regions` succeeds.
5. Merge the MVP slice. Every subsequent story layers on top without breaking it.

### Incremental Delivery (recommended)

1. MVP (US1) → merge → tag as `v0.1-core-network`.
2. US2 (Auth) → merge → tag as `v0.2-core-auth`; authenticated features can now start migrating.
3. US3 (Logging) → merge → devs get readable debug traces.
4. US4 (Language) → merge → server-localized responses correct in all three locales.
5. US5 (Endpoints catalog) → merge → catalog ready for first migrated data source.
6. Polish (ErrorInterceptor seat + release-silence verification + analyze) → merge → feature complete.

Each merge is independently shippable — the legacy `ApiService` continues to handle every feature that hasn't been migrated yet, so no end-user regression is possible at any step.

### Solo vs parallel development

- **Solo**: follow the linear order T001 → T034. Each checkpoint is a safe commit point.
- **Two devs**: after MVP (US1), split US2+US3 vs US4+US5 between people. The only shared file is `api_client.dart` (interceptor insertion line); coordinate via a short-lived diff or a single "wire interceptors" PR that merges after each dev's interceptor is created.

---

## Notes

- `[P]` means "different files, no dependency on an incomplete task in this list" — not "safe to run concurrently without any thought." Still check that the files really are disjoint before launching parallel work.
- Legacy files (`lib/providers/**`, `lib/services/**`, `lib/screens/**`, `lib/models/**`) are **not** touched by this feature except for the two guarded one-liners in T018 and T025. Any other legacy edit is out of scope and requires a separate task.
- Tests: every interceptor has a unit test. The release-silence check (US3) is manual because `kDebugMode` is compile-time; no test harness can meaningfully exercise release builds.
- After T034, the feature is done; open the PR targeting `main` and run the `/speckit.analyze` command if you want a pre-merge audit.
