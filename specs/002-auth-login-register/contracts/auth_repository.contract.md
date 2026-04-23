# Contract: `AuthRepository` + `LocationsRepository`

**Files**:
- `lib/domain/auth/auth_repository.dart` (interface)
- `lib/data/auth/auth_repository_impl.dart` (impl)
- `lib/domain/locations/locations_repository.dart` (interface)
- `lib/data/locations/locations_repository_impl.dart` (impl)

**Consumed by**: `LoginCubit`, `RegisterCubit` (Presentation); the
repository implementations are owned by `lib/core/di/service_locator.dart`.
**Status**: stable.

---

## 1. Public surface

### `AuthRepository`

```dart
abstract interface class AuthRepository {
  /// Attempts to log in with the given credentials.
  ///
  /// Returns a [Session] on success. Throws [AuthException] with a
  /// typed [AuthFailureReason] on any failure (invalid credentials,
  /// pending approval, blocked account, network error, unknown).
  ///
  /// Side effect on success: the shared [TokenReader] is updated so
  /// subsequent HTTP calls carry the new Bearer token. Storage of
  /// the user object in SharedPreferences is NOT performed here —
  /// that remains the responsibility of the legacy [AuthProvider]
  /// via [AuthProvider.hydrateFromSession].
  Future<Session> login(AuthCredentials credentials);

  /// Attempts to register a new account.
  ///
  /// Returns a [RegisterOutcome] on success:
  ///   - [RegisterAuthenticated(session)] — server issued a token.
  ///   - [RegisterPendingApproval(message)] — account awaits admin review.
  ///   - [RegisterNeedsVerification(message)] — email/phone verification pending.
  ///
  /// Throws [AuthException] on failure.
  ///
  /// Side effect on [RegisterAuthenticated]: same token push as [login].
  Future<RegisterOutcome> register(RegisterDetails details);
}

final class AuthException implements Exception {
  const AuthException(this.reason);
  final AuthFailureReason reason;
}
```

### `LocationsRepository`

```dart
abstract interface class LocationsRepository {
  /// Returns the full list of regions from the backend.
  /// Throws [LocationsException] on network/parse failure.
  Future<List<Region>> fetchRegions();

  /// Returns the full list of cities (across all regions). The caller
  /// filters client-side on `regionId` to match the legacy form's UX.
  /// Throws [LocationsException] on network/parse failure.
  Future<List<City>> fetchCities();
}

final class LocationsException implements Exception {
  const LocationsException([this.cause]);
  final Object? cause;
}
```

---

## 2. Invariants

1. **Domain purity**: `AuthRepository` MUST NOT expose `DioException`,
   `Response`, `Dio`, `Failure`, `Either`, or any Flutter type. Only
   Domain types cross the interface boundary.
2. **Exception-based error channel**: v1 uses typed exceptions
   (`AuthException`, `LocationsException`) rather than a `Result` /
   `Either` wrapper. A later migration may introduce `Result` — at
   that point this contract migrates too. For now, callers wrap
   repository calls in `try/catch`.
3. **No presentation concerns**: `AuthRepository` MUST NOT touch the
   legacy `AuthProvider`, `context`, widget state, or any UI types.
   The sync into `AuthProvider` happens exclusively in the page's
   `BlocListener` (see `legacy_bridge.contract.md`).
4. **Token side effect is part of the contract**: on successful
   login/register-with-token, the repository MUST update the shared
   `TokenReader` before returning. This is how subsequent requests
   made by the same call site carry the new Authorization header
   without the caller doing anything.
5. **No double-submission protection at repository layer**: the
   repository happily calls the server twice if invoked twice. The
   Cubit is where submission-idempotency lives (research § R-013).

---

## 3. Guarantees

| Guarantee | Verified by |
|-----------|-------------|
| Every `AuthFailureReason` variant that the legacy helpers recognise is produced for the corresponding server response | `test/data/auth/auth_response_parser_test.dart` (table-driven over every legacy case) |
| Successful login updates `TokenReader` | `test/data/auth/auth_repository_impl_test.dart` |
| `DioException` does not leak past the repository | Same test — asserts only `AuthException` is thrown |
| `Region`/`City` DTO → entity mapping preserves localized names | `test/data/locations/locations_repository_impl_test.dart` |

---

## 4. Consumption example

```dart
// In LoginCubit (Presentation):
try {
  final session = await _repository.login(credentials);
  emit(LoginSucceeded(session));
} on AuthException catch (e) {
  emit(LoginFailed(e.reason));
}
```

Note how Presentation never sees `DioException` or `Failure` — only
the typed `AuthException`. The Cubit then renders the reason through
the Presentation mapper (research § R-005).

---

## 5. DI wiring

In `lib/core/di/service_locator.dart`, after the Dio registration:

```dart
// Auth feature
getIt.registerFactory<AuthRemoteDataSource>(
  () => AuthRemoteDataSource(getIt<Dio>()),
);
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    dataSource: getIt<AuthRemoteDataSource>(),
    tokenReader: getIt<TokenReader>(),
  ),
);

// Locations feature
getIt.registerFactory<LocationsRemoteDataSource>(
  () => LocationsRemoteDataSource(getIt<Dio>()),
);
getIt.registerLazySingleton<LocationsRepository>(
  () => LocationsRepositoryImpl(
    dataSource: getIt<LocationsRemoteDataSource>(),
  ),
);
```

Data sources are `factory` (cheap, stateless). Repositories are
`lazySingleton` (one instance shared by every Cubit construction).
