# Phase 1 Data Model: Auth Recovery Flows Migration

All new Dart types introduced by this feature, plus the extensions
to existing feature-002 types. Organised by layer.

---

## 1. Domain extensions

### 1.1 `AuthFailureReason` (enum — extended)

**File**: `lib/domain/auth/auth_failure_reason.dart` *(edited)*

Two new variants appended to the existing 13:

```dart
enum AuthFailureReason {
  // ... existing 13 variants ...
  invalidOtp,            // NEW — server rejected the code (wrong)
  expiredOtp,            // NEW — OTP expired (typically 5 minutes)
}
```

**Mapping** (server message → variant) — applied in
`AuthResponseParser._loginReasonFromMessage` and friends:

| Message fragment | Variant |
|------------------|---------|
| `invalid otp`, `wrong code`, `incorrect code` | `invalidOtp` |
| `expired otp`, `otp expired`, `code expired` | `expiredOtp` |

No change to `AuthOperation` enum.

### 1.2 `AuthRepository` (interface — extended)

**File**: `lib/domain/auth/auth_repository.dart` *(edited)*

Four new method signatures added to the existing interface:

```dart
abstract interface class AuthRepository {
  // ... existing login() + register() ...

  /// Initiates a password-recovery OTP for the given phone.
  /// Throws [AuthException] on failure (unregistered phone, network, ...).
  Future<void> forgotPassword(String phone);

  /// Client-side no-op passthrough. Always succeeds if the shape
  /// check passes. Server-side validation happens at
  /// [resetPassword] time. See research § R-001.
  Future<void> verifyOtp(String phone, String code);

  /// Re-requests the OTP for an ongoing recovery flow. Hard-coded
  /// to `type: 'password_reset'` — see research § R-002.
  Future<void> resendOtp(String phone);

  /// Atomically validates the OTP and updates the password.
  /// Throws [AuthException(invalidOtp)] / [AuthException(expiredOtp)]
  /// / etc. on failure.
  Future<void> resetPassword(String phone, String code, String newPassword);
}
```

`AuthException` is unchanged — same typed carrier.

No new Domain entities (phone + code are plain `String`s; a future
PR could introduce `PhoneNumber` / `OtpCode` value objects if
validation logic grows).

---

## 2. Data layer

### 2.1 `AuthRemoteDataSource` (extended)

**File**: `lib/data/auth/auth_remote_datasource.dart` *(edited)*

Four new methods — all thin `Dio.post` wrappers:

```dart
class AuthRemoteDataSource {
  // ... existing login() + register() ...

  Future<Map<String, Object?>> forgotPassword(String phone) async {
    final response = await _dio.post<Map<String, Object?>>(
      ApiEndpoints.authForgotPassword,
      data: <String, Object?>{'phone': phone},
    );
    return response.data ?? const <String, Object?>{};
  }

  Future<Map<String, Object?>> resendOtp(String phone) async {
    final response = await _dio.post<Map<String, Object?>>(
      ApiEndpoints.authResendOtp,
      data: <String, Object?>{'phone': phone, 'type': 'password_reset'},
    );
    return response.data ?? const <String, Object?>{};
  }

  Future<Map<String, Object?>> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      ApiEndpoints.authResetPassword,
      data: <String, Object?>{
        'phone': phone,
        'otp': code,
        'password': newPassword,
      },
    );
    return response.data ?? const <String, Object?>{};
  }
}
```

No data-source method for `verifyOtp` — that's the no-op in the
repository impl.

### 2.2 `AuthResponseParser` (extended)

**File**: `lib/data/auth/auth_response_parser.dart` *(edited)*

Two new pure-function parsers + extended message table:

```dart
abstract final class AuthResponseParser {
  // ... existing parseLogin() + parseRegister() + fromDioException() ...

  /// Parses a forgot-password response — minimal shape check.
  /// Success = `{success: true}`. Failure = typed reason.
  static AuthResponse parseForgotPassword(Map<String, Object?> response) {
    if (response['success'] == false) {
      final message = (response['message'] ?? '').toString();
      return AuthResponseFailure(_recoveryReasonFromMessage(message));
    }
    return AuthResponseSuccess(session: _emptySession());
  }

  /// Parses a reset-password response — server validated OTP + password.
  static AuthResponse parseResetPassword(Map<String, Object?> response) {
    if (response['success'] == false) {
      final message = (response['message'] ?? '').toString();
      return AuthResponseFailure(_recoveryReasonFromMessage(message));
    }
    return AuthResponseSuccess(session: _emptySession());
  }

  // Private: recognises OTP-specific errors + falls through to the
  // existing register-style mapper.
  static AuthFailureReason _recoveryReasonFromMessage(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid otp') ||
        msg.contains('wrong code') ||
        msg.contains('incorrect code')) {
      return AuthFailureReason.invalidOtp;
    }
    if (msg.contains('expired otp') ||
        msg.contains('otp expired') ||
        msg.contains('code expired')) {
      return AuthFailureReason.expiredOtp;
    }
    if (msg.contains('required')) {
      return AuthFailureReason.missingRequiredFields;
    }
    if (msg.contains('password') && msg.contains('least')) {
      return AuthFailureReason.weakPassword;
    }
    return AuthFailureReason.unknownLogin; // catch-all
  }
}
```

