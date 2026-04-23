# Implementation Plan: Auth (Login + Register) — Clean Architecture Migration

**Branch**: `002-auth-login-register` | **Date**: 2026-04-23 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-auth-login-register/spec.md`

## Summary

First end-to-end slice of the Clean Architecture / Cubit refactor. Both
the login and register screens are rebuilt under
`lib/{domain,data,presentation}/auth/**` (with a small
`lib/{domain,data}/locations/**` module for the register form's
region/city pickers). Two Cubits (`LoginCubit`, `RegisterCubit`) own
presentation state; a new `AuthRepository` talks to the server through
the feature-001 `Dio` / `ApiEndpoints` / `TokenReader` foundation. Five
app-wide custom widgets + four auth-scoped widgets ship and are used by
both pages. Legacy `login_screen.dart` and `register_screen.dart` are
deleted; seven navigation call sites in legacy screens are updated to
point at the new pages through a small `auth_routes.dart` helper that
hides the `BlocProvider` wiring. The legacy `AuthProvider` stays
registered in `MultiProvider` and gains two methods — `hydrateFromSession`
and `clearSession` — so downstream legacy screens continue to read
`user` / `isLoggedIn` untouched. When a successful auth finishes, a
`BlocListener` in the page pushes the session into the legacy provider
via one `context.read<AuthProvider>()` call. That one-line bridge is
the entire migration scaffold; it deletes when the last non-auth
screen migrates off `AuthProvider` in a later feature.

## Technical Context

**Language/Version**: Dart `^3.8.1` / Flutter (as pinned by [pubspec.yaml](../../pubspec.yaml))
**Primary Dependencies** (added by this feature):
  - `flutter_bloc ^8.1.x` (NEW — Cubit API)
  - `equatable ^2.0.x` (NEW — value-class equality for states and entities)
  - `dio ^5.4.0` (EXISTING — via feature 001)
  - `get_it ^7.7.0` (EXISTING — via feature 001)
**Foundation reused** (from feature 001): `getIt<Dio>()`, `ApiEndpoints`, `TokenReader`, `LocaleReader`, sealed `Failure`
**Storage**: `SharedPreferences` under `StorageKeys.token` / `StorageKeys.user` (unchanged from today)
**Testing**: `flutter_test` + `bloc_test ^9.1.x` (NEW — Cubit-focused test helpers) + `mocktail ^1.0.x` (NEW — lightweight test doubles for the repository)
**Target Platform**: Android + iOS (web guarded, not targeted)
**Project Type**: mobile-app (Flutter)
**Performance Goals**: zero regression vs pre-migration login time-to-authenticated on a mid-range Android; LoginPage / RegisterPage first build < 50 ms after BlocProvider construction
**Constraints**: character-exact preservation of every Arabic error message from `_translateLoginError` / `_translateRegisterError`; three-locale support (`ar`/`he`/`en`); legacy `AuthProvider` MUST keep working for downstream screens; no touches to the three out-of-scope legacy auth screens (`forgot_password_screen.dart`, `otp_screen.dart`, `reset_password_screen.dart`)
**Scale/Scope**: 2 pages migrated; ~30 new files + ~10 legacy files edited + 2 legacy files deleted; 7 navigation call sites updated

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Mapping against [.specify/memory/constitution.md](../../.specify/memory/constitution.md) v2.0.0:

| Principle | Applies? | Status | Notes |
|-----------|----------|--------|-------|
| I. Clean Architecture (NON-NEGOTIABLE) | Yes — first full three-layer slice | ✅ PASS | Strict Domain → Data → Presentation split. Domain imports nothing Flutter/Dio/Bloc. Data imports Dio and talks to Domain interfaces. Presentation imports `flutter_bloc` + Domain. |
| II. Cubit State Management (NON-NEGOTIABLE) | Yes — new screens | ✅ PASS | `LoginCubit` and `RegisterCubit` own state. No `ChangeNotifier`, no `provider` usage in new code. Legacy `AuthProvider` remains only for downstream legacy screens, not consumed by new presentation. |
| III. Dio-based Networking with Wrapper | Yes — data sources | ✅ PASS | Data sources depend on `getIt<Dio>()`; all paths reference `ApiEndpoints.authLogin` / `ApiEndpoints.authRegister` / `ApiEndpoints.regions` / `ApiEndpoints.cities`. Zero raw path strings. |
| IV. DRY through Custom Widgets | Yes — two pages with overlap | ✅ PASS | Five app-wide widgets (`AppTextField`, `AppPasswordField`, `AppPrimaryButton`, `AppErrorBanner`, `AppFormScaffold`) + four auth-scoped (`UserTypeSelector`, `TermsCheckbox`, `RegionPicker`, `CityPicker`). Both pages consume them. No hardcoded colors / text styles / paddings at call sites. |
| V. Simple, Readable, Organized Code | Yes — baseline | ✅ PASS | Target: every new file ≤ 300 lines. Intent-revealing names. Three-layer separation is self-enforcing. The Arabic error strings move location (provider → presentation mapper) but values stay verbatim per FR-007. |

**Gate decision**: PASS — proceeding to Phase 0.

Two points worth calling out before research:

1. **Legacy scaffold kept deliberate small**: the only legacy-code
   additions this feature makes are (a) two new public methods on
   `AuthProvider` — `hydrateFromSession(Session)` and `clearSession()`
   — and (b) seven route-call-site edits in legacy screens. No other
   legacy code is touched.
2. **Locations sub-module**: extracting `Region` / `City` into a
   tiny new `lib/{domain,data}/locations/**` module is slightly more
   files than the minimum, but it matches the constitution's
   three-layer rule and keeps the second consumer (search, edit
   listing, add listing — all future migrations) cheap. Rationale in
   research § R-002.

### Post-Phase-1 Re-check

*Filled in after Phase 1 artefacts are produced.*

| Principle | Re-check | Notes |
|-----------|----------|-------|
| I. Clean Architecture | ✅ PASS | Verified by the contract docs — Domain depends on `dart:core` + `equatable` only; Data imports Dio and Domain; Presentation imports `flutter_bloc` + Domain. |
| II. Cubit State Management | ✅ PASS | Both Cubits consume `AuthRepository` (interface) only; no `Provider` / `ChangeNotifier` in Presentation. |
| III. Dio with wrapper | ✅ PASS | Data-source contract forbids Dio leaks outside `lib/data/auth/**` and `lib/data/locations/**`. |
| IV. DRY | ✅ PASS | Custom-widget inventory in data-model § 5 lists 9 widgets; every one is used ≥ 2 places. |
| V. Simple/Readable | ✅ PASS | Legacy-provider bridge is 2 new methods + one `BlocListener` per page. Error-message mapper is a ~40-line pure function (research § R-005). |

**Gate remains PASS.**

## Project Structure

### Documentation (this feature)

```text
specs/002-auth-login-register/
├── plan.md              # This file
├── research.md          # Phase 0 output — 10 decisions
├── data-model.md        # Phase 1 output — entities, states, widgets
├── quickstart.md        # Phase 1 output — how to add the next migrated auth screen
├── contracts/           # Phase 1 output
│   ├── auth_repository.contract.md
│   ├── cubits.contract.md
│   └── legacy_bridge.contract.md
├── checklists/
│   └── requirements.md  # From /speckit.specify
└── tasks.md             # Produced by /speckit.tasks
```

### Source Code (repository root)

Follows the target Clean Architecture layout locked by constitution v2.0.0.

```text
lib/
├── main.dart                                    # (unchanged)
├── core/
│   ├── di/
│   │   └── service_locator.dart                 # EDIT — add auth + locations feature wiring
│   ├── error/failure.dart                       # (unchanged — provides base Failure)
│   └── localization/app_localizations.dart      # EDIT — ~12 auth-error localization keys
│
├── domain/
│   ├── auth/
│   │   ├── entities/
│   │   │   ├── auth_credentials.dart            # NEW
│   │   │   ├── register_details.dart            # NEW
│   │   │   ├── session.dart                     # NEW
│   │   │   ├── register_outcome.dart            # NEW (sealed union)
│   │   │   └── user_type.dart                   # NEW (enum)
│   │   ├── auth_failure_reason.dart             # NEW (enum — typed auth errors)
│   │   └── auth_repository.dart                 # NEW (interface)
│   └── locations/
│       ├── region.dart                          # NEW
│       ├── city.dart                            # NEW
│       └── locations_repository.dart            # NEW (interface)
│
├── data/
│   ├── auth/
│   │   ├── dtos/
│   │   │   ├── session_dto.dart                 # NEW
│   │   │   └── user_dto.dart                    # NEW
│   │   ├── auth_remote_datasource.dart          # NEW
│   │   ├── auth_response_parser.dart            # NEW (server-message → AuthFailureReason)
│   │   └── auth_repository_impl.dart            # NEW
│   └── locations/
│       ├── dtos/
│       │   ├── region_dto.dart                  # NEW
│       │   └── city_dto.dart                    # NEW
│       ├── locations_remote_datasource.dart     # NEW
│       └── locations_repository_impl.dart       # NEW
│
├── presentation/
│   ├── auth/
│   │   ├── cubits/
│   │   │   ├── login/
│   │   │   │   ├── login_cubit.dart             # NEW
│   │   │   │   └── login_state.dart             # NEW
│   │   │   └── register/
│   │   │       ├── register_cubit.dart          # NEW
│   │   │       └── register_state.dart          # NEW
│   │   ├── pages/
│   │   │   ├── login_page.dart                  # NEW  (replaces lib/screens/auth/login_screen.dart)
│   │   │   └── register_page.dart               # NEW  (replaces lib/screens/auth/register_screen.dart)
│   │   ├── widgets/                             # auth-scoped shared widgets
│   │   │   ├── user_type_selector.dart          # NEW
│   │   │   ├── terms_checkbox.dart              # NEW
│   │   │   ├── region_picker.dart               # NEW
│   │   │   └── city_picker.dart                 # NEW
│   │   └── auth_routes.dart                     # NEW  (route helpers with BlocProvider wiring)
│   └── widgets/                                 # app-wide shared widgets
│       ├── app_text_field.dart                  # NEW
│       ├── app_password_field.dart              # NEW
│       ├── app_primary_button.dart              # NEW
│       ├── app_error_banner.dart                # NEW
│       └── app_form_scaffold.dart               # NEW
│
├── providers/
│   └── auth_provider.dart                       # EDIT — add hydrateFromSession + clearSession
├── models/                                      # (unchanged — legacy UserModel reused by DTO)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart                    # DELETE
│   │   ├── register_screen.dart                 # DELETE
│   │   ├── forgot_password_screen.dart          # (unchanged — out of scope)
│   │   ├── otp_screen.dart                      # (unchanged — out of scope)
│   │   └── reset_password_screen.dart           # (unchanged — out of scope)
│   ├── home/home_screen.dart                    # EDIT — route update
│   ├── my_listings/my_listings_screen.dart      # EDIT — route update
│   ├── profile/profile_screen.dart              # EDIT — route update
│   ├── packages/packages_screen.dart            # EDIT — route update
│   ├── listing_details/listing_details_screen.dart  # EDIT — 2× route updates
│   └── splash_screen.dart                       # EDIT — route update

pubspec.yaml                                     # EDIT — add flutter_bloc, equatable, bloc_test, mocktail

test/
├── data/auth/
│   ├── auth_remote_datasource_test.dart         # NEW
│   ├── auth_response_parser_test.dart           # NEW  (maps every legacy case)
│   └── auth_repository_impl_test.dart           # NEW
├── data/locations/
│   └── locations_repository_impl_test.dart      # NEW
├── presentation/auth/cubits/
│   ├── login_cubit_test.dart                    # NEW
│   └── register_cubit_test.dart                 # NEW
└── presentation/auth/pages/
    ├── login_page_test.dart                     # NEW  (widget — happy path + failure path)
    └── register_page_test.dart                  # NEW  (widget — happy path)
```

**Structure Decision**: Full three-layer Clean Architecture drop for
the auth feature. The small `lib/{domain,data}/locations/**` module is
included in the same feature because the register page needs it and
it is the cheapest way to avoid a one-off hack. All new files fit in
the target layout locked by constitution v2.0.0 principles I and II.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified.**

No violations. Table intentionally empty.

---

**Phase 0 research** and **Phase 1 artefacts** follow in their own files:
- [research.md](research.md)
- [data-model.md](data-model.md)
- [contracts/auth_repository.contract.md](contracts/auth_repository.contract.md)
- [contracts/cubits.contract.md](contracts/cubits.contract.md)
- [contracts/legacy_bridge.contract.md](contracts/legacy_bridge.contract.md)
- [quickstart.md](quickstart.md)
