# Implementation Plan: Auth Recovery Flows — Clean Architecture Migration

**Branch**: `003-auth-forgot-otp-reset` | **Date**: 2026-04-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-auth-forgot-otp-reset/spec.md`

## Summary

Continuation slice of the Auth migration. The three remaining legacy
auth screens — `forgot_password_screen.dart`, `otp_screen.dart`,
`reset_password_screen.dart` — are rebuilt under
`lib/presentation/auth/` using three new Cubits
(`ForgotPasswordCubit`, `OtpCubit`, `ResetPasswordCubit`), each
following the `LoginCubit` state-machine pattern established in
feature 002. The `AuthRepository` interface is extended with
`forgotPassword(phone)`, `verifyOtp(phone, code)`, `resendOtp(phone)`,
and `resetPassword(phone, code, newPassword)`; `AuthRemoteDataSource`
gains four corresponding methods; `AuthResponseParser` gains two new
parse functions plus new `AuthFailureReason` variants for
`invalidOtp` and `expiredOtp`. One new custom widget
(`AppOtpCodeField`) lands under `lib/presentation/widgets/` as a
reusable 6-digit code input. Seven new source files plus edits to
eight existing files, plus three legacy deletions. **No new
dependencies** — feature 002's stack is sufficient. The single
external code touch outside the migration scope is the
forgot-password link inside the migrated `login_page.dart` which
swaps from `ForgotPasswordScreen` to `forgotPasswordRoute()`.

## Technical Context

**Language/Version**: Dart `^3.8.1` / Flutter (unchanged from 002)
**Primary Dependencies** (all already present):
  - `flutter_bloc ^8.1.6` (from 002)
  - `equatable ^2.0.7` (from 002)
  - `dio ^5.4.0` (from 001)
  - `get_it ^7.7.0` (from 001)
**Dev dependencies** (all already present): `bloc_test ^9.1.7`, `mocktail ^1.0.4`
**Foundation reused** (from features 001 + 002):
  - `AuthRepository` interface + `AuthException` (extended, not replaced)
  - `AuthResponseParser` (extended with 2 new parse functions)
  - `AuthFailureReason` enum (extended with 2 new variants: `invalidOtp`, `expiredOtp`)
  - `failureReasonToMessage` Presentation helper
  - `auth_routes.dart` (extended with 3 new route helpers)
  - All 5 app-wide widgets: `AppTextField`, `AppPasswordField`, `AppPrimaryButton`, `AppErrorBanner`, `AppFormScaffold`
  - `getIt<Dio>()`, `TokenReader`, `LocaleReader`
**Storage**: none new — password recovery is a server round-trip, nothing persists locally until the user logs back in afterwards
**Testing**: `flutter_test` + `bloc_test` + `mocktail`, same harness as 002
**Target Platform**: Android + iOS
**Project Type**: mobile-app (Flutter)
**Performance Goals**: same as 002 — Cubit construction < 50 ms; no regression on the end-to-end recovery-flow time-to-complete
**Constraints**: character-exact preservation of every Arabic error message from the legacy three screens; three-locale support (`ar`/`he`/`en`) via the same "Arabic verbatim in all three locales" pattern per 002 research § R-005; legacy `AuthProvider.forgotPassword/verifyPhone/resendOtp/resetPassword` stay untouched to serve any non-migrated callers
**Scale/Scope**: 3 pages migrated; ~12 new source files + ~8 edits + 3 legacy deletions + 1 new custom widget + ~8 new localization keys × 3 locales

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Mapping against [.specify/memory/constitution.md](../../.specify/memory/constitution.md) v2.0.0:

| Principle | Applies? | Status | Notes |
|-----------|----------|--------|-------|
| I. Clean Architecture (NON-NEGOTIABLE) | Yes — three more Clean-Arch pages | ✅ PASS | All new code under `lib/{domain,data,presentation}/auth/**`. No imports cross layer boundaries incorrectly. Domain gains 3 new method signatures + 2 enum variants; Data gains the network + parser implementations; Presentation gains 3 Cubits + 3 pages. |
| II. Cubit State Management (NON-NEGOTIABLE) | Yes — new screens | ✅ PASS | `ForgotPasswordCubit`, `OtpCubit`, `ResetPasswordCubit` — one Cubit per screen, all following the `LoginCubit` pattern. No `ChangeNotifier` / `provider` in new Presentation code. |
| III. Dio-based Networking with Wrapper | Yes — data source additions | ✅ PASS | All four new data-source methods use `getIt<Dio>()`. New `ApiEndpoints` constants (`authVerifyPhone`, `authResendOtp`, `authResetPassword`) land in the existing catalog. Zero raw path strings. |
| IV. DRY through Custom Widgets | Yes — reuse + 1 addition | ✅ PASS | Pages compose from the 5 app-wide widgets built in 002 + 1 new `AppOtpCodeField` (used by the OTP page and reserved for future verification flows). No widget is re-derived inline. |
| V. Simple, Readable, Organized Code | Yes — baseline | ✅ PASS | Target: every new file ≤ 300 lines. Each Cubit is <100 lines; each page ≤ 200 lines based on the legacy screen complexity. `AppOtpCodeField` encapsulates the 40-line focus-node plumbing the legacy OTP screen inlined. |

**Gate decision**: PASS — proceeding to Phase 0.

Notable simplifications vs. 002:
- **Zero new dependencies**: the `flutter_bloc` / `equatable` / `bloc_test` / `mocktail` additions landed in 002 already.
- **Zero new locations for DI**: `AuthRepository` is already registered in `setupLocator()`. Extending the interface doesn't require any DI changes — the existing registration picks up the new methods.
- **No new legacy-bridge pattern**: unlike 002, this feature does NOT need to push state back into `AuthProvider`. The three recovery flows are stateless from the app's perspective (no authenticated session until the user logs in again post-reset). `AuthProvider.hydrateFromSession` is irrelevant here.

### Post-Phase-1 Re-check

*Filled in after Phase 1 artefacts are produced.*

| Principle | Re-check | Notes |
|-----------|----------|-------|
| I. Clean Architecture | ✅ PASS | Verified by the contract docs — Domain additions are enum variants + 3 method signatures; Data additions are pure-function parsers + repository impl methods; Presentation additions are Cubits + pages + 1 widget. No dependency-direction violations. |
| II. Cubit State Management | ✅ PASS | All three Cubits consume `AuthRepository` only. No `ChangeNotifier` imports. |
| III. Dio with wrapper | ✅ PASS | New data-source methods use the existing `Dio` injected via constructor; new endpoints added to catalog. |
| IV. DRY | ✅ PASS | `AppOtpCodeField` is the only new widget — used in the new OTP page and reserved for future reuse. All other primitives reused from 002. |
| V. Simple/Readable | ✅ PASS | Every new Cubit mirrors `LoginCubit`'s shape exactly. No novel abstractions. Pages compose from the existing widget vocabulary. |

**Gate remains PASS.**

## Project Structure

### Documentation (this feature)

```text
specs/003-auth-forgot-otp-reset/
├── plan.md              # This file
├── research.md          # Phase 0 output — 7 decisions
├── data-model.md        # Phase 1 output — states + cubits + widget
├── quickstart.md        # Phase 1 output — how to add the next OTP-based screen
├── contracts/           # Phase 1 output
│   ├── auth_repository_extension.contract.md
│   └── cubits.contract.md
├── checklists/
│   └── requirements.md  # From /speckit.specify
└── tasks.md             # Produced by /speckit.tasks
```

### Source Code (repository root)

Minimal footprint. Builds on 002's structure, touches only the auth
slice plus one external link update.

```text
lib/
├── core/
│   ├── constants/
│   │   └── api_endpoints.dart                      # EDIT — add 3 constants (authVerifyPhone, authResendOtp, authResetPassword)
│   └── localization/
│       └── app_localizations.dart                  # EDIT — ~8 new keys in 3 locale blocks (~24 entries)
│
├── domain/auth/
│   ├── auth_failure_reason.dart                    # EDIT — add `invalidOtp`, `expiredOtp` variants
│   └── auth_repository.dart                        # EDIT — add 4 method signatures (forgotPassword, verifyOtp, resendOtp, resetPassword)
│
├── data/auth/
│   ├── auth_remote_datasource.dart                 # EDIT — add 4 methods
│   ├── auth_response_parser.dart                   # EDIT — add `parseForgotPassword`, `parseResetPassword`, extend `_translateAuthError` mapping for OTP reasons
│   └── auth_repository_impl.dart                   # EDIT — add 4 method impls with DioException mapping
│
├── presentation/
│   ├── auth/
│   │   ├── auth_error_messages.dart                # EDIT — add `invalidOtp` / `expiredOtp` → localization keys
│   │   ├── auth_routes.dart                        # EDIT — add forgotPasswordRoute(), otpRoute(phone), resetPasswordRoute(phone, code)
│   │   ├── cubits/
│   │   │   ├── forgot_password/
│   │   │   │   ├── forgot_password_cubit.dart      # NEW
│   │   │   │   └── forgot_password_state.dart      # NEW
│   │   │   ├── otp/
│   │   │   │   ├── otp_cubit.dart                  # NEW
│   │   │   │   └── otp_state.dart                  # NEW
│   │   │   └── reset_password/
│   │   │       ├── reset_password_cubit.dart       # NEW
│   │   │       └── reset_password_state.dart       # NEW
│   │   └── pages/
│   │       ├── forgot_password_page.dart           # NEW  (replaces screens/auth/forgot_password_screen.dart)
│   │       ├── login_page.dart                     # EDIT — swap legacy ForgotPasswordScreen link for forgotPasswordRoute()
│   │       ├── otp_page.dart                       # NEW  (replaces screens/auth/otp_screen.dart — password_reset path only)
│   │       └── reset_password_page.dart            # NEW  (replaces screens/auth/reset_password_screen.dart)
│   └── widgets/
│       └── app_otp_code_field.dart                 # NEW — 6-digit code input (reusable)
│
└── screens/auth/
    ├── forgot_password_screen.dart                 # DELETE
    ├── otp_screen.dart                             # DELETE
    └── reset_password_screen.dart                  # DELETE

test/
├── data/auth/
│   ├── auth_response_parser_test.dart              # EDIT — add parseForgotPassword + parseResetPassword + OTP reason cases
│   └── auth_repository_impl_test.dart              # EDIT — add tests for 4 new methods + dioException mapping
└── presentation/auth/
    ├── cubits/
    │   ├── forgot_password_cubit_test.dart         # NEW
    │   ├── otp_cubit_test.dart                     # NEW
    │   └── reset_password_cubit_test.dart          # NEW
    └── pages/
        ├── forgot_password_page_test.dart          # NEW  (widget — happy path + failure banner)
        └── otp_page_test.dart                      # NEW  (widget — happy path + failure banner)
```

**Structure Decision**: Builds purely on top of 002's layered
architecture — no new directories at the top level. 12 new source
files (7 under `lib/`, 5 under `test/`), 8 edits, 3 legacy deletions.
No changes to `pubspec.yaml` or DI wiring; `AuthRepository` is
already registered and the interface extension flows through
transparently.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified.**

No violations. Table intentionally empty.

---

**Phase 0 research** and **Phase 1 artefacts** follow in their own files:
- [research.md](research.md)
- [data-model.md](data-model.md)
- [contracts/auth_repository_extension.contract.md](contracts/auth_repository_extension.contract.md)
- [contracts/cubits.contract.md](contracts/cubits.contract.md)
- [quickstart.md](quickstart.md)
