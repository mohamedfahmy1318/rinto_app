# Phase 1 Data Model: Auth (Login + Register) Clean Architecture Migration

Three groups of types:
1. **Domain entities** — framework-free value objects consumed by Cubit + repository.
2. **Data DTOs** — JSON-shape mirrors of the backend responses.
3. **Presentation states** + **widget catalog** — Cubit state classes and the UI primitives introduced.

---

## 1. Domain entities

### 1.1 `AuthCredentials`

**File**: `lib/domain/auth/entities/auth_credentials.dart`

| Field | Type | Notes |
|-------|------|-------|
| `login` | `String` | phone or email (server disambiguates) |
| `password` | `String` | raw text — used only for the outbound request; never stored |

Immutable, `Equatable`. Validation: both fields non-empty
(validation belongs to the form, not the entity — Domain just holds
values).

### 1.2 `RegisterDetails`

**File**: `lib/domain/auth/entities/register_details.dart`

| Field | Type | Notes |
|-------|------|-------|
| `name` | `String` | full name |
| `companyName` | `String?` | required iff `userType` is landlord-kind (owner / office / car_lessor) |
| `email` | `String` | |
| `phone` | `String` | |
| `password` | `String` | raw text |
| `userType` | `UserType` | see § 1.3 |
| `regionId` | `int?` | optional |
| `cityId` | `int?` | optional, must belong to `regionId` when both present |
| `agreedToTerms` | `bool` | form-level sanity; server ignores |

Validation rules (enforced in the form, restated here as
documentation):
- All required fields non-empty.
- `password.length >= 6`.
- `email` must pass a basic shape check.
- `phone` must pass a basic shape check.
- `agreedToTerms` must be `true` to submit.

### 1.3 `UserType` (enum)

**File**: `lib/domain/auth/entities/user_type.dart`

```
enum UserType { renter, owner, office, carLessor }
```

Methods:
- `String get apiValue` — returns `'renter'`, `'owner'`, `'office'`,
  `'car_lessor'` (matches backend expectation).
- `String get labelKey` — `AppLocalizations` key: `user_type_renter`,
  etc.
- `bool get isLandlord` — `true` for owner / office / carLessor;
  used by the register form to decide whether to show company-name
  and region/city fields.

### 1.4 `Session`

**File**: `lib/domain/auth/entities/session.dart`

| Field | Type | Notes |
|-------|------|-------|
| `token` | `String` | Bearer token |
| `userId` | `int` | |
| `name` | `String` | |
| `email` | `String` | |
| `phone` | `String` | |
| `userType` | `UserType` | |
| `companyName` | `String?` | |
| `preferredLanguage` | `String?` | |
| `regionId` | `int?` | |
| `cityId` | `int?` | |
| `requiresApproval` | `bool` | |
| `requiresVerification` | `bool` | |
| `rawUserJson` | `Map<String, Object?>` | kept verbatim so the legacy `AuthProvider.hydrateFromSession` can round-trip it into SharedPreferences without losing fields the new entity hasn't named yet |

`Session` is immutable and `Equatable`.

### 1.5 `RegisterOutcome` (sealed class)

**File**: `lib/domain/auth/entities/register_outcome.dart`

```
sealed class RegisterOutcome {}

class RegisterAuthenticated extends RegisterOutcome {
  RegisterAuthenticated(this.session);
  final Session session;
}

class RegisterPendingApproval extends RegisterOutcome {
  RegisterPendingApproval(this.message);
  final String message;          // server-provided, may be null/empty
}

class RegisterNeedsVerification extends RegisterOutcome {
  RegisterNeedsVerification(this.message);
  final String message;
}
```

Discriminator values come from the existing server response
(`requires_approval`, `requires_verification` flags + presence of
`token`).

### 1.6 `AuthFailureReason` (enum)

**File**: `lib/domain/auth/auth_failure_reason.dart`

```
enum AuthFailureReason {
  invalidCredentials,
  accountPendingApproval,
  accountBlocked,
  emailAlreadyExists,
  phoneAlreadyExists,
  invalidEmail,
  invalidPhone,
  weakPassword,
  missingRequiredFields,
  validationFailed,
  network,
  unknownLogin,
  unknownRegister,
}
```

