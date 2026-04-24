---

description: "Task list for feature 002-auth-login-register implementation"
---

# Tasks: Auth (Login + Register) — Clean Architecture Migration

**Input**: Design documents from `/specs/002-auth-login-register/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Included. Spec FR-018 requires unit tests for the Cubit state
transitions and widget tests for the happy / failure paths on the new
pages. Research § R-004 / R-009 / R-013 expand the scope: every
`AuthResponseParser` case (FR-007 preservation guard), every `Cubit`
transition, plus repository idempotency and token-side-effect
assertions.

**Organization**: Tasks are grouped by user story, but USs 3 and 4
(Cubit/UI separation; DRY custom widgets) are **structural
requirements embedded across every story** — they do not get their
own phases. Phase 1 creates the app-wide widget library that US4
depends on; the architecture layering (Phase 2 + US1 + US2) delivers
US3. The Polish phase adds grep-level structural guards.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story the task belongs to (US1 / US2 / US5)
- Every task includes an exact file path

## Path Conventions

Flutter mobile-app single-project layout (plan.md § Project Structure).
New code lands under `lib/{domain,data,presentation}/auth/**`,
`lib/{domain,data}/locations/**`, and `lib/presentation/widgets/**`.
Legacy touches are limited to (a) `lib/providers/auth_provider.dart`
(two new methods), (b) seven navigation call sites in legacy screens,
(c) `lib/core/localization/app_localizations.dart` (17 new keys), and
(d) deletion of `lib/screens/auth/{login,register}_screen.dart` at
the end of the feature.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the four new dev/prod dependencies, introduce all
localization keys needed by every error message and user-type label,
and ship the five app-wide custom widgets that both the login and
register pages consume.

- [X] T001 Add `flutter_bloc: ^8.1.6`, `equatable: ^2.0.7` under `dependencies`, and `bloc_test: ^9.1.7`, `mocktail: ^1.0.4` under `dev_dependencies` in [pubspec.yaml](../../pubspec.yaml); run `flutter pub get`
- [X] T002 [P] Add 13 auth-error localization keys (`auth_error_invalid_credentials`, `auth_error_account_pending`, `auth_error_account_blocked`, `auth_error_email_exists`, `auth_error_phone_exists`, `auth_error_invalid_email`, `auth_error_invalid_phone`, `auth_error_weak_password`, `auth_error_missing_fields`, `auth_error_validation_failed`, `auth_error_network`, `auth_error_unknown_login`, `auth_error_unknown_register`) to all three locale blocks (`ar` / `he` / `en`) in [lib/core/localization/app_localizations.dart](../../lib/core/localization/app_localizations.dart); use the Arabic values verbatim in all three blocks per research § R-005
- [X] T003 [P] Add 4 user-type localization keys (`user_type_renter`, `user_type_owner`, `user_type_office`, `user_type_car_lessor`) to all three locale blocks in [lib/core/localization/app_localizations.dart](../../lib/core/localization/app_localizations.dart); use the existing hardcoded Arabic labels from [lib/screens/auth/register_screen.dart](../../lib/screens/auth/register_screen.dart) verbatim in all three blocks
- [X] T004 [P] Create `AppTextField` (themed wrapper over `TextFormField` — controller, labelKey, hintKey?, prefixIcon?, keyboardType?, textDirection?, validator?; reads labels via `ctx.tr(labelKey)`) in `lib/presentation/widgets/app_text_field.dart`; see data-model § 5.1
- [X] T005 [P] Create `AppPasswordField` (self-contained obscure-toggle + visibility icon — controller, labelKey, validator?) in `lib/presentation/widgets/app_password_field.dart`
- [X] T006 [P] Create `AppPrimaryButton` (`ElevatedButton` wrapper with built-in `isLoading` state that disables the button and shows a 20×20 spinner) in `lib/presentation/widgets/app_primary_button.dart`
- [X] T007 [P] Create `AppErrorBanner` (red-tinted container with icon; `null`/empty message renders `SizedBox.shrink()`) in `lib/presentation/widgets/app_error_banner.dart`
- [X] T008 [P] Create `AppFormScaffold` (Scaffold + AppBar + SafeArea + SingleChildScrollView + padded Form; accepts `titleKey`, `children`, optional `formKey`) in `lib/presentation/widgets/app_form_scaffold.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the full Domain + Data layer stack that both US1 and
US2 consume, wire it into DI, add the two legacy-bridge methods to
`AuthProvider`, and stand up the error-message mapper.

**⚠️ CRITICAL**: No user story may begin until this phase is complete.

### Domain layer

- [X] T009 [P] Create `UserType` enum with `.apiValue` and `.labelKey` methods per data-model § 1.3 in `lib/domain/auth/entities/user_type.dart`
- [X] T010 [P] Create `AuthCredentials` entity (`login`, `password`; Equatable) in `lib/domain/auth/entities/auth_credentials.dart`
- [X] T011 [P] Create `Session` entity (token + identity fields + `rawUserJson: Map<String,Object?>`; Equatable) per data-model § 1.4 in `lib/domain/auth/entities/session.dart`
- [X] T012 [US2-prereq] Create `RegisterDetails` entity per data-model § 1.2 in `lib/domain/auth/entities/register_details.dart`; depends on T009 (UserType)
- [X] T013 [US2-prereq] Create `RegisterOutcome` sealed class (variants `RegisterAuthenticated`, `RegisterPendingApproval`, `RegisterNeedsVerification`) in `lib/domain/auth/entities/register_outcome.dart`; depends on T011 (Session)
- [X] T014 [P] Create `AuthFailureReason` enum with 13 variants per research § R-003 in `lib/domain/auth/auth_failure_reason.dart`
- [X] T015 Create `AuthRepository` abstract interface + `AuthException` class in `lib/domain/auth/auth_repository.dart`; depends on T010, T011, T012, T013, T014
- [X] T016 [P] Create `Region` entity (id + nameAr/nameEn/nameHe; Equatable) in `lib/domain/locations/region.dart`
- [X] T017 [P] Create `City` entity (id + regionId + nameAr/nameEn/nameHe; Equatable) in `lib/domain/locations/city.dart`
- [X] T018 Create `LocationsRepository` abstract interface + `LocationsException` class in `lib/domain/locations/locations_repository.dart`; depends on T016, T017

### Data layer

- [X] T019 [P] Create `UserDto.fromJson(Map)` with `toDomain()` → `User` fields (Session expects them nested) in `lib/data/auth/dtos/user_dto.dart`
- [X] T020 Create `SessionDto.fromJson(Map)` with `toDomain() → Session` (preserves raw user map) in `lib/data/auth/dtos/session_dto.dart`; depends on T011, T019
- [X] T021 [P] Create `RegionDto.fromJson(Map)` with `toDomain() → Region` in `lib/data/locations/dtos/region_dto.dart`; depends on T016
- [X] T022 [P] Create `CityDto.fromJson(Map)` with `toDomain() → City` in `lib/data/locations/dtos/city_dto.dart`; depends on T017
- [X] T023 Create `AuthRemoteDataSource` with `login({login, password})` and `register({body})` methods calling `getIt<Dio>()` against `ApiEndpoints.authLogin` / `ApiEndpoints.authRegister`, returning raw response maps in `lib/data/auth/auth_remote_datasource.dart`
- [X] T024 [P] Create `LocationsRemoteDataSource` with `fetchRegions()` and `fetchCities()` against `ApiEndpoints.regions` / `ApiEndpoints.cities` in `lib/data/locations/locations_remote_datasource.dart`
- [X] T025 Create `AuthResponseParser` with `parseLogin`, `parseRegister`, and `fromDioException` static methods per data-model § 2.3 and research § R-004; classifies every legacy `_translateLoginError` / `_translateRegisterError` case into the right `AuthFailureReason` — in `lib/data/auth/auth_response_parser.dart`; depends on T014, T020, T013
- [X] T026 Create `AuthRepositoryImpl` that delegates to `AuthRemoteDataSource`, maps via `AuthResponseParser`, pushes the token into `TokenReader` on success, and throws `AuthException` on failure — in `lib/data/auth/auth_repository_impl.dart`; depends on T015, T023, T025 + existing `TokenReader`
- [X] T027 Create `LocationsRepositoryImpl` wrapping `LocationsRemoteDataSource` with DTO → entity mapping in `lib/data/locations/locations_repository_impl.dart`; depends on T018, T024, T021, T022

### DI wiring

- [X] T028 Register `AuthRemoteDataSource` (factory), `LocationsRemoteDataSource` (factory), `AuthRepository` (lazy singleton), `LocationsRepository` (lazy singleton) in [lib/core/di/service_locator.dart](../../lib/core/di/service_locator.dart) per contracts/auth_repository.contract.md § 5; depends on T026, T027

### Legacy-bridge additions

- [X] T029 Add `hydrateFromSession(Session)` and `clearSession()` public methods to [lib/providers/auth_provider.dart](../../lib/providers/auth_provider.dart) per data-model § 4 and contracts/legacy_bridge.contract.md § 2; preserve the existing FCM topic subscribe/unsubscribe behaviour by calling the same code paths `_saveAuth` and `logout` use today; depends on T011 (Session)

### Presentation-layer shared helper

- [X] T030 Create `AuthOperation` enum (`login`, `register`) + pure `String failureReasonToMessage(BuildContext, AuthFailureReason, {required AuthOperation op})` function that reads `AppLocalizations` via the reason-to-key table from research § R-005; place in `lib/presentation/auth/auth_error_messages.dart`; depends on T014, T002 (localization keys)

### Foundational tests

- [X] T031 [P] Unit test: `UserDto.fromJson` + `SessionDto.fromJson` parse the legacy response shape correctly; `toDomain()` preserves `rawUserJson` — in `test/data/auth/session_dto_test.dart`
- [X] T032 [P] Unit test: `AuthResponseParser.parseLogin` / `parseRegister` / `fromDioException` table-driven over every legacy case from `_translateLoginError` / `_translateRegisterError` (invalid/credentials, pending/approval, blocked, email exists, phone exists, invalid email, invalid phone, password-length, required, validation, plus DioExceptionType.connectionTimeout/connectionError/badResponse) — in `test/data/auth/auth_response_parser_test.dart`
- [X] T033 [P] Unit test: `AuthRepositoryImpl.login` happy path pushes token to `TokenReader` and returns `Session`; failure paths throw `AuthException(reason)` instead of leaking `DioException`; `register` produces each `RegisterOutcome` variant based on response shape — in `test/data/auth/auth_repository_impl_test.dart`; uses a fake `AuthRemoteDataSource` + fake `TokenReader`
- [X] T034 [P] Unit test: `LocationsRepositoryImpl` maps DTO lists to entity lists preserving localized name fields — in `test/data/locations/locations_repository_impl_test.dart`

**Checkpoint**: Foundation complete. Domain + Data + DI are wired and
covered by tests. `AuthProvider` has its bridge methods. The error
mapper compiles. `flutter test test/data/` passes.

---

## Phase 3: User Story 1 — Existing user logs in through the migrated login screen (Priority: P1) 🎯 MVP

**Goal**: Replace the legacy `LoginScreen` with a new `LoginPage`
backed by `LoginCubit` and the shared `AuthRepository`. Every
navigation target that previously pointed at `LoginScreen` now points
at `loginRoute()`. The user-visible behaviour — speed, Arabic error
messages, pending/blocked handling — is preserved end-to-end.

**Independent Test**: Install the app, submit known-good credentials
on the new login page, confirm navigation to the main screen and that
a subsequent authenticated API call succeeds (the token interceptor
sees the new token). Submit a known-bad pair and confirm the same
Arabic error message as today. Submit a pending-account credential
and confirm the "account under review" message.

### Tests for User Story 1

- [X] T035 [P] [US1] Unit test: `LoginCubit` state sequences — `[Submitting, Succeeded(session)]` on happy path; `[Submitting, Failed(reason)]` for each `AuthFailureReason` (table-driven using `bloc_test.blocTest`); second `submit()` while `Submitting` is a no-op (FR-013 / SC-009); `reset()` transitions `Failed → Initial` — in `test/presentation/auth/cubits/login_cubit_test.dart`; uses a `_MockAuthRepository extends Mock implements AuthRepository` from `mocktail`
- [X] T036 [P] [US1] Widget test: `LoginPage` happy path — `pumpWidget` with a `BlocProvider` holding a controlled `LoginCubit`, emit `Succeeded(session)`, verify `pushAndRemoveUntil` fires exactly once and `hydrateFromSession` is called on a fake `AuthProvider`; failure path — emit `Failed(reason)`, verify `AppErrorBanner` renders the localized message — in `test/presentation/auth/pages/login_page_test.dart`

### Implementation for User Story 1

- [X] T037 [P] [US1] Create `LoginState` sealed class with variants `LoginInitial`, `LoginSubmitting`, `LoginSucceeded(Session)`, `LoginFailed(AuthFailureReason)`; Equatable — in `lib/presentation/auth/cubits/login/login_state.dart`; depends on T011, T014
- [X] T038 [P] [US1] Create `LoginCubit` with `submit(AuthCredentials)` (idempotent while `Submitting`) and `reset()` methods per contracts/cubits.contract.md § 1 — in `lib/presentation/auth/cubits/login/login_cubit.dart`; depends on T015, T037
- [X] T039 [US1] Create `LoginPage` using `AppFormScaffold` + `AppTextField` (phone/email) + `AppPasswordField` + `AppErrorBanner` + `AppPrimaryButton`; wire submit via `context.read<LoginCubit>().submit(...)`; wire post-success via `BlocListener` that calls `context.read<AuthProvider>().hydrateFromSession(state.session)` then navigates to `MainScreen`; include the "forgot password?" link (still points at legacy `ForgotPasswordScreen`) and the "no account? register" link (points at `registerRoute()` — the route exists after US2 but the call compiles; if US2 hasn't landed yet, temporarily keep the legacy `RegisterScreen` import) — in `lib/presentation/auth/pages/login_page.dart`; depends on T004-T008, T029, T030, T038
- [X] T040 [US1] Create `loginRoute()` helper function in `lib/presentation/auth/auth_routes.dart` that returns a `MaterialPageRoute` wrapping `LoginPage` in a `BlocProvider(create: (_) => LoginCubit(repository: getIt<AuthRepository>()))` per contracts/cubits.contract.md § 3; depends on T038, T039

### Route call-site updates (LoginScreen → loginRoute)

- [X] T041 [P] [US1] Replace `MaterialPageRoute(builder: (_) => const LoginScreen())` with `loginRoute()` at [lib/screens/home/home_screen.dart:97](../../lib/screens/home/home_screen.dart#L97); remove the now-unused `LoginScreen` import; depends on T040
- [X] T042 [P] [US1] Same swap at [lib/screens/splash_screen.dart:98](../../lib/screens/splash_screen.dart#L98) (handles `pageBuilder` form differently — see file context); depends on T040
- [X] T043 [P] [US1] Same swap at [lib/screens/my_listings/my_listings_screen.dart:126](../../lib/screens/my_listings/my_listings_screen.dart#L126); depends on T040
- [X] T044 [P] [US1] Same swap at [lib/screens/profile/profile_screen.dart:351](../../lib/screens/profile/profile_screen.dart#L351); depends on T040
- [X] T045 [P] [US1] Same swap at [lib/screens/packages/packages_screen.dart:198](../../lib/screens/packages/packages_screen.dart#L198); depends on T040
- [X] T046 [P] [US1] Same swap at [lib/screens/listing_details/listing_details_screen.dart:812 and :975](../../lib/screens/listing_details/listing_details_screen.dart#L812) (two sites in one file); depends on T040

**Checkpoint**: Users can log in via the new `LoginPage` from every
entry point the legacy `LoginScreen` used to serve. `LoginCubit` unit
tests and `LoginPage` widget test green. Legacy `login_screen.dart`
file still physically exists but is no longer referenced externally
(it still links to `RegisterScreen` internally; US2 fixes that before
US5 deletes it). **This is the MVP cut-line** — US1 is independently
shippable if registration is allowed to remain on the legacy path
(it isn't, per the feature scope, but the system works).

---

## Phase 4: User Story 2 — New user registers through the migrated register screen (Priority: P1)

**Goal**: Replace the legacy `RegisterScreen` with a new
`RegisterPage` backed by `RegisterCubit`. The register form covers
all branching outcomes (immediate authentication, pending approval,
verification required), preserves the landlord-specific region/city
flow, and uses the shared custom widgets plus four auth-scoped
widgets (`UserTypeSelector`, `TermsCheckbox`, `RegionPicker`,
`CityPicker`).

**Independent Test**: Submit a new renter registration, confirm the
flow outcome matches today (immediate authentication, or the pending
/ verification screen with the same text). Repeat for landlord,
confirming the region → city dependency still works. Submit a
duplicate email and confirm the same Arabic error message.

### Tests for User Story 2

- [X] T047 [P] [US2] Unit test: `RegisterCubit` — `loadLocations()` populates `regions` / `cities` and flips `isLocationsLoading`; `submit()` emits `[Submitting, SucceededAuthenticated]` when the server returns a token; `[Submitting, PendingApprovalState(msg)]` and `[Submitting, NeedsVerificationState(msg)]` for the approval / verification branches; `[Submitting, Failed(reason)]` per `AuthFailureReason`; double-submit is idempotent — in `test/presentation/auth/cubits/register_cubit_test.dart`; uses `mocktail` mocks of both `AuthRepository` and `LocationsRepository`
- [X] T048 [P] [US2] Widget test: `RegisterPage` happy path — pump with `BlocProvider`, locations loaded, submit successful, verify navigation + `hydrateFromSession`; also test the `isLandlord` conditional (company-name + region-picker visibility toggles when user type changes) — in `test/presentation/auth/pages/register_page_test.dart`

### Auth-scoped custom widgets (used only by register in this PR; reused by subsequent auth migrations)

- [X] T049 [P] [US2] Create `UserTypeSelector` (Wrap of 4 `ChoiceChip`s labelled via `UserType.labelKey`; `value`, `onChanged(UserType)`) in `lib/presentation/auth/widgets/user_type_selector.dart`; depends on T009
- [X] T050 [P] [US2] Create `TermsCheckbox` (Checkbox + RichText with a tappable "terms" link that opens the existing Arabic terms dialog; the dialog content moves into a private `_TermsDialog` helper widget in the same file) in `lib/presentation/auth/widgets/terms_checkbox.dart`
- [X] T051 [P] [US2] Create `RegionPicker` (DropdownButtonFormField of `Region` entities; disabled while empty/loading) in `lib/presentation/auth/widgets/region_picker.dart`; depends on T016
- [X] T052 [P] [US2] Create `CityPicker` (DropdownButtonFormField of `City` filtered by `selectedRegionId`; resets selection when region changes and current city doesn't match) in `lib/presentation/auth/widgets/city_picker.dart`; depends on T017

### Cubit + page

- [X] T053 [P] [US2] Create `RegisterState` sealed class with variants per contracts/cubits.contract.md § 2 — base fields `regions` / `cities` / `isLocationsLoading` on every variant, concrete variants `RegisterInitial`, `RegisterLocationsFailed`, `RegisterSubmitting`, `RegisterSucceededAuthenticated(Session)`, `RegisterPendingApprovalState(String)`, `RegisterNeedsVerificationState(String)`, `RegisterFailed(AuthFailureReason)` — in `lib/presentation/auth/cubits/register/register_state.dart`; depends on T011, T013, T014, T016, T017
- [X] T054 [P] [US2] Create `RegisterCubit` with `loadLocations()` and `submit(RegisterDetails)` per contracts/cubits.contract.md § 2 in `lib/presentation/auth/cubits/register/register_cubit.dart`; depends on T015, T018, T053
- [X] T055 [US2] Create `RegisterPage` composing `AppFormScaffold` + name/email/phone `AppTextField`s + `AppPasswordField` × 2 (password + confirm) + `UserTypeSelector` + conditional (landlord-only) company-name field + `RegionPicker` + `CityPicker` + `TermsCheckbox` + `AppErrorBanner` + `AppPrimaryButton`; confirm-password validation happens in the form (presentation-only per research § R-012); `BlocListener` handles all three success variants: `SucceededAuthenticated` → hydrate + navigate to `MainScreen`; `PendingApprovalState` / `NeedsVerificationState` → show the same dialog/snackbar UX the legacy screen produced; depends on T004-T008, T029, T030, T049-T052, T054

### Route wiring

- [X] T056 [US2] Add `registerRoute()` helper to [lib/presentation/auth/auth_routes.dart](../../lib/presentation/auth/auth_routes.dart) that wraps `RegisterPage` in a `BlocProvider` and kicks off `..loadLocations()` on construction per contracts/cubits.contract.md § 3; depends on T054, T055
- [X] T057 [US2] Update the "no account? register" link in [lib/presentation/auth/pages/login_page.dart](../../lib/presentation/auth/pages/login_page.dart) to use `Navigator.push(context, registerRoute())` (and remove any remaining legacy `RegisterScreen` import); depends on T056

**Checkpoint**: Users can register via the new `RegisterPage` for
every user type, including landlord with region/city. All acceptance
scenarios from spec US2 pass. `RegisterCubit` + `RegisterPage` tests
green. Legacy `login_screen.dart` and `register_screen.dart` files
still physically exist but are no longer referenced from any live
call site.

---

## Phase 5: User Story 5 — Legacy login/register are removed (Priority: P3)

**Goal**: Physically delete the two legacy files and confirm the repo
contains exactly one login path and one register path.

**Independent Test**: After this phase, `grep -R 'LoginScreen'
lib/` and `grep -R 'RegisterScreen' lib/` return zero matches.
`flutter analyze` reports no unresolved references. The app builds
and runs end-to-end.

### Implementation for User Story 5

- [X] T058 [US5] Delete [lib/screens/auth/login_screen.dart](../../lib/screens/auth/login_screen.dart); depends on T041-T046 (all call-site updates) and T039 (new page exists)
- [X] T059 [US5] Delete [lib/screens/auth/register_screen.dart](../../lib/screens/auth/register_screen.dart); depends on T057 (last call-site removed) and T055 (new page exists)
- [X] T060 [US5] Verify deletion completeness: run `grep -R 'LoginScreen\|RegisterScreen' lib/ --include='*.dart'` and confirm zero matches; run `flutter analyze` and confirm no unresolved-import warnings introduced

**Checkpoint**: Legacy auth screens are gone. The codebase contains
exactly one login flow and one register flow.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Enforce the structural guarantees from US3 (Cubit/UI
separation) and US4 (DRY custom widgets) via grep checks, run the
full test suite, run the analyzer, and spot-check the three-locale
behaviour.

- [X] T061 [P] Structural guard for US3: `grep -E 'http\.|package:dio|SharedPreferences|ApiService|notifyListeners' lib/presentation/auth/pages/` — expect zero matches; `grep -E 'BlocBuilder|BlocListener|BlocConsumer|context\.read<.*Cubit>' lib/presentation/auth/pages/` — expect ≥ 2 matches per page. Record results in the PR description (SC-003)
- [X] T062 [P] Structural guard for US4: `grep -E 'Color\(|EdgeInsets|TextStyle\(' lib/presentation/auth/pages/{login_page,register_page}.dart` — expect zero matches (all styling comes from theme / custom widgets, SC-005). Confirm `grep` shows both pages importing the same `AppTextField` / `AppPrimaryButton` / `AppFormScaffold` / `AppErrorBanner` symbols
- [X] T063 Run `flutter analyze` across the full project; zero warnings in new code under `lib/{domain,data,presentation}/auth/**`, `lib/{domain,data}/locations/**`, `lib/presentation/widgets/**`, and `lib/presentation/auth/**`. Pre-existing warnings in unrelated legacy files remain out of scope (same policy as feature 001 T031)
- [X] T064 Run `flutter test` end-to-end; all tests pass — the new ones under `test/data/**`, `test/presentation/auth/**` plus every test from feature 001 that lives under `test/core/**`
- [X] T065 Three-locale smoke check: launch the app with `ar`, `he`, and `en` as the active language (one at a time), open the login page, trigger a known failure (bad credentials), confirm the `AppErrorBanner` shows the same Arabic string in every locale (expected per research § R-005's "same Arabic value in all three locales initially"). Record in the PR description as a one-line note
- [ ] T066 **DEFERRED (manual)** Manual end-to-end verification — run on an emulator: (a) log in with valid credentials → reach `MainScreen`, authenticated API call succeeds; (b) log in with bad credentials → Arabic error banner; (c) register as renter with unique details → success flow; (d) register as landlord → region/city pickers work, success flow; (e) log out and confirm navigation back to login works. Record results as a short checklist in the PR description. Cannot be automated — requires an emulator + live backend. Responsibility passes to the human reviewer before merge.
- [X] T067 Update [CLAUDE.md](../../CLAUDE.md) to mark 002 as merged-or-in-review, and add a line for the next planned migration (to be chosen by the user)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. T001 unlocks every `flutter_bloc` / `bloc_test` / `mocktail` / `equatable` import downstream. T002–T008 can all run in parallel after T001 (the 5 widgets + 2 localization batches are all different files).
- **Phase 2 (Foundational)**: Depends on Phase 1.
  - Domain layer: T009–T011, T014, T016, T017 are each independent ([P]). T012 depends on T009. T013 depends on T011. T015 depends on T010/T011/T012/T013/T014. T018 depends on T016/T017.
  - Data layer: T019, T021, T022, T024 are each independent ([P]). T020 depends on T011 + T019. T023 depends on data-source needs (no other Data-layer task blocks it). T025 depends on T014, T020. T026 depends on T015, T023, T025. T027 depends on T018, T024, T021, T022.
  - DI (T028) depends on T026, T027.
  - Legacy-bridge (T029) depends on T011.
  - Error mapper (T030) depends on T014 + T002.
  - Foundational tests (T031–T034) each depend on the unit they test; all [P] relative to each other.
- **Phase 3 (US1 = MVP)**: Depends on Phase 2. This phase is the hard MVP floor — US2 and US5 are not required to ship US1's value.
- **Phase 4 (US2)**: Depends on Phase 2. Can run partially in parallel with Phase 3 (different files, different Cubit/page). Only T057 depends on Phase 3 completing (it edits the file Phase 3 created).
- **Phase 5 (US5 — deletions)**: Depends on Phase 3 AND Phase 4 fully complete (all call-site updates must land before deletions).
- **Phase 6 (Polish)**: Depends on Phase 5 complete. T063–T066 are end-to-end verification; T067 is the final doc update.

### Within Each User Story

- **US1**: tests (T035–T036) are written in parallel with implementation. T037 (State) and T038 (Cubit) are [P] relative to each other but both precede T039 (Page). T040 (route helper) depends on T038 + T039. Route call-site updates (T041–T046) depend on T040 and are all [P].
- **US2**: same shape. Auth-scoped widgets (T049–T052) are each [P]. T053 (State) and T054 (Cubit) are [P]. T055 (Page) depends on widgets + Cubit. T056 (route helper) depends on T054 + T055. T057 (LoginPage edit) depends on T056.
- **US5**: T058 and T059 are both [P] (different files). T060 (verification) depends on both.

### Parallel Opportunities

- Phase 1: T002–T008 after T001 (7 parallel tasks).
- Phase 2 Domain: T009–T011, T014, T016, T017 in parallel (6 tasks). Follow-ups T012, T013, T015, T018 serialise on their specific deps.
- Phase 2 Data: T019, T021, T022, T024 in parallel (4 tasks). Follow-ups T020, T025, T026, T027 serialise.
- Phase 2 Tests: T031–T034 in parallel (4 tasks).
- Phase 3 (US1) + Phase 4 (US2) can run in parallel except for T057 (edits a file created in Phase 3) and the structural-guard tasks in Phase 6.

---

## Parallel Example: Foundational Domain

```text
# Six independent Domain entities / interfaces can be created in parallel:
Task T009 [P] UserType enum                → lib/domain/auth/entities/user_type.dart
Task T010 [P] AuthCredentials entity       → lib/domain/auth/entities/auth_credentials.dart
Task T011 [P] Session entity               → lib/domain/auth/entities/session.dart
Task T014 [P] AuthFailureReason enum       → lib/domain/auth/auth_failure_reason.dart
Task T016 [P] Region entity                → lib/domain/locations/region.dart
Task T017 [P] City entity                  → lib/domain/locations/city.dart

# Then, serialised on their deps:
Task T012 [US2-prereq] RegisterDetails     (depends on T009)
Task T013 [US2-prereq] RegisterOutcome     (depends on T011)
Task T015 AuthRepository interface         (depends on T010, T011, T012, T013, T014)
Task T018 LocationsRepository interface    (depends on T016, T017)
```

## Parallel Example: US1 + US2 interleaved after Foundational

```text
# After Phase 2 completes, US1 and US2 can proceed in parallel:

# US1 — independent of US2:
Task T035 [P] [US1] LoginCubit test
Task T036 [P] [US1] LoginPage widget test
Task T037 [P] [US1] LoginState
Task T038 [P] [US1] LoginCubit

# US2 — independent of US1 except for T057:
Task T047 [P] [US2] RegisterCubit test
Task T048 [P] [US2] RegisterPage widget test
Task T049 [P] [US2] UserTypeSelector
Task T050 [P] [US2] TermsCheckbox
Task T051 [P] [US2] RegionPicker
Task T052 [P] [US2] CityPicker
Task T053 [P] [US2] RegisterState
Task T054 [P] [US2] RegisterCubit

# Then serialise each story's page + route:
Task T039 [US1] LoginPage          (depends on T037, T038, widgets from Phase 1)
Task T055 [US2] RegisterPage       (depends on T049–T052, T053, T054, widgets from Phase 1)
Task T040 [US1] loginRoute()       (depends on T039)
Task T056 [US2] registerRoute()    (depends on T055)

# Route call-site updates (US1) and T057 (US2) in parallel:
Task T041–T046 [P] [US1] — 6 files
Task T057      [US2] — edits login_page.dart (depends on T056)
```

---

## Implementation Strategy

### MVP first (US1 only)

1. Phase 1: Setup (pubspec + localization + 5 app-wide widgets) → 8 tasks.
2. Phase 2: Foundational (full Domain + Data + DI + legacy bridge + error mapper + 4 test files) → 26 tasks.
3. Phase 3: US1 (Cubit + Page + route helper + 6 call-site updates + 2 test files) → 12 tasks.
4. **Stop and validate**: `flutter test`, manual smoke test of the login happy path + one error path.
5. Merge as a partial slice **if** the team wants login delivered before register. Legacy `RegisterScreen` keeps working because the `registerRoute()` call in `LoginPage` doesn't exist yet — so `LoginPage` needs a temporary legacy `RegisterScreen` import during this interim slice. If you intend to ship US1-only, add a note on T039 that the "register" link uses `const RegisterScreen()` until T056/T057 land.

### Incremental delivery (recommended — one PR)

1. Land Phase 1 + Phase 2 (foundation is ready for both stories).
2. Land Phase 3 + Phase 4 (pages both exist; route call sites all updated; legacy files still physically present but unreferenced from call sites).
3. Land Phase 5 (deletions) + Phase 6 (polish).
4. Single PR merged to `main` containing all 67 tasks.

### Solo vs parallel development

- **Solo**: follow the phase order T001 → T067. Within a phase, use the parallel markers as a permission slip to not sweat ordering within a phase.
- **Two devs**: after Phase 2, split by story (Dev A on US1 T035–T046, Dev B on US2 T047–T057). Merge conflicts only on `auth_routes.dart` (both add helpers) and `login_page.dart` (US2 T057 edits a file US1 T039 created). Coordinate in one merge checkpoint before Phase 5.

---

## Notes

- **Legacy files touched in this feature**: exactly three (aside from the two deletions) — `lib/providers/auth_provider.dart` (2 new methods), `lib/core/localization/app_localizations.dart` (17 new keys in 3 locale blocks), and the 7 navigation call sites across 6 files. Any other legacy edit is out of scope.
- **Out of scope** (per spec FR-016 / Assumptions): `lib/screens/auth/forgot_password_screen.dart`, `lib/screens/auth/otp_screen.dart`, `lib/screens/auth/reset_password_screen.dart`. These still use `AuthProvider` directly and will migrate in future features.
- **The legacy `AuthProvider`**: stays registered in `MultiProvider` after this feature lands. Its `register()`, `login()`, `logout()`, and related methods remain because the three out-of-scope auth screens still call them.
- **Character-exact Arabic preservation (FR-007)**: the parser test (T032) is the regression guard. If it fails, the spec's hard commitment to "no message regression" has been violated.
- **US3 (Cubit/UI separation) and US4 (DRY widgets)**: have no dedicated tasks because they are structural outcomes of the tasks that build the pages and widgets. They are enforced by the Phase 6 grep checks (T061, T062).
- **Migration-bridge cleanup plan**: documented in [contracts/legacy_bridge.contract.md § 5](contracts/legacy_bridge.contract.md) — the `BlocListener` bridge + `hydrateFromSession`/`clearSession` + the `AuthProvider` registration all delete in the future feature that migrates the last non-auth consumer off Provider.
