# Feature Specification: Auth Recovery Flows — Clean Architecture Migration

**Feature Branch**: `003-auth-forgot-otp-reset`
**Created**: 2026-04-24
**Status**: Draft
**Input**: User description: "عايز أكمل الـ Auth migration بترحيل الشاشات الـ 3 المتبقية — forgot_password, otp, reset_password — لنفس الـ Clean Architecture + Cubit pattern اللي بنيناه في 002. استخدم الـ AppTextField / AppPasswordField / AppPrimaryButton / AppErrorBanner / AppFormScaffold الموجودين. وسّع الـ AuthRepository بـ forgotPassword(phone) + verifyOtp(phone, code) + resetPassword(phone, code, newPassword). Cubit لكل شاشة (ForgotPasswordCubit, OtpCubit, ResetPasswordCubit) بنفس pattern الـ LoginCubit. أضف widget جديد AppOtpCodeField (6-digit code input) في lib/presentation/widgets/. احذف الملفات القديمة (forgot_password_screen.dart و otp_screen.dart و reset_password_screen.dart). التزم بالـ Constitution v2.0.0."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Forgotten-password recovery end-to-end (Priority: P1)

As a rento-go user who has forgotten my password, I tap "Forgot
password" on the login screen, enter my phone, receive a 6-digit
code, enter it, then set a new password and get signed back in —
exactly the same flow I have today, with the same Arabic text and
the same success/error messages.

**Why this priority**: This is the only path to account recovery.
If a user forgets their password and this flow breaks, they're
locked out permanently. The three screens — Forgot Password →
OTP → Reset Password — are a **connected journey**: partial
delivery of any one screen is not independently useful to an end
user. The full flow is the minimum viable slice.

**Independent Test**: On the migrated build, tap "forgot password"
from login. Enter a known-registered phone; confirm the app
advances to OTP entry with a "code sent to {phone}" message
matching today's wording. Enter a wrong code; confirm the same
Arabic error as today (or equivalent). Enter the correct code and
proceed to the new-password screen; set a valid password, submit,
and confirm the app returns to the login page with a success
snackbar matching today's text.

**Acceptance Scenarios**:

1. **Given** a user at the login screen, **When** they tap "forgot
   password", **Then** the recovery-entry screen opens.
2. **Given** a valid phone at the recovery-entry screen, **When**
   the user submits, **Then** the app advances to the OTP screen
   and shows the legacy "code sent to {phone}" text unchanged.
3. **Given** a phone not registered with the system, **When** the
   user submits the recovery request, **Then** the backend's error
   message is surfaced in Arabic matching today's wording.
4. **Given** the user is on the OTP screen, **When** they type all
   6 digits, **Then** focus automatically advances across fields
   and the submit button becomes enabled.
5. **Given** the user is on the OTP screen, **When** they tap
   "didn't receive code? resend", **Then** a fresh OTP is requested
   for the same phone and the legacy "code resent" confirmation
   appears.
6. **Given** the user enters a wrong 6-digit code, **When** they
   submit, **Then** a typed error is surfaced on-screen (not a
   raw exception message) with Arabic text.
7. **Given** the user enters the correct code, **When** submission
   succeeds, **Then** the app advances to the new-password screen
   carrying the verified-OTP context forward.
8. **Given** a new password shorter than 6 characters, **When**
   the user submits, **Then** client-side validation blocks
   submission with the existing Arabic min-length message.
9. **Given** confirmation password does not match, **When** the
   user submits, **Then** client-side validation blocks submission
   with the existing Arabic mismatch message.
10. **Given** a valid new password with matching confirm, **When**
    the user submits, **Then** the app pops back to login and
    shows the legacy "password reset successfully" snackbar.

---

### User Story 2 — Cubit/UI separation on the three new screens (Priority: P2)

As an engineer reviewing the diff, I can open any of the three new
pages and read the widget tree in under a minute. None of them
contain HTTP calls, `SharedPreferences` access, or business logic.
State lives in three single-responsibility Cubits alongside, each
testable in isolation.

**Why this priority**: Preserves the architectural invariant
established by feature 002. Without this enforcement, the legacy
`AuthProvider` methods (`forgotPassword`, `resetPassword`,
`resendOtp`) would leak back into the new pages.

