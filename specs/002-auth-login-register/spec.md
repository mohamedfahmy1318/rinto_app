# Feature Specification: Auth (Login + Register) — Clean Architecture Migration

**Feature Branch**: `002-auth-login-register`
**Created**: 2026-04-23
**Status**: Draft
**Input**: User description: "عايز أبدأ تحويل ميزة الـ Auth (Login/Register) للـ Clean Architecture و Cubit. التزم بالـ Constitution v2.0.0. استخدم الـ ApiClient والـ ApiEndpoints اللي لسه مكرتينهم في الـ Core. اعمل AuthCubit لإدارة حالات الـ Loading والـ Error والـ Success. افصل الـ UI في الـ login_screen.dart بحيث تستخدم الـ Cubit الجديد وتعتمد على الـ Custom Widgets لتقليل الكود."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Existing user logs in through the migrated login screen (Priority: P1)

As a returning rento-go user, I open the app, tap "Log in", enter my
phone/email and password, and land on my home screen — with the same
speed, the same error messages, and the same pending-approval /
blocked-account handling I see today. Nothing about the visible
experience changes.

**Why this priority**: This is the primary auth entry point for the
entire app. A regression here breaks access to every authenticated
feature. This story is the migration's hard floor — if it doesn't
pass, nothing ships.

**Independent Test**: On the migrated branch, install the app, open
it, submit a known-good credential pair, confirm navigation to the
main screen and that the authenticated session carries through
(protected screens load without a second login prompt). Then submit
a known-bad pair, confirm the Arabic error message is identical to
the one shown pre-migration. Then submit credentials for a pending
account, confirm the "account under review" message still appears.

**Acceptance Scenarios**:

1. **Given** a user with valid credentials, **When** they submit the
   login form, **Then** the app navigates to the main screen and
   subsequent authenticated requests succeed (token attached by the
   network core).
2. **Given** a user submits wrong credentials, **When** the server
   returns 401/invalid, **Then** the user sees the same Arabic error
   message as today ("رقم الهاتف أو كلمة المرور غير صحيحة").
3. **Given** a user whose account is pending admin approval,
   **When** they submit correct credentials, **Then** the server's
   pending-status response is translated to the existing message
   ("حسابك قيد المراجعة من قبل الإدارة").
4. **Given** a user with a blocked account, **When** they submit,
   **Then** the blocked message appears exactly as today.
5. **Given** network loss mid-submission, **When** the request times
   out, **Then** a friendly "connection failed" message appears and
   the submit button returns to its normal state.
6. **Given** the login is in flight, **When** the user taps submit
   again, **Then** no duplicate request is fired and the spinner
   remains visible.

---

### User Story 2 — New user registers through the migrated register screen (Priority: P1)

As a first-time visitor, I open the app, tap "Register", fill in my
name, phone, email, password, and pick renter/landlord, then submit.
The same downstream flow I get today continues — success, or a
pending-approval notice, or a verification step.

**Why this priority**: Registration is the primary acquisition path.
It has several branching outcomes (immediate success, pending
approval, email/phone verification) that MUST all be preserved.

**Independent Test**: On the migrated branch, submit a new
renter-type registration with unique credentials and confirm the
expected downstream outcome — either immediate login, or the
pending/verification screen with the same text as today. Repeat for
landlord type. Submit a duplicate email/phone and confirm the
"already used" error in Arabic.

**Acceptance Scenarios**:

1. **Given** a new renter fills all required fields with unique
   credentials, **When** they submit, **Then** the flow outcome
   matches today (either authenticated and routed to main, or shown
   the "account pending approval" or "verification required" message
   as appropriate to the server response).
2. **Given** a user submits a duplicate email, **When** the server
   responds "email exists", **Then** the message in Arabic matches
   today's ("البريد الإلكتروني مستخدم مسبقاً").
3. **Given** the password field is shorter than 6 characters,
   **When** the user submits, **Then** the client-side validator
   rejects submission with the existing Arabic message.
4. **Given** the user picks landlord type, **When** the form shows
   the landlord-specific fields (company name, region, city),
   **Then** those fields behave as today (including the region ↓
   city dependency).
5. **Given** the register request is in flight, **When** the user
   taps submit again, **Then** no duplicate registration is
   attempted.

---

### User Story 3 — Cubit-driven state is clearly separated from UI (Priority: P2)

As an engineer reviewing the diff, I can open `login_page.dart` or
`register_page.dart` and read the widget tree in under a minute. The
file contains only layout and state-rendering code — no HTTP calls,
no `SharedPreferences` access, no business rules. State lives in a
Cubit I can open in a neighbouring file and understand in isolation.