See research § R-005 for the `reason → AppLocalizations key` table.

### 1.7 `AuthRepository` (interface)

**File**: `lib/domain/auth/auth_repository.dart`

```dart
abstract interface class AuthRepository {
  /// Throws [AuthException] with an [AuthFailureReason] on any failure.
  Future<Session> login(AuthCredentials credentials);

  /// Throws [AuthException] on failure; returns the typed outcome on success.
  Future<RegisterOutcome> register(RegisterDetails details);
}

class AuthException implements Exception {
  const AuthException(this.reason);
  final AuthFailureReason reason;
}
```

`AuthException` is the domain-level "something went wrong" carrier.
Presentation pattern-matches the reason via
`failureReasonToMessage(ctx, reason, op:)` (research § R-005).

### 1.8 Locations

**File**: `lib/domain/locations/region.dart`

| Field | Type |
|-------|------|
| `id` | `int` |
| `nameAr` | `String` |
| `nameEn` | `String?` |
| `nameHe` | `String?` |

**File**: `lib/domain/locations/city.dart`

| Field | Type |
|-------|------|
| `id` | `int` |
| `regionId` | `int` |
| `nameAr` | `String` |
| `nameEn` | `String?` |
| `nameHe` | `String?` |

**File**: `lib/domain/locations/locations_repository.dart`

```dart
abstract interface class LocationsRepository {
  Future<List<Region>> fetchRegions();
  Future<List<City>> fetchCities();          // all cities
}
```

Filtering by region ID happens in the cubit/widget (client-side on
the flat list returned). The backend supports
`ApiEndpoints.regionCities(id)` but the legacy form loaded the full
list once and filtered locally; we preserve that.

---

## 2. Data layer

### 2.1 `SessionDto` / `UserDto`

**File**: `lib/data/auth/dtos/session_dto.dart`, `user_dto.dart`

- `UserDto.fromJson(Map<String, Object?>)` — parses the `user`
  sub-object of a login/register response.
- `SessionDto.fromJson(Map<String, Object?>)` — parses the whole
  response and owns the raw `user` map so `Session.rawUserJson`
  stays faithful.
- `toDomain() → Session` on `SessionDto`; delegates to
  `UserDto.toDomain()` where needed.

### 2.2 `AuthRemoteDataSource`

**File**: `lib/data/auth/auth_remote_datasource.dart`

| Member | Signature |
|--------|-----------|
| `login(login: String, password: String)` | `Future<Map<String, Object?>>` (raw response data) |
| `register(body: Map<String, Object?>)` | `Future<Map<String, Object?>>` |

Uses `getIt<Dio>()`. References `ApiEndpoints.authLogin` /
`ApiEndpoints.authRegister`. Throws `DioException` on network
failures (unmodified — the repository layer catches and maps).

### 2.3 `AuthResponseParser` (pure function class)

**File**: `lib/data/auth/auth_response_parser.dart`

```dart
sealed class AuthResponse {}
class AuthResponseSuccess extends AuthResponse {
  AuthResponseSuccess(this.session, {this.outcome});
  final Session session;
  final RegisterOutcome? outcome;   // null when operation = login
}
class AuthResponseFailure extends AuthResponse {
  AuthResponseFailure(this.reason);
  final AuthFailureReason reason;
}

abstract final class AuthResponseParser {
  AuthResponseParser._();

  static AuthResponse parseLogin(Map<String, Object?> response);

  static AuthResponse parseRegister(Map<String, Object?> response);

  static AuthResponse fromDioException(
    DioException e, {
    required AuthOperation op,
  });
}
```

The classification logic mirrors the legacy `_translateLoginError` /
`_translateRegisterError` case table — kept here as the single
source of truth (research § R-004).

### 2.4 `AuthRepositoryImpl`

**File**: `lib/data/auth/auth_repository_impl.dart`

Depends on `AuthRemoteDataSource` + `TokenReader`.