**Independent Test**: Grep the new pages for `http.`, `dio`,
`SharedPreferences`, `ApiService`, `notifyListeners`. Expect
zero matches. Grep for `BlocConsumer`, `BlocListener`,
`context.read<ForgotPasswordCubit>` / `<OtpCubit>` /
`<ResetPasswordCubit>`. Expect matches.

**Acceptance Scenarios**:

1. **Given** a reviewer opens any of the three new pages,
   **When** they scan the imports and the widget tree, **Then**
   they see only Flutter/Bloc/Domain types — no Data or legacy
   imports.
2. **Given** a Cubit test exists for each of the three Cubits,
   **When** those tests run, **Then** each exercises its state
   machine without instantiating any widget.

---

### User Story 3 — Reusable `AppOtpCodeField` widget (Priority: P2)

As an engineer who will later need a verification-code input
elsewhere (e.g. phone verification during onboarding, 2FA),
I can compose it from the same `AppOtpCodeField` that the OTP
screen uses — theme-aware, focus-chained, 6-digit by default,
configurable length.

**Why this priority**: The legacy OTP screen has 40+ lines of
inline 6-digit code-field logic (focus nodes, controllers,
direction handling). Without extraction, every future caller
would re-derive the same code. This is the DRY principle applied
to the one new widget this feature introduces.

**Independent Test**: Inventory `lib/presentation/widgets/`.
Confirm `AppOtpCodeField` exists as a standalone public widget.
Confirm the new OTP page imports and uses it. Confirm no
focus-node plumbing appears inline in the page itself.

**Acceptance Scenarios**:

1. **Given** a reviewer examines `lib/presentation/widgets/`,
   **When** they look for OTP-related widgets, **Then**
   `AppOtpCodeField` is present with parameters for length, a
   `ValueChanged<String>` callback, and a completion hook.
2. **Given** a future feature needs a verification-code input,
   **When** the engineer imports `AppOtpCodeField`, **Then** the
   widget is theme-aware and requires no focus-node or controller
   wiring from the caller.

---

### User Story 4 — Legacy recovery screens removed (Priority: P3)

As the owner of the codebase, I want the three legacy files
removed at the end of this feature. There must be exactly one
password-recovery path in the repo: the new one.

**Why this priority**: Per constitution principle I, a feature
is "migrated" only when its legacy files are deleted. Leaving
the three legacy screens as "just in case" is explicitly
forbidden.

**Independent Test**: On the merged branch,
`ls lib/screens/auth/` returns only legacy-but-out-of-scope
files (if any remain) — `forgot_password_screen.dart`,
`otp_screen.dart`, and `reset_password_screen.dart` are gone.
`grep -R 'ForgotPasswordScreen\|OtpScreen\|ResetPasswordScreen' lib/`
returns zero matches.

**Acceptance Scenarios**:

1. **Given** the feature is merged, **When** a grep runs for any
   of the three legacy class names, **Then** zero matches are
   found.
2. **Given** the app boots, **When** a user taps "forgot password"
   from the login page, **Then** the new flow is reached without
   any code still referring to the legacy classes.

---

### Edge Cases

- **Empty phone on the forgot-password screen**: client-side
  validator blocks submission with the legacy Arabic required-field
  message.
- **Unregistered phone**: server returns an error; the Cubit
  surfaces a typed reason and the page renders a localized banner.
- **Incomplete OTP (fewer than 6 digits)**: submit button disabled;
  if triggered programmatically, the Cubit rejects with a
  "enter the complete code" message matching today's legacy text.
- **Wrong OTP**: server rejects; the Cubit emits
  `OtpFailed(invalidCode)` and the page renders the localized
  banner. The user stays on the OTP screen (no navigation).
- **Resend OTP**: fires a fresh code request; UI shows a
  "code resent" snackbar matching legacy wording. The existing
  6 code fields clear.
- **Password mismatch on reset**: client-side validator blocks;
  no network call.
- **Password too short on reset**: client-side validator blocks;
  legacy min-length message.
- **Network loss mid-flow**: any of the three Cubits surface a
  `network` failure and the page shows the localized banner.
  In-flight navigation is blocked until the request resolves.
- **Back button mid-flow**: user can back out at any stage; no
  side effects stick (no half-reset state).