**Why this priority**: This is the whole point of the migration as
far as the codebase is concerned. A migrated screen that still holds
business logic is failed work regardless of whether the user-visible
behavior is preserved.

**Independent Test**: Grep the new `login_page.dart` and
`register_page.dart` for any of: `http.`, `dio.`, `Dio`,
`SharedPreferences`, `ApiService`, `notifyListeners`. Expect **zero**
matches. Grep for `BlocBuilder`, `BlocListener`, `BlocConsumer`, or
`context.read<AuthCubit>`. Expect matches.

**Acceptance Scenarios**:

1. **Given** a reviewer opens the new login page, **When** they scan
   the file, **Then** they see only widget composition + Cubit
   consumption — no network, storage, or provider calls.
2. **Given** a Cubit test exists for `AuthCubit`, **When** the test
   runs, **Then** it exercises loading / success / failure state
   transitions without constructing any widget.

---

### User Story 4 — DRY through shared custom widgets (Priority: P2)

As an engineer, when I add the next auth screen (or migrate a
non-auth form), I can compose it from the same text-field, submit
button, loading overlay, and error-banner widgets that login and
register already use. I don't re-derive these primitives per
feature.

**Why this priority**: The constitution makes DRY through custom
widgets a hard rule. This migration is the first place we build the
shared vocabulary. Skipping this would make every subsequent
migration rebuild the same widgets, defeating the goal.

**Independent Test**: Inventory the new custom widgets. For each,
confirm it is used in BOTH the login and register screens (where
applicable). Confirm zero hard-coded colors, paddings, or text
styles inline in `login_page.dart` / `register_page.dart` — all
style values come from the theme / the custom widget.

**Acceptance Scenarios**:

1. **Given** a PR reviewer looks at `lib/presentation/widgets/`,
   **When** they compare login and register usage,
   **Then** both screens reference the same widget types (text
   fields, buttons, banners, scaffolds) rather than re-inlining
   them.
2. **Given** a future feature needs the same primitives, **When**
   the engineer imports from `lib/presentation/widgets/`,
   **Then** the widget is already there and theme-aware.

---

### User Story 5 — Legacy login/register are removed (Priority: P3)

As the owner of the codebase, I want the old `login_screen.dart` and
`register_screen.dart` files gone after this feature lands. The
repository must have exactly one place where login/register happens
— the new one.

**Why this priority**: Per the constitution: "a feature is
'migrated' only when … legacy files are deleted — not when they
coexist." Leaving the old files as "just in case" fallback is
explicitly forbidden.

**Independent Test**: On the merged feature branch, confirm that
`lib/screens/auth/login_screen.dart` and
`lib/screens/auth/register_screen.dart` no longer exist. Confirm
every route that previously pointed at `LoginScreen` / `RegisterScreen`
now points at `LoginPage` / `RegisterPage` (or equivalent names)
from the new presentation layer.

**Acceptance Scenarios**:

1. **Given** the feature is merged, **When** `grep -r LoginScreen`
   runs over `lib/`, **Then** no matches remain (class is deleted
   or renamed).
2. **Given** the app boots, **When** any route that previously
   navigated to the legacy login screen fires, **Then** it
   navigates to the new login page without code modification at the
   call site (routes updated as part of this feature).

---

### Edge Cases

- **Empty fields on submit**: validators block submission client-side
  with the existing Arabic messages; no request is sent.
- **Password visibility toggle**: preserved — user can reveal/hide
  the password as today.
- **Region → city dependency (register, landlord path)**: region
  selection loads the city list; same UX as today.
- **Language change mid-flow**: if the user switches language while
  the form is open, the next request carries the new locale header
  (already handled by the network core); in-flight request completes
  under its original language.
- **Device rotation / app backgrounded mid-submit**: Cubit state
  survives; the spinner keeps showing until the request completes.
- **Double-tap submit**: Cubit ignores new submit intents while in
  loading state.
- **Server returns unexpected 5xx**: generic "something went wrong"
  message in Arabic; no stack traces leaked to the user.
- **Empty token in a successful response**: rare server path where
  the user registered but is pending approval (no token issued) —
  the UI shows the approval message instead of treating it as an
  error.
- **FCM registration failure on Android post-login**: already
  non-fatal today (wrapped in a `try/catch` with a debug log); same
  behavior preserved.