```dart
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenReader tokenReader,
  });

  @override
  Future<Session> login(AuthCredentials c) async {
    try {
      final raw = await _dataSource.login(
        login: c.login, password: c.password);
      final parsed = AuthResponseParser.parseLogin(raw);
      return switch (parsed) {
        AuthResponseSuccess(:final session) => _afterSuccess(session),
        AuthResponseFailure(:final reason) => throw AuthException(reason),
      };
    } on DioException catch (e) {
      throw AuthException(
        AuthResponseParser.fromDioException(e, op: AuthOperation.login),
      );
    }
  }

  @override
  Future<RegisterOutcome> register(RegisterDetails d) async { ... }

  Session _afterSuccess(Session session) {
    _tokenReader.setToken(session.token);   // keep interceptors warm
    return session;
  }
}
```

Responsibilities:
1. Call the remote data source.
2. Map the response via `AuthResponseParser`.
3. On success: push the token into `TokenReader` so subsequent
   requests carry it.
4. On failure: throw `AuthException(reason)`.

### 2.5 `LocationsRemoteDataSource`, `LocationsRepositoryImpl`

**Files**: `lib/data/locations/{locations_remote_datasource,
locations_repository_impl}.dart`

Thin wrappers over `Dio.get(ApiEndpoints.regions)` and
`Dio.get(ApiEndpoints.cities)`. DTO → domain mapping in
`dtos/{region,city}_dto.dart`.

---

## 3. Presentation layer — Cubits

### 3.1 `LoginState`

**File**: `lib/presentation/auth/cubits/login/login_state.dart`

```dart
sealed class LoginState extends Equatable {}

class LoginInitial extends LoginState {}
class LoginSubmitting extends LoginState {}
class LoginSucceeded extends LoginState {
  LoginSucceeded(this.session);
  final Session session;
}
class LoginFailed extends LoginState {
  LoginFailed(this.reason);
  final AuthFailureReason reason;
}
```

### 3.2 `LoginCubit`

**File**: `lib/presentation/auth/cubits/login/login_cubit.dart`

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository repository})
    : _repository = repository,
      super(LoginInitial());

  final AuthRepository _repository;

  Future<void> submit(AuthCredentials credentials) async {
    if (state is LoginSubmitting) return;
    emit(LoginSubmitting());
    try {
      final session = await _repository.login(credentials);
      emit(LoginSucceeded(session));
    } on AuthException catch (e) {
      emit(LoginFailed(e.reason));
    }
  }
}
```

### 3.3 `RegisterState`

**File**: `lib/presentation/auth/cubits/register/register_state.dart`

```dart
sealed class RegisterState extends Equatable {
  // All states also carry the loaded regions/cities lists (possibly
  // empty during loading). Separating "locations loaded" into a
  // nested struct keeps the state variants flat.
  List<Region> get regions;
  List<City> get cities;
  bool get isLocationsLoading;
}