### 2.3 `AuthRepositoryImpl` (extended)

**File**: `lib/data/auth/auth_repository_impl.dart` *(edited)*

Four new impl methods. Pattern mirrors existing `login()`/`register()`:

```dart
@override
Future<void> forgotPassword(String phone) async {
  try {
    final raw = await _dataSource.forgotPassword(phone);
    final parsed = AuthResponseParser.parseForgotPassword(raw);
    if (parsed is AuthResponseFailure) throw AuthException(parsed.reason);
  } on DioException catch (e) {
    throw AuthException(
      AuthResponseParser.fromDioException(e, op: AuthOperation.login),
    );
  }
}

@override
Future<void> verifyOtp(String phone, String code) async {
  // Client-side no-op (research § R-001). Shape check only.
  if (code.length != 6) {
    throw const AuthException(AuthFailureReason.invalidOtp);
  }
}

@override
Future<void> resendOtp(String phone) async {
  try {
    final raw = await _dataSource.resendOtp(phone);
    final parsed = AuthResponseParser.parseForgotPassword(raw);
    if (parsed is AuthResponseFailure) throw AuthException(parsed.reason);
  } on DioException catch (e) {
    throw AuthException(
      AuthResponseParser.fromDioException(e, op: AuthOperation.login),
    );
  }
}

@override
Future<void> resetPassword(
  String phone, String code, String newPassword,
) async {
  try {
    final raw = await _dataSource.resetPassword(
      phone: phone, code: code, newPassword: newPassword,
    );
    final parsed = AuthResponseParser.parseResetPassword(raw);
    if (parsed is AuthResponseFailure) throw AuthException(parsed.reason);
  } on DioException catch (e) {
    throw AuthException(
      AuthResponseParser.fromDioException(e, op: AuthOperation.login),
    );
  }
}
```

### 2.4 `ApiEndpoints` (extended)

**File**: `lib/core/constants/api_endpoints.dart` *(edited)*

Three new constants appended to the existing auth block:

```dart
// existing: authRegister, authLogin, authForgotPassword, authDeleteAccount
static const String authVerifyPhone  = 'auth/verify-phone';  // unused by 003 but added for future phone-verification migration
static const String authResendOtp    = 'auth/resend-otp';
static const String authResetPassword = 'auth/reset-password';
```

`authVerifyPhone` is added preemptively so a future phone-verification
feature doesn't need to re-visit the catalog.

---

## 3. Presentation layer

### 3.1 `ForgotPasswordState` + `ForgotPasswordCubit`

**Files**:
- `lib/presentation/auth/cubits/forgot_password/forgot_password_state.dart`
- `lib/presentation/auth/cubits/forgot_password/forgot_password_cubit.dart`

**State shape**:

```dart
sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override List<Object?> get props => const [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordSubmitting extends ForgotPasswordState {
  const ForgotPasswordSubmitting();
}

/// Carries the phone forward so the page's BlocListener can navigate
/// to the OTP page with the right argument.
final class ForgotPasswordSucceeded extends ForgotPasswordState {
  const ForgotPasswordSucceeded(this.phone);
  final String phone;
  @override List<Object?> get props => [phone];
}

final class ForgotPasswordFailed extends ForgotPasswordState {
  const ForgotPasswordFailed(this.reason);
  final AuthFailureReason reason;
  @override List<Object?> get props => [reason];
}
```

**Cubit shape**:

```dart
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthRepository repository})
    : _repository = repository,
      super(const ForgotPasswordInitial());

  final AuthRepository _repository;

  Future<void> submit(String phone) async {
    if (state is ForgotPasswordSubmitting) return;   // idempotent
    emit(const ForgotPasswordSubmitting());
    try {
      await _repository.forgotPassword(phone);
      emit(ForgotPasswordSucceeded(phone));
    } on AuthException catch (e) {
      emit(ForgotPasswordFailed(e.reason));
    }
  }

  void reset() => emit(const ForgotPasswordInitial());
}
```