- **Cold-start while form is open via deep-link**: `setupLocator()`
  completes before the first widget is built (guaranteed by the
  network core); Cubit construction succeeds.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a new login entry point that
  accepts either a phone number or an email plus a password, submits
  to the existing login endpoint, and surfaces `Loading` / `Success` /
  `Failure(message)` states to the UI through a Cubit.
- **FR-002**: The system MUST provide a new registration entry point
  that accepts all fields the current registration form accepts
  (name, optional company name for landlords, email, phone, password,
  user type, optional region/city), and surfaces the same three
  states to the UI.
- **FR-003**: All outbound HTTP calls from the new code path MUST go
  through the shared `Dio` client resolved via `getIt<Dio>()` and
  MUST reference endpoint paths only through `ApiEndpoints.authLogin`
  / `ApiEndpoints.authRegister` (never string literals).
- **FR-004**: On successful authentication (login or register with
  token), the new code path MUST update the shared `TokenReader`
  so the network interceptors carry the `Authorization` header on
  subsequent requests.
- **FR-005**: On successful authentication, the new code path MUST
  also update the legacy `AuthProvider` (via a guarded one-liner,
  mirroring the 001-feature pattern) so screens that still read
  `user` / `isLoggedIn` from the legacy provider continue to work
  without modification during the migration window.
- **FR-006**: On logout, the new code path (where reachable from
  migrated screens) MUST clear both the `TokenReader` and the legacy
  `AuthProvider` in the same transaction.
- **FR-007**: Error messages shown to the user MUST match the
  current Arabic translations character-for-character for every case
  the legacy code maps today: invalid credentials, pending approval,
  blocked account, email/phone already exists, invalid email/phone,
  weak password, required-field validation, generic fallback.
- **FR-008**: All user-facing strings (labels, placeholders, error
  messages, button captions) MUST be localized in `ar`, `he`, and
  `en` consistent with the existing app.
- **FR-009**: The new architecture MUST place files in Clean-Architecture
  layers per the constitution: `lib/data/**`, `lib/domain/**`,
  `lib/presentation/**`. No auth code lands outside these three
  directories (apart from DI wiring in `lib/core/di/`).
- **FR-010**: The new Cubit MUST depend on a domain-layer
  `AuthRepository` interface, not on `Dio` or any HTTP type.
- **FR-011**: Both the login page and the register page MUST compose
  their UI from reusable custom widgets. Repeated UI elements across
  the two pages (text fields, primary submit button, error banner,
  page scaffold) MUST be extracted into shared widgets under
  `lib/presentation/widgets/` per constitution principle IV (DRY).
- **FR-012**: The new pages MUST NOT contain network calls,
  `SharedPreferences` access, route-building, or business logic —
  those concerns live in the Cubit / repository / data-source.
- **FR-013**: Loading state MUST disable the submit control AND
  display a visible progress indicator; the Cubit MUST reject new
  submit intents while already in the loading state (preventing
  duplicate requests).
- **FR-014**: State transitions MUST be: `Initial → Submitting →
  Success(session)` or `Initial → Submitting → Failure(message) →
  (next submit returns to Submitting)`. The Cubit MUST not leak
  framework types (`DioException`, `Failure`) to the UI — only
  user-facing messages.
- **FR-015**: On completion of this feature, the legacy files
  `lib/screens/auth/login_screen.dart` and
  `lib/screens/auth/register_screen.dart` MUST be deleted. Every
  navigation target previously pointing at the legacy classes MUST
  be updated to the new pages.
- **FR-016**: The three legacy auth screens that are **not** in
  scope (`forgot_password_screen.dart`, `otp_screen.dart`,
  `reset_password_screen.dart`) MUST remain unchanged and continue
  to operate via the legacy `AuthProvider`. The legacy provider
  stays registered in `MultiProvider`.
- **FR-017**: Region → city dependency behavior in the register
  form MUST be preserved (selecting a region updates the city list).
- **FR-018**: Unit tests MUST cover the Cubit's state transitions
  (Initial → Submitting → Success / Failure) using a fake
  `AuthRepository`; widget tests MUST cover at minimum a happy-path
  login and a failure-path login on the new page.

### Key Entities *(include if feature involves data)*

- **AuthCredentials**: the login input — a phone-or-email identifier
  and a password. Domain-layer value object.
- **RegisterDetails**: the registration input — name, optional
  company name, email, phone, password, user type, optional region
  + city IDs. Domain-layer value object.
- **Session** *(a.k.a. authenticated user)*: the domain entity
  produced by a successful login or registration — token + user
  identity fields (id, name, email, phone, type, preferred_language,
  approval/verification flags).
