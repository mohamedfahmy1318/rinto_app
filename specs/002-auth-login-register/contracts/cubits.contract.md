# Contract: `LoginCubit` + `RegisterCubit`

**Files**:
- `lib/presentation/auth/cubits/login/{login_cubit,login_state}.dart`
- `lib/presentation/auth/cubits/register/{register_cubit,register_state}.dart`

**Consumed by**: `LoginPage`, `RegisterPage` via `BlocProvider` +
`BlocBuilder` / `BlocListener`.
**Status**: stable.

---

## 1. `LoginCubit`

### State surface

```dart
sealed class LoginState extends Equatable {
  const LoginState();
  @override List<Object?> get props => const [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginSucceeded extends LoginState {
  const LoginSucceeded(this.session);
  final Session session;
  @override List<Object?> get props => [session];
}

final class LoginFailed extends LoginState {
  const LoginFailed(this.reason);
  final AuthFailureReason reason;
  @override List<Object?> get props => [reason];
}
```

### API

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository repository})
    : _repository = repository,
      super(const LoginInitial());

  final AuthRepository _repository;

  /// Attempts to log in. Idempotent while already submitting (early
  /// return — no duplicate state emission, no duplicate network call).
  Future<void> submit(AuthCredentials credentials);

  /// Returns to [LoginInitial]. Useful for dismissing a persistent
  /// error banner after the user edits the form.
  void reset();
}
```

### State transitions

```text
     ┌───────────┐  submit()   ┌──────────────┐
     │ Initial   │────────────▶│  Submitting  │
     └───────────┘             └──────┬───────┘
           ▲                          │
           │                          │
           │ reset()                  ▼
     ┌─────┴─────┐             ┌──────────────┐
     │  Failed   │◀────────────│  Submitting  │
     └───────────┘   error     └──────┬───────┘
                                      │ success
                                      ▼
                              ┌──────────────┐
                              │  Succeeded   │
                              └──────────────┘
```

Invariant: no transition out of `Submitting` except to `Succeeded`
or `Failed` (no direct `Submitting → Initial`).

### Invariants

- **Idempotent submit**: `submit()` called while `state is LoginSubmitting`
  returns immediately without emitting a new state.
- **No side effects outside `AuthRepository`**: the Cubit does not
  touch storage, navigation, Provider, or `context`. Its only
  outbound call is `_repository.login(...)`.
- **No framework imports**: the Cubit file imports `bloc`, `equatable`,
  Domain types. It MUST NOT import `flutter_bloc`, `flutter/material`,
  `dio`, or `provider`.

---

## 2. `RegisterCubit`

### State surface

```dart
sealed class RegisterState extends Equatable {
  const RegisterState({
    required this.regions,
    required this.cities,
    required this.isLocationsLoading,
  });

  final List<Region> regions;
  final List<City> cities;
  final bool isLocationsLoading;

  @override List<Object?> get props => [regions, cities, isLocationsLoading];
}

final class RegisterInitial extends RegisterState { ... }
final class RegisterLocationsFailed extends RegisterState {
  final Object? cause;   // for debug only; UI surfaces a retry
}
final class RegisterSubmitting extends RegisterState { ... }
final class RegisterSucceededAuthenticated extends RegisterState {
  final Session session;
}
final class RegisterPendingApprovalState extends RegisterState {
  final String message;
}
final class RegisterNeedsVerificationState extends RegisterState {
  final String message;
}
final class RegisterFailed extends RegisterState {
  final AuthFailureReason reason;
}
```

`regions` / `cities` / `isLocationsLoading` travel with every state
variant so the page can keep rendering the location pickers while a
submit is in flight.

### API

```dart
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required AuthRepository authRepository,
    required LocationsRepository locationsRepository,
  });

  /// Loads regions + cities from the locations repository and stores
  /// them on the state. Callers fire this from the page's
  /// `initState`. Reentrant-safe: concurrent calls coalesce.
  Future<void> loadLocations();

  /// Submits the register request. Idempotent while already submitting.
  Future<void> submit(RegisterDetails details);

  /// Returns to Initial (preserves loaded regions/cities).
  void reset();
}
```

### State transitions

```text
  Initial (locationsLoading=true)
     │
     │ loadLocations() resolves
     ▼
  Initial (locationsLoading=false, regions/cities populated)
     │
     │ submit(details)
     ▼
  Submitting
     │
     ├─── session has token  ─────▶ SucceededAuthenticated
     ├─── requires_approval  ─────▶ PendingApprovalState
     ├─── requires_verify    ─────▶ NeedsVerificationState
     └─── AuthException     ─────▶ Failed(reason)
                                       │
                                       │ reset()
                                       ▼
                                    Initial (locations preserved)