class RegisterInitial extends RegisterState { ... }
class RegisterSubmitting extends RegisterState { ... }
class RegisterSucceededAuthenticated extends RegisterState {
  final Session session;
}
class RegisterPendingApprovalState extends RegisterState {
  final String message;
}
class RegisterNeedsVerificationState extends RegisterState {
  final String message;
}
class RegisterFailed extends RegisterState {
  final AuthFailureReason reason;
}
```

### 3.4 `RegisterCubit`

**File**: `lib/presentation/auth/cubits/register/register_cubit.dart`

```dart
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required AuthRepository authRepository,
    required LocationsRepository locationsRepository,
  });

  Future<void> loadLocations();       // fire-and-forget at page init
  Future<void> submit(RegisterDetails details);
}
```

The `loadLocations` action fills `regions` / `cities` on the state;
the `submit` action ignores the location lists but expects the page
to have filled `details.regionId` / `cityId` if relevant.

---

## 4. Legacy `AuthProvider` additions

**File**: `lib/providers/auth_provider.dart` (edited)

Two new public methods (only legacy-code additions in this feature
beyond route-call-site edits):

```dart
/// Pushes a Session obtained by the new AuthCubit into the legacy
/// provider so screens that still read `user` / `isLoggedIn` from
/// `context.watch<AuthProvider>()` keep working unchanged.
Future<void> hydrateFromSession(Session session) async {
  _token = session.token;
  _user = UserModel.fromJson(session.rawUserJson);
  ApiService.setToken(_token);
  if (getIt.isRegistered<TokenReader>()) {
    getIt<TokenReader>().setToken(_token);
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(StorageKeys.token, _token!);
  await prefs.setString(StorageKeys.user, jsonEncode(session.rawUserJson));

  // FCM subscribe — preserved from the existing _saveAuth path.
  if (!kIsWeb && Platform.isAndroid) {
    await _saveFcmToken();
    await FCMService.subscribeToTopic('user_type_${_user!.userType}');
    await FCMService.subscribeToTopic('all_users');
  }

  notifyListeners();
}

/// Clears the legacy provider state without hitting the network.
Future<void> clearSession() async {
  // Mirrors the non-network half of logout().
  if (_user != null && !kIsWeb && Platform.isAndroid) {
    await FCMService.unsubscribeFromTopic('user_type_${_user!.userType}');
    await FCMService.unsubscribeFromTopic('all_users');
  }

  _user = null;
  _token = null;
  ApiService.setToken(null);
  if (getIt.isRegistered<TokenReader>()) {
    getIt<TokenReader>().clear();
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(StorageKeys.token);
  await prefs.remove(StorageKeys.user);

  notifyListeners();
}
```

No other changes to `AuthProvider`.

---

## 5. Custom widgets catalog

### 5.1 App-wide (`lib/presentation/widgets/`)

| Widget | Constructor parameters | Behavior |
|--------|------------------------|----------|
| `AppTextField` | `controller`, `labelKey`, `hintKey?`, `prefixIcon?`, `keyboardType?`, `textDirection?`, `validator?` | Theme-driven `TextFormField`; no inline colors/sizes. Reads label/hint via `ctx.tr(labelKey)`. |
| `AppPasswordField` | `controller`, `labelKey`, `validator?`, `onChanged?` | Self-contained obscure toggle + visibility icon. |
| `AppPrimaryButton` | `labelKey`, `onPressed`, `isLoading` | `ElevatedButton`; when `isLoading`, shows a 20×20 spinner and disables `onPressed`. |
| `AppErrorBanner` | `message` | Red-tinted container with rounded corners + icon. Null/empty message → `SizedBox.shrink()` (convenient conditional rendering). |
| `AppFormScaffold` | `titleKey`, `children` | Scaffold + AppBar + SafeArea + SingleChildScrollView + padded Form. |

### 5.2 Auth-scoped (`lib/presentation/auth/widgets/`)

| Widget | Constructor parameters | Behavior |
|--------|------------------------|----------|
| `UserTypeSelector` | `value`, `onChanged(UserType)` | Wrap of 4 `ChoiceChip`s, each labeled via `UserType.labelKey → ctx.tr(...)`. |
| `TermsCheckbox` | `value`, `onChanged(bool)` | Checkbox + RichText with a tappable "terms" link that opens `_TermsDialog`. |
| `RegionPicker` | `regions`, `selected?`, `onChanged(int?)` | Dropdown; disabled when regions list empty (loading). |
| `CityPicker` | `cities`, `selectedRegionId?`, `selected?`, `onChanged(int?)` | Filters on `selectedRegionId`; resets when region changes and current city doesn't match. |

---

## 6. Localization keys added

**File**: `lib/core/localization/app_localizations.dart` (edited — ar / he / en blocks)

Auth errors (research § R-005): `auth_error_invalid_credentials`,
`auth_error_account_pending`, `auth_error_account_blocked`,
`auth_error_email_exists`, `auth_error_phone_exists`,
`auth_error_invalid_email`, `auth_error_invalid_phone`,
`auth_error_weak_password`, `auth_error_missing_fields`,
`auth_error_validation_failed`, `auth_error_network`,
`auth_error_unknown_login`, `auth_error_unknown_register`.

User-type labels: `user_type_renter`, `user_type_owner`,
`user_type_office`, `user_type_car_lessor`.

Per research § R-005, the `ar` values are the legacy Arabic strings
verbatim. The `he` and `en` values are the same Arabic strings in
v1 (to preserve behaviour). A follow-up PR translates them.