### 3.2 `OtpState` + `OtpCubit`

**Files**:
- `lib/presentation/auth/cubits/otp/otp_state.dart`
- `lib/presentation/auth/cubits/otp/otp_cubit.dart`

**State** — every variant carries `phone` so it's always available
for the resend action and the downstream navigation:

```dart
sealed class OtpState extends Equatable {
  const OtpState({required this.phone});
  final String phone;
  @override List<Object?> get props => [phone];
}

final class OtpInitial extends OtpState {
  const OtpInitial({required super.phone});
}

final class OtpSubmitting extends OtpState {
  const OtpSubmitting({required super.phone});
}

/// The code carried forward to the reset-password page.
final class OtpSucceeded extends OtpState {
  const OtpSucceeded({required super.phone, required this.code});
  final String code;
  @override List<Object?> get props => [phone, code];
}

final class OtpFailed extends OtpState {
  const OtpFailed({required super.phone, required this.reason});
  final AuthFailureReason reason;
  @override List<Object?> get props => [phone, reason];
}

/// Side-effect-only state for the "resend" action. Emits
/// `OtpResendSucceeded` or `OtpResendFailed` then naturally drops
/// back to `OtpInitial(phone)` so the main Submit flow isn't blocked.
final class OtpResending extends OtpState {
  const OtpResending({required super.phone});
}

final class OtpResendSucceeded extends OtpState {
  const OtpResendSucceeded({required super.phone});
}

final class OtpResendFailed extends OtpState {
  const OtpResendFailed({required super.phone, required this.reason});
  final AuthFailureReason reason;
  @override List<Object?> get props => [phone, reason];
}
```

**Cubit**:

```dart
class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required AuthRepository repository,
    required String phone,
  }) : _repository = repository,
       super(OtpInitial(phone: phone));

  final AuthRepository _repository;

  Future<void> submit(String code) async {
    if (state is OtpSubmitting) return;
    final phone = state.phone;
    emit(OtpSubmitting(phone: phone));
    try {
      await _repository.verifyOtp(phone, code);
      emit(OtpSucceeded(phone: phone, code: code));
    } on AuthException catch (e) {
      emit(OtpFailed(phone: phone, reason: e.reason));
    }
  }

  Future<void> resend() async {
    if (state is OtpSubmitting || state is OtpResending) return;
    final phone = state.phone;
    emit(OtpResending(phone: phone));
    try {
      await _repository.resendOtp(phone);
      emit(OtpResendSucceeded(phone: phone));
      // Auto-drop back to Initial after the SnackBar fires.
      emit(OtpInitial(phone: phone));
    } on AuthException catch (e) {
      emit(OtpResendFailed(phone: phone, reason: e.reason));
      emit(OtpInitial(phone: phone));
    }
  }

  void reset() => emit(OtpInitial(phone: state.phone));
}
```

### 3.3 `ResetPasswordState` + `ResetPasswordCubit`

**Files**:
- `lib/presentation/auth/cubits/reset_password/reset_password_state.dart`
- `lib/presentation/auth/cubits/reset_password/reset_password_cubit.dart`

**State** — carries `phone` + `code` on every variant for context:

```dart
sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState({required this.phone, required this.code});
  final String phone;
  final String code;
  @override List<Object?> get props => [phone, code];
}

final class ResetPasswordInitial extends ResetPasswordState { ... }
final class ResetPasswordSubmitting extends ResetPasswordState { ... }
final class ResetPasswordSucceeded extends ResetPasswordState { ... }
final class ResetPasswordFailed extends ResetPasswordState {
  final AuthFailureReason reason;
}
```

**Cubit**: standard `submit(newPassword)` + `reset()`, mirroring
`LoginCubit` exactly.

### 3.4 `AppOtpCodeField` (new widget)

**File**: `lib/presentation/widgets/app_otp_code_field.dart`

Per research § R-006:

```dart
class AppOtpCodeField extends StatefulWidget {
  const AppOtpCodeField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;
}
```

Internal state: `List<TextEditingController>` + `List<FocusNode>`,
sized by `length`. Fires `onCompleted` exactly once when the last
field receives its digit. Uses
`FilteringTextInputFormatter.digitsOnly` and
`TextInputType.number`. Wraps the row in `Directionality(TextDirection.ltr)`
regardless of ambient locale (matches legacy).