```

If `loadLocations` fails, state transitions to `RegisterLocationsFailed`
(still usable — submit can proceed if the user skips optional region
/ city; page UI offers a retry button).

### Invariants

- Same idempotent-submit, no-side-effects, no-framework-imports rules
  as `LoginCubit`.
- Post-login / post-register navigation is driven by the page's
  `BlocListener`, not the Cubit. The Cubit emits a state; the page
  reacts.

---

## 3. Page-level consumption contract

### Construction

```dart
// lib/presentation/auth/auth_routes.dart
Route<dynamic> loginRoute() {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => LoginCubit(repository: getIt<AuthRepository>()),
      child: const LoginPage(),
    ),
  );
}

Route<dynamic> registerRoute() {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => RegisterCubit(
        authRepository: getIt<AuthRepository>(),
        locationsRepository: getIt<LocationsRepository>(),
      )..loadLocations(),
      child: const RegisterPage(),
    ),
  );
}
```

Call sites (both new internal links and legacy legacy-screen
navigations) use these helpers:

```dart
Navigator.push(context, loginRoute());
Navigator.pushAndRemoveUntil(context, registerRoute(), (r) => false);
```

### Consumption

Inside the pages:

```dart
// LoginPage — snippet
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (prev, curr) => curr is LoginSucceeded || curr is LoginFailed,
      listener: (ctx, state) {
        if (state is LoginSucceeded) {
          // Legacy-bridge — see legacy_bridge.contract.md
          ctx.read<AuthProvider>().hydrateFromSession(state.session);
          Navigator.of(ctx).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (r) => false,
          );
        }
      },
      builder: (ctx, state) {
        return AppFormScaffold(
          titleKey: 'login',
          children: [
            AppTextField(...),
            AppPasswordField(...),
            if (state is LoginFailed)
              AppErrorBanner(
                message: failureReasonToMessage(ctx, state.reason,
                    op: AuthOperation.login)),
            AppPrimaryButton(
              labelKey: 'login',
              isLoading: state is LoginSubmitting,
              onPressed: () => ctx.read<LoginCubit>().submit(...),
            ),
          ],
        );
      },
    );
  }
}
```

Pages MUST:
- Import only `package:flutter/*`, `flutter_bloc`, `provider` (for
  the legacy bridge only), Domain types, and Presentation widgets.
- NOT import `Dio`, `http`, `ApiService`, `SharedPreferences`,
  `ApiEndpoints`.
- NOT contain `try/catch` around repository calls — the Cubit owns
  error handling.

---

## 4. Guarantees

| Guarantee | Verified by |
|-----------|-------------|
| Login state sequence `Initial → Submitting → Succeeded` on happy path | `test/presentation/auth/cubits/login_cubit_test.dart` |
| Login state sequence `Initial → Submitting → Failed(reason)` per `AuthFailureReason` | same file, table-driven |
| `submit()` is idempotent while `Submitting` | same file |
| `reset()` transitions `Failed → Initial` | same file |
| Register state sequence includes `locationsLoading` lifecycle | `test/presentation/auth/cubits/register_cubit_test.dart` |
| Post-success `Navigator.pushAndRemoveUntil` fires exactly once | `test/presentation/auth/pages/login_page_test.dart` (widget test with fake navigator) |
| The submit button is disabled while `Submitting` | same widget test |
