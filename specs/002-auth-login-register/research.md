# Phase 0 Research: Auth (Login + Register) Clean Architecture Migration

Scope: resolve every design decision the plan depends on so Phase 1 can
produce concrete contracts. One row per decision.

---

## R-001: One `AuthCubit` vs two Cubits (`LoginCubit` + `RegisterCubit`)

**Question**: The user's prompt says "اعمل AuthCubit" (make an
AuthCubit) — singular. Should we build one Cubit handling both login
and register, or split into two?

**Decision**: **Two Cubits** — `LoginCubit` and `RegisterCubit` — under
`lib/presentation/auth/cubits/{login,register}/`.

**Rationale**:
- Single-responsibility: `LoginCubit` has exactly one submit action
  with three post-states (Succeeded / Failed / Initial). `RegisterCubit`
  has a submit + a separate `loadLocations` action and five post-states
  (Authenticated / PendingApproval / NeedsVerification / Failed /
  Initial). Merging them into one state machine produces a confused
  union with many invalid state combinations (a single instance can't
  usefully be "submitting login" and "awaiting register verification"
  at the same time — but a combined state class would need to model
  that transition or forbid it).
- Smaller files: each Cubit + state file lands comfortably under 150
  lines; a merged Cubit would be ~250+.
- Independent testability: `LoginCubit`'s tests don't need to stub
  out `loadLocations`; `RegisterCubit`'s tests don't need to stub
  out login flows.
- "AuthCubit" in the user's message is idiomatic Arabic shorthand for
  "use Cubit for auth state" — the count is prose, not a class-count
  requirement. We honour the spirit (Cubit for both screens) without
  forcing one class.

**Alternatives considered**:
- Single `AuthCubit` with verbs `login()` / `register()`: leads to
  state ambiguity as described above; rejected.
- Three Cubits (LoginCubit, RegisterCubit, LocationsCubit inside the
  feature): the locations load is small and only needed by register;
  promoting it to its own Cubit is premature until a second consumer
  arrives (expected in a later migration).

---

## R-002: Locations as a standalone domain module

**Question**: Do `Region` and `City` live in `lib/domain/auth/entities/`
(because the only current consumer is register) or in their own
`lib/domain/locations/`?

**Decision**: Own module — `lib/domain/locations/` + `lib/data/locations/`.

**Rationale**:
- The Region / City entities are semantically not authentication
  concepts. Placing them under `domain/auth/` would force the next
  consumer (search, edit listing, add listing — all expected to
  migrate later) to either duplicate them or move them with churn.
- Cost today is minimal: 6 small new files (2 entities, 1 interface,
  2 DTOs, 1 remote data source, 1 repo impl) versus the risk of a
  future relocation touching multiple PRs.
- Matches the constitution's three-layer split precisely — Data,
  Domain, Presentation per feature, with modules organised by
  business concept (auth, locations) rather than by who-uses-what.

**Alternatives considered**:
- Put entities under `domain/auth/`: cheaper now, painful later;
  rejected.
- Expose Data-layer DTOs directly to the Cubit: violates the
  dependency rule (Presentation → Data); rejected.

---

## R-003: Domain error modelling — typed enum vs extending `Failure`

**Question**: How do we model auth errors (invalid credentials,
blocked, pending, email exists, ...) without leaking `DioException`
to the Cubit?

**Decision**: A flat `enum AuthFailureReason { ... }` in
`lib/domain/auth/auth_failure_reason.dart`, separate from the base
`Failure` hierarchy introduced by feature 001.

**Rationale**:
- The app-wide `Failure` sealed hierarchy (feature 001) is designed
  for cross-cutting errors (`NetworkFailure`, `ServerFailure`,
  `UnexpectedFailure`). Auth has domain-specific semantic variants
  (pending, blocked) that aren't really "server errors" — they're
  valid server responses to legitimate login attempts.
- Using a simple enum keeps the Cubit's pattern matching compact
  (`switch (reason) { ... }`) and makes the Arabic-message mapper
  (R-005) an exhaustive function with compiler-checked coverage.
- The repository catches `DioException` + payload shape and maps
  both dimensions to a reason in one place (`AuthResponseParser`,
  R-004).