### 3.5 Three new pages

**Files**:
- `lib/presentation/auth/pages/forgot_password_page.dart`
- `lib/presentation/auth/pages/otp_page.dart`
- `lib/presentation/auth/pages/reset_password_page.dart`

All three compose from `AppFormScaffold` + Cubit-driven rendering.
Each file is < 200 lines projected.

**Forgot Password page** — mirrors `LoginPage`'s shape with one
field + one submit. `BlocListener` catches `ForgotPasswordSucceeded`
and navigates to `otpRoute(phone: state.phone)`.

**OTP page** — single `AppOtpCodeField` + submit button + "resend"
link. Listens for `OtpSucceeded` → navigates to
`resetPasswordRoute(phone, code)`. Listens for `OtpResendSucceeded`/
`OtpResendFailed` → shows matching SnackBar.

**Reset Password page** — two `AppPasswordField`s (new + confirm) +
submit. Listens for `ResetPasswordSucceeded` → shows success SnackBar
and pops to first route (the login page).

### 3.6 `auth_routes.dart` (extended)

**File**: `lib/presentation/auth/auth_routes.dart` *(edited)*

Three new route helpers:

```dart
Route<dynamic> forgotPasswordRoute() {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => ForgotPasswordCubit(repository: getIt<AuthRepository>()),
      child: const ForgotPasswordPage(),
    ),
  );
}

Route<dynamic> otpRoute({required String phone}) {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => OtpCubit(
        repository: getIt<AuthRepository>(),
        phone: phone,
      ),
      child: const OtpPage(),
    ),
  );
}

Route<dynamic> resetPasswordRoute({
  required String phone,
  required String code,
}) {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => ResetPasswordCubit(
        repository: getIt<AuthRepository>(),
        phone: phone,
        code: code,
      ),
      child: const ResetPasswordPage(),
    ),
  );
}
```

### 3.7 `auth_error_messages.dart` (extended)

**File**: `lib/presentation/auth/auth_error_messages.dart` *(edited)*

Two new cases in the `switch (reason)`:

```dart
AuthFailureReason.invalidOtp  => 'auth_error_invalid_otp',
AuthFailureReason.expiredOtp  => 'auth_error_expired_otp',
```

---

## 4. Localization keys added

**File**: `lib/core/localization/app_localizations.dart` *(edited)*

~8 new keys × 3 locales. Per feature 002 research § R-005, the
Arabic values are used verbatim in all three locales for v1:

| Key | Arabic value (verbatim in all three locales) |
|-----|----------------------------------------------|
| `auth_error_invalid_otp` | رمز التحقق غير صحيح |
| `auth_error_expired_otp` | انتهت صلاحية رمز التحقق |
| `forgot_password_subtitle` | أدخل رقم هاتفك لإرسال رمز التحقق |
| `send_code` | إرسال الرمز |
| `verify_code` | التحقق من الرمز |
| `enter_otp` | أدخل رمز التحقق |
| `code_sent_to` | تم إرسال الرمز إلى |
| `didnt_receive_code` | لم يصلك الرمز؟ |
| `resend` | إعادة الإرسال |
| `code_resent` | تم إرسال الرمز مرة أخرى |
| `verify` | تحقق |
| `new_password` | كلمة المرور الجديدة |
| `password_reset_success` | تم إعادة تعيين كلمة المرور بنجاح |
| `enter_complete_code` | يرجى إدخال الرمز كاملاً |
| `passwords_not_match` | كلمتا المرور غير متطابقتين |

Some of these (e.g. `forgot_password_subtitle`, `new_password`,
`resend`) already exist from the legacy screens; only the **net-new**
keys for the migrated pages are added. The implementation phase
should check existence before writing to avoid duplicates.

---

## 5. Legacy files touched / deleted

- **EDIT**: `lib/presentation/auth/pages/login_page.dart` — one
  line: swap the legacy `ForgotPasswordScreen` navigation for
  `forgotPasswordRoute()`.
- **DELETE**: `lib/screens/auth/forgot_password_screen.dart`,
  `lib/screens/auth/otp_screen.dart`,
  `lib/screens/auth/reset_password_screen.dart`.
- **UNCHANGED**: `lib/providers/auth_provider.dart` — legacy methods
  (`forgotPassword`, `verifyPhone`, `resendOtp`, `resetPassword`)
  stay for any non-migrated callers; they're removed as part of the
  separate SessionCubit migration (feature 004).