- **Language switch mid-flow**: Arabic/Hebrew/English — the new
  message headers update on navigation; the Auth-error mapper
  produces the same Arabic value in all three locales (same
  FR-007 continuation rule as feature 002).
- **User taps the submit button twice quickly**: each Cubit is
  idempotent while in its `Submitting` state — the second tap is
  a no-op.
- **OTP screen opened directly via deep-link without going through
  Forgot Password first**: out of scope — the current app has no
  such deep-link and this feature doesn't introduce one. The OTP
  page assumes it was opened from within the recovery flow.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a new forgot-password entry
  point that accepts a phone number, submits an OTP request, and
  surfaces `Loading` / `Success` / `Failure(reason)` via a Cubit.
- **FR-002**: The system MUST provide a new OTP-entry page that
  accepts a 6-digit code, submits verification against the server,
  and surfaces the same three states via a Cubit. A "resend" action
  triggers a fresh OTP request and shows a confirmation on success.
- **FR-003**: The system MUST provide a new reset-password entry
  point that accepts a new password + confirmation, submits the
  reset, and surfaces the three states via a Cubit.
- **FR-004**: The three pages MUST navigate sequentially:
  ForgotPassword → OTP → ResetPassword → back to the login page
  with a "password reset successfully" confirmation, preserving
  today's navigation semantics (pop-to-root on success).
- **FR-005**: All outbound HTTP calls MUST go through
  `getIt<Dio>()` and reference paths from `ApiEndpoints.*` — never
  raw string literals. This extends the same rule feature 002
  established for login/register.
- **FR-006**: The `AuthRepository` interface MUST be extended with
  `forgotPassword(phone)`, `verifyOtp(phone, code)`, and
  `resetPassword(phone, code, newPassword)`. A
  `resendOtp(phone)` method MAY be added or may reuse
  `forgotPassword` (implementation detail for `/speckit.plan`).
- **FR-007**: Error messages MUST match the current Arabic
  wording for every case the legacy screens produce today:
  required-field, unregistered-phone, wrong-OTP, expired-OTP (if
  applicable), incomplete-OTP, password-min-length,
  passwords-don't-match, generic network/server errors.
- **FR-008**: All user-facing strings MUST be localized in
  `ar`/`he`/`en`. Per research § R-005 from feature 002, the
  Arabic values are used verbatim in all three locales as the
  default; Hebrew/English translations are a future PR.
- **FR-009**: The three new pages MUST compose their UI from the
  five app-wide custom widgets introduced by feature 002
  (`AppTextField`, `AppPasswordField`, `AppPrimaryButton`,
  `AppErrorBanner`, `AppFormScaffold`) plus a new
  `AppOtpCodeField` that this feature introduces.
- **FR-010**: `AppOtpCodeField` MUST be implemented as a single
  reusable widget under `lib/presentation/widgets/`, accept a
  configurable length (defaulting to 6), expose a
  `ValueChanged<String>` for the current code, and expose a
  completion hook fired when the full code is entered. It MUST be
  theme-driven (no hardcoded colors, widths, or text styles).
- **FR-011**: Each of the three Cubits (`ForgotPasswordCubit`,
  `OtpCubit`, `ResetPasswordCubit`) MUST follow the same
  state-machine pattern established by `LoginCubit` in feature 002:
  `Initial → Submitting → Succeeded(...) | Failed(reason)`, with
  idempotent `submit()` while in `Submitting` state.
- **FR-012**: The new pages MUST NOT contain HTTP calls,
  `SharedPreferences` access, `ApiService` calls, or
  `notifyListeners`. They consume Cubit state only.
- **FR-013**: On completion, the three legacy files
  (`forgot_password_screen.dart`, `otp_screen.dart`,
  `reset_password_screen.dart`) MUST be deleted. The single
  external reference from the migrated `login_page.dart`
  (feature 002) MUST be updated to point at the new
  forgot-password route.
- **FR-014**: The `phone_verification` branch inside the legacy
  `OtpScreen` is **dead code** (no caller creates an
  `OtpScreen(type: 'phone_verification')` anywhere in the repo)
  and is explicitly **out of scope** — the migration preserves
  only the `password_reset` branch.
- **FR-015**: Unit tests MUST cover each of the three Cubit state
  machines (happy path + typed failure per `AuthFailureReason`
  variant that applies). Widget tests MUST cover at minimum a
  happy path for the forgot-password page and an error-banner
  render for the OTP page.