**Variants** (matches every case the legacy `_translateLoginError` /
`_translateRegisterError` handles):
```
AuthFailureReason {
  invalidCredentials,        // login: 'invalid' or 'credentials'
  accountPendingApproval,    // login: 'pending' or 'approval'
  accountBlocked,            // login: 'blocked'
  emailAlreadyExists,        // register: 'email exists' / 'email already'
  phoneAlreadyExists,        // register: 'phone exists' / 'phone already'
  invalidEmail,              // register: 'invalid email'
  invalidPhone,              // register: 'invalid phone'
  weakPassword,              // register: 'password' + 'least'
  missingRequiredFields,     // 'required'
  validationFailed,          // register: 'validation'
  network,                   // DioException connectionError/timeout
  unknown,                   // fallback
}
```

**Alternatives considered**:
- Extend `Failure` with `AuthFailure extends ServerFailure`: forces
  a sealed hierarchy that doesn't add real value for enum-like
  variants. Rejected.
- Use string messages throughout: loses compiler-checked exhaustiveness
  in the message mapper; rejected.

---

## R-004: Server response → `AuthFailureReason` mapping location

**Question**: Where does the server-message classification live (the
logic that currently sits in `_translateLoginError` /
`_translateRegisterError` inside `AuthProvider`)?

**Decision**: In a pure function/class `AuthResponseParser` under
`lib/data/auth/auth_response_parser.dart`. Takes an `ApiResponse` +
the operation (`AuthOperation.login` or `.register`), returns either
a `Session` (on success) or an `AuthFailureReason`.

