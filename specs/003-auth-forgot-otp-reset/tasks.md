---

description: "Task list for feature 003-auth-forgot-otp-reset implementation"
---

# Tasks: Auth Recovery Flows — Clean Architecture Migration

**Input**: Design documents from `/specs/003-auth-forgot-otp-reset/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Included. Per spec FR-015, unit tests cover the three Cubit
state machines (every `AuthFailureReason` variant they can emit) and
widget tests cover at minimum the happy path + failure banner for
the forgot-password and OTP pages.

**Organization**: Tasks are grouped by user story. US2 (Cubit/UI
separation) and US3 (reusable `AppOtpCodeField` widget) are
**structural requirements embedded across US1's implementation** —
they do not get their own phases, same pattern as features 001 +
002. Phase 1 creates the `AppOtpCodeField`; Phase 3 (US1) composes
the three pages from it; Phase 5 (Polish) enforces structural
guarantees via grep.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story the task belongs to (US1 / US4)
- Every task includes an exact file path

## Path Conventions

Flutter mobile-app single-project layout (plan.md § Project
Structure). New code lands under `lib/presentation/auth/**` and
`lib/presentation/widgets/`. Extensions to existing feature-002
files live in `lib/{domain,data}/auth/**` and `lib/core/**`. The
single external edit is in `lib/presentation/auth/pages/login_page.dart`.
Deletions target `lib/screens/auth/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the three new API endpoints, the ~13 new
localization keys, and the one new custom widget. No new
dependencies (002 brought everything needed).

- [X] T001 Add `authVerifyPhone = 'auth/verify-phone'`, `authResendOtp = 'auth/resend-otp'`, and `authResetPassword = 'auth/reset-password'` under the `// region auth` block in [lib/core/constants/api_endpoints.dart](../../lib/core/constants/api_endpoints.dart)
- [X] T002 [P] Add 13 new localization keys to all three locale blocks in [lib/core/localization/app_localizations.dart](../../lib/core/localization/app_localizations.dart) per data-model § 4 (`auth_error_invalid_otp`, `auth_error_expired_otp`, `forgot_password_subtitle`, `send_code`, `verify_code`, `enter_otp`, `code_sent_to`, `didnt_receive_code`, `resend`, `code_resent`, `verify`, `new_password`, `password_reset_success`, `enter_complete_code`, `passwords_not_match`). Check existence first — some keys (e.g. `new_password`, `resend`) already exist from the legacy screens and MUST NOT be duplicated. Use the Arabic values verbatim in all three locales per feature-002 research § R-005.
- [X] T003 [P] Create `AppOtpCodeField` in `lib/presentation/widgets/app_otp_code_field.dart` per research § R-006 — 4 constructor params (`length=6`, `onChanged`, `onCompleted?`, `autoFocus=true`), self-contained `List<TextEditingController>` + `List<FocusNode>` internal state, `Directionality(TextDirection.ltr)` wrapping the row regardless of ambient locale, `FilteringTextInputFormatter.digitsOnly` on each field, theme-driven styling (no hardcoded colors / widths / text styles), fires `onCompleted` exactly once when the last digit lands.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Extend the Domain + Data layer for the three new
repository methods, add the two new `AuthFailureReason` variants,
and wire them through the Presentation error mapper.

**⚠️ CRITICAL**: No user story may begin until this phase is complete.

### Domain extensions

- [X] T004 [P] Add `invalidOtp` and `expiredOtp` variants to the `AuthFailureReason` enum in [lib/domain/auth/auth_failure_reason.dart](../../lib/domain/auth/auth_failure_reason.dart) per data-model § 1.1
- [X] T005 Add 4 method signatures to the `AuthRepository` interface in [lib/domain/auth/auth_repository.dart](../../lib/domain/auth/auth_repository.dart) — `forgotPassword(String phone)`, `verifyOtp(String phone, String code)`, `resendOtp(String phone)`, `resetPassword(String phone, String code, String newPassword)` — per contracts/auth_repository_extension.contract.md § 1

### Data extensions

- [X] T006 Add 3 new methods to `AuthRemoteDataSource` in [lib/data/auth/auth_remote_datasource.dart](../../lib/data/auth/auth_remote_datasource.dart) — `forgotPassword(String phone)`, `resendOtp(String phone)` (hard-codes `type: 'password_reset'`), `resetPassword({phone, code, newPassword})` — all calling `getIt<Dio>()` via `ApiEndpoints.*` constants. No datasource method for `verifyOtp` (client-side no-op per research § R-001).
- [X] T007 Extend `AuthResponseParser` in [lib/data/auth/auth_response_parser.dart](../../lib/data/auth/auth_response_parser.dart) with two new static parse methods (`parseForgotPassword`, `parseResetPassword`) and a private `_recoveryReasonFromMessage` helper per data-model § 2.2 — recognises `invalid otp` / `wrong code` / `incorrect code` → `invalidOtp`, and `expired otp` / `otp expired` / `code expired` → `expiredOtp`, falling through to `missingRequiredFields` / `weakPassword` / `unknownLogin`
- [X] T008 Implement the 4 new methods on `AuthRepositoryImpl` in [lib/data/auth/auth_repository_impl.dart](../../lib/data/auth/auth_repository_impl.dart) per data-model § 2.3 — `verifyOtp` is a shape check (throws `AuthException(invalidOtp)` if `code.length != 6`, otherwise returns normally, no network); the other three follow the existing `login()`/`register()` pattern with `DioException → AuthException` mapping via `AuthResponseParser.fromDioException`; depends on T005, T006, T007

### Presentation shared surface

- [X] T009 Extend `failureReasonToMessage` in [lib/presentation/auth/auth_error_messages.dart](../../lib/presentation/auth/auth_error_messages.dart) with the two new cases — `AuthFailureReason.invalidOtp => 'auth_error_invalid_otp'` and `AuthFailureReason.expiredOtp => 'auth_error_expired_otp'`; depends on T004, T002

### Foundational tests

- [X] T010 [P] Extend [test/data/auth/auth_response_parser_test.dart](../../test/data/auth/auth_response_parser_test.dart) with: (a) a group covering `parseForgotPassword` happy + typed-failure cases, (b) a group covering `parseResetPassword` happy + typed-failure cases, and (c) table-driven cases for every new `invalidOtp` / `expiredOtp` server-message fragment
- [X] T011 [P] Extend [test/data/auth/auth_repository_impl_test.dart](../../test/data/auth/auth_repository_impl_test.dart) with groups covering each of the 4 new methods — `forgotPassword` happy/failure, `verifyOtp` 6-digit pass and non-6-digit fail (no network), `resendOtp` happy/failure (verify `type: 'password_reset'` in the body), `resetPassword` happy/every-failure-variant, and the `DioException → AuthException.network` path for all three network-bound methods

**Checkpoint**: Foundation complete. `flutter test test/data/`
should pass with the extended test suite green. The three Cubits
can now be written on top of the extended `AuthRepository`.

---

## Phase 3: User Story 1 — Forgotten-password recovery end-to-end (Priority: P1) 🎯 MVP

**Goal**: Deliver the complete three-screen password-recovery
journey using the Cubit pattern from feature 002. The flow is a
**connected unit** — partial delivery of any one screen is not
independently useful to an end user (per spec US1), so this phase
ships the whole journey before the US4 deletion can run.

**Independent Test**: Install the app, tap "forgot password" on
the login page, enter a known-registered phone, confirm the app
advances to OTP entry. Enter an incorrect code, confirm the
Arabic error banner appears. Enter the correct code, enter a
new valid password, confirm the app pops back to login with the
"password_reset_success" snackbar.

### ForgotPassword (4 tasks)

- [X] T012 [P] [US1] Create `ForgotPasswordState` sealed class with `ForgotPasswordInitial`, `ForgotPasswordSubmitting`, `ForgotPasswordSucceeded(phone)`, `ForgotPasswordFailed(reason)` variants in `lib/presentation/auth/cubits/forgot_password/forgot_password_state.dart` per data-model § 3.1 and contracts/cubits.contract.md § 1
- [X] T013 [P] [US1] Create `ForgotPasswordCubit` with `submit(phone)` and `reset()` methods, idempotent while `Submitting`, in `lib/presentation/auth/cubits/forgot_password/forgot_password_cubit.dart`; depends on T005 (repository interface) and T012
- [X] T014 [US1] Create `ForgotPasswordPage` in `lib/presentation/auth/pages/forgot_password_page.dart` — composes `AppFormScaffold` + `AppTextField` (phone) + `AppErrorBanner` + `AppPrimaryButton`; `BlocListener<ForgotPasswordCubit>` catches `ForgotPasswordSucceeded` and calls `Navigator.pushReplacement(ctx, otpRoute(phone: state.phone))`; depends on T003 (AppOtpCodeField not yet needed, but the other 002 widgets are), T013, T009 (error mapper), and T024 (route helper — uses forward-reference; T024 imports this page)
- [X] T015 [P] [US1] Unit test `ForgotPasswordCubit` per research § R-007 — happy path, table-driven over every `AuthFailureReason` variant the Cubit can emit, idempotent-submit (`wait: const Duration(milliseconds: 100)`), `reset() → Initial` — in `test/presentation/auth/cubits/forgot_password_cubit_test.dart`; uses `_MockAuthRepository extends Mock implements AuthRepository` via `mocktail`

### OTP (4 tasks)

- [X] T016 [P] [US1] Create `OtpState` sealed class with 7 variants (`OtpInitial`, `OtpSubmitting`, `OtpSucceeded(code)`, `OtpFailed(reason)`, `OtpResending`, `OtpResendSucceeded`, `OtpResendFailed(reason)`) in `lib/presentation/auth/cubits/otp/otp_state.dart` per data-model § 3.2 and contracts/cubits.contract.md § 2 — every variant carries `phone` via the base constructor
- [X] T017 [P] [US1] Create `OtpCubit` with `submit(code)` and `resend()` methods per contracts/cubits.contract.md § 2 — the idempotency guard blocks both when either is in-flight; `OtpResendSucceeded` / `OtpResendFailed` auto-drop back to `OtpInitial(phone)` so subsequent submits aren't blocked — in `lib/presentation/auth/cubits/otp/otp_cubit.dart`; depends on T005, T016
- [X] T018 [US1] Create `OtpPage` in `lib/presentation/auth/pages/otp_page.dart` — composes `AppFormScaffold` + the `AppOtpCodeField` from T003 + `AppErrorBanner` + `AppPrimaryButton` + a "didn't receive code? resend" `TextButton`; `BlocConsumer<OtpCubit>` handles `OtpSucceeded` → `Navigator.pushReplacement(ctx, resetPasswordRoute(phone, code))`, `OtpResendSucceeded` → SnackBar with `code_resent`, `OtpResendFailed` → SnackBar with the localized reason; depends on T003, T017, T009, T024
- [X] T019 [P] [US1] Unit test `OtpCubit` per research § R-007 — happy submit, table-driven failure over each variant (especially the new `invalidOtp` + `expiredOtp`), resend happy path + failure path with auto-drop verification, idempotent-submit, idempotent-resend — in `test/presentation/auth/cubits/otp_cubit_test.dart`

### ResetPassword (4 tasks)

- [X] T020 [P] [US1] Create `ResetPasswordState` sealed class with `ResetPasswordInitial(phone, code)`, `ResetPasswordSubmitting(phone, code)`, `ResetPasswordSucceeded(phone, code)`, `ResetPasswordFailed(phone, code, reason)` variants in `lib/presentation/auth/cubits/reset_password/reset_password_state.dart` per data-model § 3.3
- [X] T021 [P] [US1] Create `ResetPasswordCubit` with `submit(newPassword)` and `reset()` — phone + code captured at construction time and preserved across states — in `lib/presentation/auth/cubits/reset_password/reset_password_cubit.dart`; depends on T005, T020
- [X] T022 [US1] Create `ResetPasswordPage` in `lib/presentation/auth/pages/reset_password_page.dart` — composes `AppFormScaffold` + two `AppPasswordField` (new + confirm, with client-side match validator) + `AppErrorBanner` + `AppPrimaryButton`; `BlocListener<ResetPasswordCubit>` catches `ResetPasswordSucceeded` → SnackBar (`password_reset_success`) + `Navigator.popUntil((r) => r.isFirst)`; depends on T021, T009, T024
- [X] T023 [P] [US1] Unit test `ResetPasswordCubit` per research § R-007 — happy path, table-driven failure with especial attention to `invalidOtp` + `expiredOtp` + `weakPassword` + `missingRequiredFields`, idempotent-submit, `reset()` — in `test/presentation/auth/cubits/reset_password_cubit_test.dart`

### Route wiring + legacy LoginPage update (2 tasks)

- [X] T024 [US1] Extend [lib/presentation/auth/auth_routes.dart](../../lib/presentation/auth/auth_routes.dart) with three new route helpers — `forgotPasswordRoute()`, `otpRoute({required String phone})`, `resetPasswordRoute({required String phone, required String code})` — each wraps its page in a `BlocProvider` resolving `AuthRepository` via `getIt` per data-model § 3.6; depends on T013, T017, T021 (Cubits) and T014, T018, T022 (pages)
- [X] T025 [US1] Update [lib/presentation/auth/pages/login_page.dart](../../lib/presentation/auth/pages/login_page.dart) — replace the legacy `Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()))` in the `_ForgotPasswordLink` widget with `Navigator.push(context, forgotPasswordRoute())`; remove the now-unused `screens/auth/forgot_password_screen.dart` import; depends on T024

### Widget tests (2 tasks)

- [X] T026 [P] [US1] Widget test `ForgotPasswordPage` — renders the phone field + submit button with `ForgotPasswordInitial`; shows the localized error banner when state is `ForgotPasswordFailed(invalidPhone)` — in `test/presentation/auth/pages/forgot_password_page_test.dart`; uses `MockCubit` via `bloc_test` and `AppLocalizations.delegate` with locale `ar`, matching the 002 widget-test pattern
- [X] T027 [P] [US1] Widget test `OtpPage` — renders the `AppOtpCodeField` (6 visible digit boxes) + resend link + submit button when state is `OtpInitial(phone)`; shows the localized `invalid otp` Arabic banner when state is `OtpFailed(invalidOtp)` — in `test/presentation/auth/pages/otp_page_test.dart`

**Checkpoint**: The full recovery journey works end-to-end. All
~18 new Cubit tests + ~5 new widget tests green. The legacy
`LoginPage` forgot-password link now points at `forgotPasswordRoute()`.
Legacy files still physically exist but are no longer referenced.

---

## Phase 4: User Story 4 — Legacy recovery screens removed (Priority: P3)

**Goal**: Physically delete the three legacy files now that nothing
references them.

**Independent Test**: `grep -R 'ForgotPasswordScreen\|OtpScreen\|ResetPasswordScreen' lib/`
returns zero matches. `flutter analyze` reports no unresolved
imports.

- [X] T028 [US4] Delete [lib/screens/auth/forgot_password_screen.dart](../../lib/screens/auth/forgot_password_screen.dart); depends on T025 (last external reference repointed at the new route)
- [X] T029 [US4] Delete [lib/screens/auth/otp_screen.dart](../../lib/screens/auth/otp_screen.dart) — only referenced from within the other two legacy files, both deleted in this phase
- [X] T030 [US4] Delete [lib/screens/auth/reset_password_screen.dart](../../lib/screens/auth/reset_password_screen.dart); then verify deletion completeness with `grep -R 'ForgotPasswordScreen\|OtpScreen\|ResetPasswordScreen' lib/ --include='*.dart'` — expect zero matches

**Checkpoint**: Legacy recovery screens gone. `lib/screens/auth/`
is effectively empty of active code (any stragglers are
out-of-scope).

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Enforce US2 (Cubit/UI separation) and US3
(`AppOtpCodeField` reuse + DRY) via grep checks, run the analyzer,
run the full test suite, and update docs.

- [X] T031 [P] Structural guard for US2: `grep -E 'http\.|package:dio|SharedPreferences|ApiService|notifyListeners' lib/presentation/auth/pages/{forgot_password_page,otp_page,reset_password_page}.dart` — expect zero matches; `grep -cE 'BlocBuilder|BlocListener|BlocConsumer|context\.read<.*Cubit>' lib/presentation/auth/pages/{forgot_password_page,otp_page,reset_password_page}.dart` — expect ≥ 1 match per file. Record results in the PR description (SC-003).
- [X] T032 [P] Structural guard for US3 + US4: `grep -E 'Color\(|EdgeInsets\.(all|symmetric|only)\(|TextStyle\(' lib/presentation/auth/pages/{forgot_password_page,otp_page,reset_password_page}.dart` — expect zero matches (all styling from theme / custom widgets, SC-004). `grep -n 'AppOtpCodeField' lib/presentation/auth/pages/otp_page.dart` — expect ≥ 1 match (SC-005).
- [X] T033 Run `flutter analyze` across the full project; zero warnings in new code under `lib/presentation/auth/**` and `lib/presentation/widgets/app_otp_code_field.dart`. Pre-existing warnings in unrelated legacy files remain out of scope (same policy as feature 001 T031 / 002 T063).
- [X] T034 Run `flutter test` end-to-end; all tests pass — the new ones under `test/presentation/auth/cubits/{forgot_password,otp,reset_password}_cubit_test.dart` and `test/presentation/auth/pages/{forgot_password,otp}_page_test.dart`, plus every test already passing from features 001 + 002.
- [ ] T035 **DEFERRED (manual — cannot automate; requires emulator + live backend)** Manual end-to-end verification on an emulator — (a) open the app, tap "forgot password" from login, enter a phone, confirm OTP page opens with the correct "code sent to {phone}" text; (b) tap "resend" and confirm the SnackBar fires; (c) enter a wrong 6-digit code, confirm the Arabic `invalid_otp` banner appears on the reset page (validated at reset time per research § R-001); (d) enter the correct code + a valid new password, confirm the app pops back to login with the success SnackBar; (e) log in with the new password. Record results in the PR description. Cannot be automated — requires an emulator + live backend. Responsibility passes to the human reviewer before merge.
- [X] T036 Update [CLAUDE.md](../../CLAUDE.md) to mark 003 as implemented/in-review and promote the next candidate (`004-session-cubit-migration`) to the active-feature slot once 003 merges

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. T001, T002, T003 are all `[P]` — three independent files.
- **Phase 2 (Foundational)**: Depends on Phase 1. Blocks all user stories.
  - T004 is `[P]` with T002/T003.
  - T005 depends on T004 (imports `AuthFailureReason`).
  - T006 is independent of T005 (datasource doesn't use Domain types directly).
  - T007 depends on T004.
  - T008 depends on T005, T006, T007 (the integration point).
  - T009 depends on T004, T002.
  - Tests T010, T011 are `[P]` relative to each other; each depends on the code it tests.
- **Phase 3 (US1)**: Depends on Phase 2. The three screens can be built partially in parallel by two devs after Foundational lands, but:
  - Cubit states (T012, T016, T020) are `[P]`.
  - Cubits (T013, T017, T021) depend on their respective states + the shared T005.
  - Pages (T014, T018, T022) depend on their respective Cubits + T003 + T009, and each references `auth_routes.dart` functions which land in T024 — forward-reference by name that compiles once T024 ships.
  - Route helpers (T024) depend on all three pages existing.
  - LoginPage update (T025) depends on T024.
  - Cubit tests (T015, T019, T023) are `[P]` among themselves and depend only on their respective Cubits.
  - Widget tests (T026, T027) depend on their respective pages.
- **Phase 4 (US4 — deletions)**: Depends on Phase 3 complete. T028 depends on T025 (last external reference removed); T029 and T030 depend on the other two deletions happening in the same batch (they reference each other in the legacy chain).
- **Phase 5 (Polish)**: Depends on Phase 4 complete. T031–T034 are verification; T035 is manual deferred; T036 closes docs.

### Parallel Opportunities

- **Phase 1**: T001, T002, T003 all `[P]` — three files.
- **Phase 2 Domain**: T004 `[P]` (enum edit) alone; T005 serialises after.
- **Phase 2 Data**: T006, T007 are `[P]` (different files, no deps on T005); T008 serialises.
- **Phase 2 tests**: T010, T011 `[P]`.
- **Phase 3**: Cubit-state tasks (T012, T016, T020) `[P]`. Cubit tasks (T013, T017, T021) `[P]` after their states. Cubit test tasks (T015, T019, T023) `[P]` after their Cubits. Widget test tasks (T026, T027) `[P]` after their pages. Page tasks (T014, T018, T022) serialise on the `auth_routes.dart` dependency but can be drafted in parallel — T024 is the integration point.
- **Phase 5**: T031 + T032 are `[P]` (read-only grep checks); T033 / T034 serialise on the toolchain.

---

## Parallel Example: Phase 2 Domain + Data

```text
# After Phase 1, these five foundation edits can kick off in parallel:
Task T004 [P] Add AuthFailureReason variants      → lib/domain/auth/auth_failure_reason.dart
Task T006 [P] Extend AuthRemoteDataSource         → lib/data/auth/auth_remote_datasource.dart
Task T010 [P] Extend parser tests                 → test/data/auth/auth_response_parser_test.dart
Task T011 [P] Extend repo impl tests              → test/data/auth/auth_repository_impl_test.dart

# Then serialised on their dependencies:
Task T005 AuthRepository interface extension       (depends on T004)
Task T007 AuthResponseParser extension             (depends on T004)
Task T008 AuthRepositoryImpl extension             (depends on T005, T006, T007)
Task T009 failureReasonToMessage extension         (depends on T004, T002)
```

## Parallel Example: US1 Cubits

```text
# After Phase 2 completes:

# States land in parallel:
Task T012 [P] [US1] ForgotPasswordState
Task T016 [P] [US1] OtpState
Task T020 [P] [US1] ResetPasswordState

# Cubits land in parallel:
Task T013 [P] [US1] ForgotPasswordCubit
Task T017 [P] [US1] OtpCubit
Task T021 [P] [US1] ResetPasswordCubit

# Cubit tests land in parallel:
Task T015 [P] [US1] ForgotPasswordCubit test
Task T019 [P] [US1] OtpCubit test
Task T023 [P] [US1] ResetPasswordCubit test

# Pages serialise on the auth_routes.dart integration point:
Task T014 [US1] ForgotPasswordPage
Task T018 [US1] OtpPage
Task T022 [US1] ResetPasswordPage
Task T024 [US1] Extend auth_routes.dart with 3 helpers

# LoginPage update + widget tests:
Task T025 [US1] Update LoginPage forgot-password link
Task T026 [P] [US1] ForgotPasswordPage widget test
Task T027 [P] [US1] OtpPage widget test
```

---

## Implementation Strategy

### MVP Scope (US1 only)

1. **Phase 1 (Setup)**: 3 tasks → endpoints + localization + widget.
2. **Phase 2 (Foundational)**: 8 tasks → Domain + Data extensions + 2 test files.
3. **Phase 3 (US1)**: 16 tasks → the full three-screen recovery journey.
4. **Stop and validate**: `flutter test` green, manual smoke test of the happy path.
5. This is the **MVP cut-line**. The three deletions in Phase 4 and the Polish tasks in Phase 5 can land in the same PR or a fast follow-up.

### Incremental delivery (recommended — one PR)

1. Land Phase 1 + Phase 2 → foundation ready.
2. Land Phase 3 → journey works end-to-end.
3. Land Phase 4 → legacy deleted.
4. Land Phase 5 → polish + docs.
5. Single PR merged to `main` containing all 36 tasks.

### Solo vs parallel development

- **Solo**: linear T001 → T036.
- **Two devs**: after Phase 2, split by screen (Dev A on ForgotPassword + OTP, Dev B on ResetPassword + widget tests). The `auth_routes.dart` edit (T024) is the coordination point.

---

## Notes

- **Legacy files touched**: exactly one (`lib/presentation/auth/pages/login_page.dart` — T025), plus the three deletions (T028–T030). No other legacy edit is in scope.
- **Out of scope** (per spec FR-014): the `phone_verification` branch inside the legacy OTP screen (dead code — no caller creates it). If a future feature introduces phone verification during onboarding, it builds its own `PhoneVerificationCubit` on top of the `AppOtpCodeField` this feature ships.
- **Character-exact Arabic preservation (FR-007)**: the extended `auth_response_parser_test.dart` (T010) is the regression guard. If it fails, the spec's hard commitment is violated.
- **US2 and US3** have no dedicated phases because they are structural outcomes of the pages and widget built in US1. The Phase 5 grep checks (T031, T032) enforce them.
- **No new dependencies**: `pubspec.yaml` is unchanged. `flutter_bloc`, `equatable`, `bloc_test`, `mocktail` all landed in feature 002.
- **No new DI registrations**: `AuthRepository` is already registered as a `lazySingleton`; the interface extension flows through transparently.