### Key Entities *(include if feature involves data)*

- **PhoneNumber** *(reused from feature 002 conventions)* — the
  phone string shared across all three Cubits as part of their
  state.
- **OtpCode** — the 6-digit code typed on the OTP screen;
  travels with the user from OTP screen to Reset screen as part
  of their Cubit input state.
- **ForgotPasswordCubit + states** — Initial /
  Submitting(phone) / Succeeded(phone) / Failed(reason).
- **OtpCubit + states** — Initial(phone) /
  Submitting(phone, code) / Succeeded(phone, verifiedCode) /
  Failed(reason). Also owns the `resend` action (a separate
  sub-state — `Resending` — or a side-effect depending on the
  plan phase's choice).
- **ResetPasswordCubit + states** — Initial(phone, code) /
  Submitting / Succeeded / Failed(reason).
- **AuthRepository** *(extended, not replaced)* — the existing
  interface gains three new methods. Its implementation
  (`AuthRepositoryImpl`) picks up new lines in
  `AuthResponseParser` to classify the new error cases.
- **AppOtpCodeField** *(new shared widget)* — the 6-digit code
  primitive introduced by this feature, reusable across future
  verification flows.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user who has forgotten their password can reach
  the login page with a working new password in **no more clicks
  and no more time** than on the pre-migration build.
- **SC-002**: 100% of the error-message cases mapped by the
  legacy `AuthProvider.forgotPassword` / `resetPassword` flows
  produce the same Arabic text on the new pages — verified by
  direct diff against the legacy wording.
- **SC-003**: The three new page files contain zero occurrences
  of `http`, `dio`, `SharedPreferences`, `ApiService`, or
  `notifyListeners` — verified by grep.
- **SC-004**: Each of the three new page files fits comfortably
  under 300 lines (constitution V soft target).
- **SC-005**: `AppOtpCodeField` is used in at least one place
  in this PR (the new OTP page) and is ready for reuse — a
  future caller constructs it with one constructor call and no
  focus-node / controller plumbing.
- **SC-006**: Upon completion, `grep -R 'ForgotPasswordScreen\|OtpScreen\|ResetPasswordScreen' lib/`
  returns zero matches.
- **SC-007**: Every user-facing string in the new pages has
  translations present in all three locales (`ar`/`he`/`en`)
  without loss vs. today's set.
- **SC-008**: Each of the three Cubits is unit-testable in
  isolation — at least 5 unit tests per Cubit exercise the state
  transitions without instantiating any Flutter widget.
- **SC-009**: Each Cubit rejects a second `submit` call issued
  while already in the `Submitting` state — verified by a unit
  test per Cubit.

## Assumptions

- The backend exposes a `verifyOtp` endpoint (or equivalent)
  that the new `OtpCubit` calls before advancing to the reset
  screen. If the backend does not have a separate verify
  endpoint, the `verifyOtp` call falls through to the
  reset-password call client-side (OTP is validated implicitly
  at reset time, matching today's legacy behavior). Plan phase
  resolves the endpoint question.
- Resend uses the same `forgotPassword(phone)` call or a
  dedicated `resendOtp(phone)` endpoint — plan phase decides
  based on server behavior. User-visible behavior is the same
  either way.
- The dead `phone_verification` branch in the legacy OTP screen
  is NOT migrated. If a future feature introduces phone
  verification during onboarding, it will create its own
  `PhoneVerificationCubit` on top of the new `AppOtpCodeField`.
- Error-message translations use the same "Arabic verbatim in
  all three locales" provisional pattern established by feature
  002 research § R-005. Hebrew/English translations are a
  separate future PR.
- The legacy `AuthProvider` keeps its `forgotPassword`,
  `verifyPhone`, `resendOtp`, and `resetPassword` methods for
  now. Removing them is part of the separate SessionCubit
  migration (feature 004) once all non-auth Provider consumers
  are gone.
- No new top-level routes are introduced — navigation between
  the three screens stays push-based, mirroring the legacy flow.
- Three locales (`ar`, `he`, `en`) with RTL support — preserved
  from feature 002.
- Target platforms: Android + iOS (web guarded but not
  targeted) — unchanged.
- This feature ships on top of feature 002 being merged to
  `main` (it is — commit `0846549`).
