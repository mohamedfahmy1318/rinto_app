# Quickstart: Adding or touching code in the migrated Auth stack

This file is the runtime-level guide for engineers after feature 002
lands. It describes how to extend the Auth feature, add a new form
screen anywhere in the app, or migrate the **next** feature using the
patterns this PR establishes.

---

## TL;DR

- **Navigate to login/register**: `Navigator.push(context, loginRoute())` or `registerRoute()`.
- **Inside a page**: `context.read<LoginCubit>().submit(credentials)` / `ctx.watch<LoginCubit>().state` for rendering.
- **Form primitives**: use `AppTextField`, `AppPasswordField`, `AppPrimaryButton`, `AppErrorBanner`, `AppFormScaffold`.
- **Auth errors → localized strings**: `failureReasonToMessage(ctx, reason, op: AuthOperation.login)`.
- **Legacy consumers keep reading** `context.watch<AuthProvider>()` — no change needed.

---

## Add a new auth screen (e.g. migrate OTP)

Follow the same layering:

1. Domain entity for the OTP request, interface method on
   `AuthRepository` (or a new `OtpRepository`).
2. Data impl via `getIt<Dio>()` + `ApiEndpoints.otpVerify` (add to
   the catalog if missing).
3. `OtpCubit` + `OtpState` under
   `lib/presentation/auth/cubits/otp/`.
4. `OtpPage` under `lib/presentation/auth/pages/` using the existing
   `AppFormScaffold`, `AppTextField`, etc.
5. Add `otpRoute()` to `auth_routes.dart`.
6. Switch the route call site that today navigates to `OtpScreen`
   to `otpRoute()`.
7. **Delete** `lib/screens/auth/otp_screen.dart`.

Reuse what's already there — do NOT re-derive the form scaffold or
primary button.

---

## Show an error coming from the backend

```dart
// Any new Cubit that emits AuthFailureReason:
emit(MyFailed(reason));

// In the page:
if (state is MyFailed) {
  return AppErrorBanner(
    message: failureReasonToMessage(ctx, state.reason,
        op: AuthOperation.login),
  );
}
```

The `failureReasonToMessage` function is a pure function exported
from `lib/presentation/auth/auth_error_messages.dart`. It reads
`AppLocalizations` — do not hardcode strings at the call site.

---

## Add a new error reason

1. Add a variant to `AuthFailureReason` (Domain).
2. Add a mapping row to `AuthResponseParser` (Data) — so the variant
   is produced when the server returns the matching shape.
3. Add the localization key + Arabic text in
   [lib/core/localization/app_localizations.dart](../../lib/core/localization/app_localizations.dart)
   — three blocks (`ar` / `he` / `en`).
4. Add the row to `failureReasonToMessage` (Presentation).
5. Add a test case in `auth_response_parser_test.dart`.

Five files, one per layer. Any subset is incorrect and will fail
review.

---

## Add a new form field to register

Example: adding an optional "address" field.

1. Add `address: String?` to `RegisterDetails` (Domain).
2. Add the field to `RegisterRequestBody` mapping in
   `AuthRemoteDataSource`'s body builder.
3. Add an `AppTextField` to `register_page.dart` bound to a
   `TextEditingController`.
4. Pass the value through to `registerCubit.submit(...)`.
5. Add the label to `AppLocalizations` in all three locales.

Notice: **no edits to the Cubit or the repository interface** — the
new field flows through existing types transparently.

---

## Wire a new Cubit into DI

In `lib/core/di/service_locator.dart`, after the repository
registrations:

```dart
// Cubits are NOT registered as singletons — they're created per
// page via BlocProvider so each page gets a fresh instance. But
// their dependencies are singletons.
```

That's it — the Cubit itself is constructed at the page scope
inside `*_route()` helpers in `auth_routes.dart`. Don't register
Cubits in `getIt`.

---

## Test a new Cubit

```dart
// test/presentation/auth/cubits/my_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
    registerFallbackValue(const AuthCredentials(login: '', password: ''));
  });

  blocTest<LoginCubit, LoginState>(
    'emits [Submitting, Succeeded] on happy-path login',
    build: () => LoginCubit(repository: repo),
    setUp: () {
      when(() => repo.login(any())).thenAnswer((_) async => _fakeSession);
    },
    act: (cubit) => cubit.submit(const AuthCredentials(
      login: '+972501234567', password: 'secret',
    )),
    expect: () => [
      isA<LoginSubmitting>(),
      isA<LoginSucceeded>(),
    ],
  );
}
```

Use `bloc_test`'s `blocTest(...)` rather than hand-rolling
`emitsInOrder`. One test per state sequence.

---

## FAQ

**Q: Why is there both a `LoginCubit` and an `AuthProvider`?**
`AuthProvider` is legacy and serves the ~15 non-auth screens that
still read authentication state via Provider. `LoginCubit` owns only
the login page's form state. They are bridged via a 2-line
`BlocListener` in the page — see
[contracts/legacy_bridge.contract.md](contracts/legacy_bridge.contract.md).
The bridge deletes when the last non-auth screen migrates off
Provider.

**Q: Why did the register page get location pickers but not the
login page?**
Login doesn't need location data. The register form needs it for
landlord-type accounts. A later migration (search, add listing, etc.)
will also need it; by then `LocationsRepository` is already in place.

**Q: Can I reuse `AppTextField` in a non-auth feature?**
Yes — it lives in `lib/presentation/widgets/`, app-wide. Same for
`AppPasswordField`, `AppPrimaryButton`, `AppErrorBanner`,
`AppFormScaffold`.

**Q: Where do I put new app-wide widgets?**
`lib/presentation/widgets/`. Use them from at least two places
immediately or skip creating them — constitution principle IV says
DRY kicks in at usage #2, not #1.

**Q: Why two Cubits instead of one `AuthCubit`?**
See [research.md § R-001](research.md#r-001-one-authcubit-vs-two-cubits-logincubit--registercubit).
Summary: separate concerns, simpler state machines, smaller test
files.

**Q: Why is the `RegisterCubit` state carrying `regions` and `cities`
at all times instead of having a nested "locations" sub-state?**
Flat state → flat rendering. The register page always shows the
pickers; the data is either there or loading. A nested sub-state
forces the page to traverse two discriminator levels to render.

**Q: How do I migrate the next legacy screen?**
Take the same steps this PR documents. Start with `/speckit.specify`
describing the next screen, cite this feature's patterns in
Assumptions, land the follow-up feature. The foundation + patterns
are already there; subsequent migrations should be mostly
mechanical.