- **AuthOutcome**: the domain-level union describing what can follow
  a registration: `Authenticated(session)`, `PendingApproval`,
  `VerificationRequired`, or `FailedWithMessage(text)`.
- **AuthRepository**: domain-layer interface — `login(credentials)`
  and `register(details)` returning an outcome.
- **AuthRemoteDataSource**: data-layer class that talks to the
  backend via the shared `Dio` client.
- **AuthCubit + AuthState**: presentation-layer state holder. State
  variants: `AuthInitial`, `AuthSubmitting`, `AuthSucceeded`,
  `AuthFailed(message)`, plus register-specific success variants
  (`AuthPendingApproval`, `AuthNeedsVerification`).
- **LoginPage / RegisterPage**: the new screen widgets under
  `lib/presentation/pages/auth/`.
- **Shared custom widgets** (produced by this feature, reusable
  downstream): an app text field, a primary submit button, an error
  banner, and an auth-page scaffold — at minimum.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A returning user can log in as fast on the migrated
  build as on the pre-migration build (no regression on happy-path
  time-to-authenticated, measured wall-clock on a mid-range Android
  device).
- **SC-002**: 100% of the error-message cases mapped by today's
  `_translateLoginError` and `_translateRegisterError` helpers
  produce the same Arabic text on the new pages — verified by
  direct diff.
- **SC-003**: The new `login_page.dart` and `register_page.dart`
  contain zero occurrences of `http`, `dio`, `Dio`,
  `SharedPreferences`, `ApiService`, or `notifyListeners` — verified
  by grep.
- **SC-004**: The new `login_page.dart` and `register_page.dart`
  each fit comfortably under 300 lines (constitution V soft target).
- **SC-005**: Every UI primitive reused between login and register
  is extracted into a shared widget — verified by confirming both
  pages import the same widget types and neither page re-implements
  a shared pattern inline.
- **SC-006**: Upon completion, the repository contains exactly one
  login code path and one register code path. `grep -R 'LoginScreen'
  lib/` returns zero matches; `grep -R 'RegisterScreen' lib/`
  returns zero matches.
- **SC-007**: Every user-facing string in the new pages has
  translations present in all three locales (`ar`, `he`, `en`)
  without loss vs. today's set.
- **SC-008**: AuthCubit is unit-testable in isolation — at least
  eight unit tests exercise the state transitions without
  instantiating any Flutter widget.
- **SC-009**: The AuthCubit rejects a second `submit` call issued
  while already in the `Submitting` state — verified by a unit test.

## Assumptions

- The legacy `AuthProvider` remains registered in `MultiProvider`
  and untouched apart from receiving success-state pushes from the
  new `AuthCubit`. Migration of downstream `AuthProvider` consumers
  (home, profile, chat, splash, FCM subscribe/unsubscribe) is
  explicitly **out of scope** and will be delivered by subsequent
  migrations.
- The three legacy auth flows not in scope —
  `forgot_password_screen.dart`, `otp_screen.dart`,
  `reset_password_screen.dart` — continue to operate via the legacy
  provider and will be migrated in a later feature. Their routes
  remain pointed at the legacy classes.
- FCM topic subscribe/unsubscribe calls currently inside
  `AuthProvider._saveAuth` / `logout` remain inside the legacy
  provider for this PR. They will move into a dedicated session
  manager when the next auth migration lands.
- The `login` identifier continues to accept either a phone number
  or an email, as today — no input-mode toggle introduced by this
  feature.
- The Arabic error-message translation table moves into a small
  domain helper (or a Failure-to-message mapper) inside
  `lib/domain/auth/` or `lib/presentation/auth/` — moving the
  *location* of the table is part of the refactor, but the *strings*
  themselves are preserved verbatim.
- Token + user persistence continues to use `SharedPreferences`
  under the existing `StorageKeys.token` / `StorageKeys.user`
  keys — migrating to `flutter_secure_storage` is deferred to a
  separate future feature.
- The typed `Failure` sealed stub introduced by feature 001 remains
  in stub form for this PR. The `AuthRepository` catches
  `DioException` at the repository boundary and maps to an
  auth-specific error type the Cubit can pattern-match — this
  feature introduces the mapping it needs but does not deliver the
  app-wide `NetworkFailure` / `ServerFailure` work.
- Three locales (`ar`, `he`, `en`) with RTL for Arabic and Hebrew —
  preserved.
- Target platforms: Android + iOS (web guarded but not targeted) —
  unchanged.
- The feature ships on top of feature 001's foundation and depends
  on it being present on `main` (it already is).