**Rationale**:
- Pattern-matching server strings is a **data-layer** concern (it
  knows the backend's quirks). Domain stays clean.
- Pure function → 100% unit-testable with a single file covering every
  legacy mapping case. The test is the regression guard that FR-007's
  "character-exact" preservation relies on.
- Keeps the repository impl thin: "call data source → parse response →
  return Domain shape."

**Test plan**: a table-driven test listing every legacy string case
the old helpers recognise, each asserting the expected reason. If
the legacy helpers handle a case we miss, the test discovers it
during code review.

**Alternatives considered**:
- Map inside the repository impl: works, but harder to test in
  isolation. Rejected.
- Map inside the Cubit: violates the direction rule (Presentation
  shouldn't know server strings). Rejected.

---

## R-005: Arabic error-message localization

**Question**: The current `_translateLoginError` /
`_translateRegisterError` helpers return hardcoded Arabic strings.
They are NOT passed through `AppLocalizations`, so non-Arabic users
still see Arabic text. FR-007 says "character-exact preservation."
What do we do?

**Decision**: Introduce ~12 new localization keys in
`lib/core/localization/app_localizations.dart` (one per
`AuthFailureReason` variant). For this PR, set the **value in all
three locales (`ar`, `he`, `en`) to the same Arabic string** the
legacy code produces today. This moves the location (provider →
localization file) without changing the user-visible behaviour.

Future PR can translate the `he` and `en` values — that is a
one-file change with no code touches. We do NOT silently "fix" the
pre-existing i18n gap in this PR because FR-007 commits to
character-exact preservation; we do surface the gap structurally
(separate key per reason in a localization file) so the fix is
cheap.

**Mapping (reason → key → current Arabic text)**:

| Reason | Key | Current Arabic |
|--------|-----|----------------|
| `invalidCredentials` | `auth_error_invalid_credentials` | رقم الهاتف أو كلمة المرور غير صحيحة |
| `accountPendingApproval` | `auth_error_account_pending` | حسابك قيد المراجعة من قبل الإدارة |
| `accountBlocked` | `auth_error_account_blocked` | تم حظر حسابك |
| `emailAlreadyExists` | `auth_error_email_exists` | البريد الإلكتروني مستخدم مسبقاً |
| `phoneAlreadyExists` | `auth_error_phone_exists` | رقم الهاتف مستخدم مسبقاً |
| `invalidEmail` | `auth_error_invalid_email` | البريد الإلكتروني غير صالح |
| `invalidPhone` | `auth_error_invalid_phone` | رقم الهاتف غير صالح |
| `weakPassword` | `auth_error_weak_password` | كلمة المرور يجب أن تكون 6 أحرف على الأقل |
| `missingRequiredFields` | `auth_error_missing_fields` | يرجى إدخال جميع الحقول المطلوبة |
| `validationFailed` | `auth_error_validation_failed` | يرجى التحقق من البيانات المدخلة |
| `network` | `auth_error_network` | فشل الاتصال بالخادم |
| `unknown` | `auth_error_unknown_login` / `auth_error_unknown_register` | فشل تسجيل الدخول / فشل التسجيل |

**The presentation-layer mapper** (one tiny file under
`presentation/auth/`) is a pure `String failureReasonToMessage(BuildContext
ctx, AuthFailureReason reason, {required AuthOperation op})` function
that calls `ctx.tr(key)` per the table.

**Alternatives considered**:
- Silently fix the i18n bug by translating Hebrew and English
  strings now: violates FR-007's literal reading. Out of scope.
- Keep the strings hardcoded in Presentation (not through
  AppLocalizations): same i18n bug in a new location; pointless.
  Rejected.

---

## R-006: Legacy-provider bridge — how the new Cubit updates the old `AuthProvider`

**Question**: Downstream legacy screens read `user`, `isLoggedIn`,
and related fields from `context.watch<AuthProvider>()`. After the
new `LoginCubit` succeeds, how does that state reach the legacy
provider?

**Decision**: A two-part bridge:
1. Add two new public methods to `AuthProvider`:
   - `Future<void> hydrateFromSession(Session session)` — mirrors
     the existing `_saveAuth` flow but takes the Domain `Session`
     instead of a raw response map, and does NOT re-hit the network.
   - `Future<void> clearSession()` — mirrors the existing `logout`
     cleanup without hitting the network (so the new Cubit can
     trigger a local-only logout if needed).
2. In `login_page.dart` and `register_page.dart`, add a
   `BlocListener<LoginCubit, LoginState>` (or `RegisterCubit`) that
   calls `context.read<AuthProvider>().hydrateFromSession(state.session)`
   on a `Succeeded`-variant state, then navigates.

**Rationale**:
- Keeps the Cubit free of any `provider` / `AuthProvider` imports —
  Presentation's concession is a single two-line listener per page,
  which is semantically where post-success effects belong in Cubit
  patterns.
- Keeps the `AuthRepository` (Data) layer free of legacy concerns —
  the repository doesn't know or care that a legacy provider exists.
- The `hydrateFromSession` / `clearSession` methods delete cleanly
  when the last non-auth consumer of `AuthProvider` migrates off
  Provider.

**FCM topic subscribe/unsubscribe**: continues to happen inside
`AuthProvider._saveAuth` / `logout`, now invoked via the new
`hydrateFromSession` / `clearSession` methods. This preserves the
existing Android-only FCM behaviour without the new code path
needing to know about FCM.

**Alternatives considered**:
- Register `AuthProvider` in `getIt` as well, so the new Cubit can
  resolve it directly: introduces a cycle between the two DI
  systems and makes Presentation depend on a legacy class.
  Rejected.
- Move the `BlocListener` shim into the Cubit via a callback
  injected at construction: works but hides the legacy dependency
  at the wiring site (`auth_routes.dart`) instead of making it
  visible on the page. Rejected.

---

## R-007: Where `auth_routes.dart` lives and what it exposes

**Question**: Legacy code navigates with `MaterialPageRoute(builder:
(_) => const LoginScreen())`. The new code needs to wrap the page in
a `BlocProvider`. Where does this wiring live?

**Decision**: A new helper file `lib/presentation/auth/auth_routes.dart`
exports two top-level functions:

```dart
Route<dynamic> loginRoute();
Route<dynamic> registerRoute();
```

Each returns a `MaterialPageRoute` whose `builder` constructs a
`BlocProvider<LoginCubit>` (resp. `RegisterCubit`) with dependencies
resolved from `getIt`, and places the matching page inside.

**Rationale**:
- Call sites stay one-line drop-ins: `Navigator.push(context,
  loginRoute())`. No `BlocProvider` noise leaks into legacy screens.
- Single place to update when the Cubit's constructor signature
  changes.
- Easy to swap for `go_router` registration later.

**Alternatives considered**:
- Inline `BlocProvider` at every call site: noisy, repetitive,
  violates DRY. Rejected.
- Keep `LoginScreen` as a thin public re-export that internally wraps
  `LoginPage + BlocProvider`: defers the legacy deletion (FR-015);
  rejected because the constitution says migration requires deletion.

---

## R-008: User-type modelling

**Question**: The current register screen hardcodes four user-type
values as `Map<String,String>` entries in a list with Arabic labels.
How does the new code model this?

**Decision**: A domain enum `UserType` in
`lib/domain/auth/entities/user_type.dart`:

```dart
enum UserType {
  renter,
  owner,
  office,
  carLessor;

  String get apiValue => switch (this) {
    UserType.renter    => 'renter',
    UserType.owner     => 'owner',
    UserType.office    => 'office',
    UserType.carLessor => 'car_lessor',
  };

  /// AppLocalizations key for the display label.
  String get labelKey => switch (this) {
    UserType.renter    => 'user_type_renter',
    UserType.owner     => 'user_type_owner',
    UserType.office    => 'user_type_office',
    UserType.carLessor => 'user_type_car_lessor',
  };
}
```

The `UserTypeSelector` widget renders each enum value using its
`labelKey` via `ctx.tr(...)`. The four labels (currently hardcoded in
the legacy screen) move into `AppLocalizations` (all three locales,
Arabic values in all three initially per R-005's pattern).

**Rationale**: compiler-checked exhaustiveness, no more stringly-typed
user types, displayed labels are localized properly in all three
locales.

**Alternatives considered**:
- Keep the list-of-maps: doesn't satisfy Clean Arch (no domain type).
  Rejected.
- Promote `UserType` to a first-class Domain entity with value-object
  equality: enums with methods are Dart-idiomatic and give us the
  same value semantics; no need for extra class. Keep as enum.

---

## R-009: Test library additions

**Question**: Which test libraries do we add for the Cubit + repository?

**Decision**:
- `bloc_test ^9.1.x` — first-class `blocTest()` helper with
  `build`/`act`/`seed`/`expect` ergonomics designed for Cubit state
  sequences. Written by the `flutter_bloc` authors, stays in lockstep
  with `flutter_bloc ^8.1`.
- `mocktail ^1.0.x` — mock-object builder that doesn't require
  codegen (unlike `mockito`). Smaller surface, fits the "simple code"
  principle.

Both go under `dev_dependencies`.

**Rationale**: these are the de-facto standard pairing for testing
Cubits in 2026 Flutter projects. Keeps test files compact and
idiomatic.

**Alternatives considered**:
- `mockito` + `build_runner`: requires codegen which adds a build
  step. Overkill for the test count we expect. Rejected.
- Hand-rolled fakes only (no mock lib): works for the small test
  surface but produces more boilerplate as the test count grows.
  Split the difference — use hand-rolled fakes where they're ergonomic
  (simple value types, the data sources) and mocktail where the
  abstract type has many methods (the repository interface).

---

## R-010: Widget inventory — which primitives land in this PR

**Question**: The constitution requires DRY through custom widgets.
Which specific widgets do we build, and which are app-wide vs
auth-scoped?

**Decision**: 9 widgets total.

**App-wide** (under `lib/presentation/widgets/`, used by 2+ places
in this PR alone and available for every subsequent migration):

| Widget | Purpose |
|--------|---------|
| `AppTextField` | Themed wrapper over `TextFormField`; accepts label, hint, prefix icon, validator, controller, keyboard type, text direction. No hardcoded styling inline. |
| `AppPasswordField` | Specialisation that owns an internal `obscure` toggle and visibility icon; accepts label, validator, controller. Used in login (password) + register (password + confirm). |
| `AppPrimaryButton` | `ElevatedButton` wrapper with a built-in `isLoading` mode (disables + shows a 20×20 spinner). Identical look to the current login/register buttons. |
| `AppErrorBanner` | Inline red banner used to render a Cubit `Failed` state above the submit button. Replaces the current SnackBar-on-error pattern (less intrusive, doesn't disappear while the user reads). |
| `AppFormScaffold` | Scaffold + AppBar + SafeArea + SingleChildScrollView + padded Form. The entire outer chrome of every auth page. |

**Auth-scoped** (under `lib/presentation/auth/widgets/`, reused
between login and register within this PR and by subsequent auth
migrations like OTP / reset password):

| Widget | Purpose |
|--------|---------|
| `UserTypeSelector` | Four-way `ChoiceChip` row (renter / owner / office / car_lessor) bound to a `UserType` value. |
| `TermsCheckbox` | Checkbox + legal-text RichText with a tappable "terms" link that opens the existing terms dialog. Used only on register today; widget is auth-scoped because the link text is auth-specific. |
| `RegionPicker` | Dropdown of `Region` entities; emits the selected region ID and triggers `CityPicker` filtering. |
| `CityPicker` | Dropdown of `City` entities filtered by the currently-selected region. Handles "region changed → clear city" invariant internally. |

**Rationale**: every widget listed is either used by both login AND
register (app-wide) or by both register AND a planned future auth
screen (auth-scoped). No widget is "forked per caller" and no widget
hardcodes theme values.

**Alternatives considered**:
- More widgets (e.g. `AppSocialButton`, `AppVerificationCodeField`):
  not needed by the two screens in scope; deferred.
- Fewer widgets (e.g. no `AppFormScaffold`): violates DRY once the
  second page repeats the same scaffold chrome. Kept.

---

## R-011: Legacy-route update strategy

**Question**: Seven legacy screens currently `Navigator.push` to
`LoginScreen` / `RegisterScreen`. How do we update them without
exploding scope?

**Decision**: Touch only the route-construction lines. Each call site
changes from:
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const LoginScreen()));
```
to:
```dart
Navigator.push(context, loginRoute());
```

That is the entire change per site. No refactoring of the legacy
screen, no renaming, no reformatting.

**Affected files (verified by grep)**:
- `lib/screens/home/home_screen.dart`
- `lib/screens/my_listings/my_listings_screen.dart`
- `lib/screens/profile/profile_screen.dart`
- `lib/screens/packages/packages_screen.dart`
- `lib/screens/listing_details/listing_details_screen.dart` (2 sites)
- `lib/screens/splash_screen.dart`
- `lib/presentation/auth/pages/login_page.dart` (navigates to register
  internally; uses `registerRoute()` — this is new code, not a legacy edit)

**Rationale**: minimal, reviewable, scoped to the migration.

---

## R-012: Confirm-password field handling

**Question**: The register form has a confirm-password field. Does
that go into `RegisterDetails` (Domain) or stay Presentation-only?

**Decision**: Presentation-only. The `RegisterDetails` entity carries
a single `password`. The `RegisterPage` validates `password ==
confirmPassword` in a form validator before calling
`registerCubit.submit(details)`.

**Rationale**: Confirm-password is a UX validation, not a domain
concept. The server has no notion of it. Placing it in Domain would
leak a presentation concern downward.

---

## R-013: Cubit submit idempotency

**Question**: Spec FR-013 and SC-009 say the Cubit must reject a
second `submit` while already in `Submitting` state. How is that
enforced?

**Decision**: Both Cubits check the current state at the top of
`submit()`:
```dart
Future<void> submit(AuthCredentials credentials) async {
  if (state is LoginSubmitting) return;       // idempotent no-op
  emit(const LoginSubmitting());
  ...
}
```

Tests prove this by calling `submit()` twice in rapid succession and
asserting only one state transition to `Submitting` is emitted.

**Rationale**: simplest correct pattern. The submit button is also
disabled in UI when `state is Submitting`, but the Cubit guard is
the defensive layer that protects against edge cases
(programmatic re-submit, stale button tap delivered after the
spinner appeared).

---

## Consolidated decisions summary

| Area | Decision |
|------|----------|
| Cubit count | Two: `LoginCubit`, `RegisterCubit` |
| Locations module | Standalone `domain/locations/` + `data/locations/` |
| Error modelling | Enum `AuthFailureReason` (separate from base `Failure`) |
| Server-message mapping | `AuthResponseParser` in `data/auth/` (pure function) |
| Arabic error localization | ~12 new keys in AppLocalizations; Arabic values in all three locales initially |
| Legacy-provider bridge | `hydrateFromSession` + `clearSession` on AuthProvider; called from `BlocListener` on pages |
| Route wiring | `auth_routes.dart` helpers hide `BlocProvider` at call sites |
| User types | Domain `enum UserType` with `.apiValue` / `.labelKey` |
| Test libs added | `bloc_test ^9.1`, `mocktail ^1.0` (dev_dependencies) |
| Widgets this PR | 5 app-wide + 4 auth-scoped (9 total) |
| Legacy route edits | 7 files touched; route-construction lines only, nothing else |
| Confirm-password | Presentation-only |
| Cubit idempotency | Early-return if already in Submitting state |

No `NEEDS CLARIFICATION` items remain.
