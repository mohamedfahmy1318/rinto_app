# Contract: `AuthRepository` extension for recovery flows

**File**: `lib/domain/auth/auth_repository.dart` *(edited — 4 new method signatures)*
**Implementation**: `lib/data/auth/auth_repository_impl.dart` *(edited)*
**Consumed by**: `ForgotPasswordCubit`, `OtpCubit`, `ResetPasswordCubit`.
**Status**: stable surface. Changes to any method signature are
breaking.

---

## 1. Public surface (added methods only)

```dart
abstract interface class AuthRepository {
  // ... existing login() + register() from feature 002 — unchanged ...

  /// Initiates a password-recovery OTP for the given phone.
  ///
  /// Success: the server has sent an OTP to the phone; caller advances
  /// the user to the OTP entry screen.
  ///
  /// Throws [AuthException] with one of:
  ///   - [AuthFailureReason.network] — connectivity / timeout
  ///   - [AuthFailureReason.invalidPhone] — malformed phone
  ///   - [AuthFailureReason.missingRequiredFields] — empty phone
  ///   - [AuthFailureReason.unknownLogin] — any other failure
  ///
  /// Does NOT throw for "phone not registered" in v1 — the server
  /// may return success regardless (anti-enumeration). If the
  /// server does return a specific error for unregistered phones,
  /// it maps to [AuthFailureReason.unknownLogin] via the parser.
  Future<void> forgotPassword(String phone);

  /// Client-side no-op passthrough. Always succeeds if [code] has
  /// length 6; throws [AuthException(invalidOtp)] otherwise. Does
  /// NOT hit the server. See research § R-001 for rationale.
  ///
  /// Server-side OTP validation happens at [resetPassword] time.
  /// When/if the backend ever exposes a dedicated `auth/verify-otp`
  /// endpoint, this method body is swapped without touching any
  /// caller.
  Future<void> verifyOtp(String phone, String code);

  /// Re-requests the OTP for an ongoing recovery flow.
  /// Hard-coded to `type: 'password_reset'` — this feature only
  /// migrates that branch. Phone verification (onboarding) is
  /// out of scope.
  ///
  /// Throws [AuthException] on the same variants as [forgotPassword].
  Future<void> resendOtp(String phone);

  /// Atomically validates the OTP and updates the password.
  ///
  /// Throws [AuthException] with one of:
  ///   - [AuthFailureReason.invalidOtp] — wrong code
  ///   - [AuthFailureReason.expiredOtp] — code no longer valid
  ///   - [AuthFailureReason.weakPassword] — rejected by server
  ///     (client-side validates first; this catches server overrides)
  ///   - [AuthFailureReason.network] — connectivity / timeout
  ///   - [AuthFailureReason.unknownLogin] — any other failure
  ///
  /// On success, no session is established — the user must log in
  /// via the existing [login] method with their new password.
  Future<void> resetPassword(String phone, String code, String newPassword);
}
```

No changes to `AuthException` — same typed carrier as 002.

---

## 2. Invariants

1. **Domain purity**: the new methods MUST NOT expose `DioException`,
   `Response`, `Dio`, or any Flutter type. Same rule as 002.
2. **No session side effects**: unlike `login()` / `register()`,
   none of these four methods push into `TokenReader` on success.
   Password recovery doesn't authenticate the user — they must log
   in via `login()` after reset.
3. **No persistence side effects**: no `SharedPreferences` writes,
   no legacy `AuthProvider` updates. These flows are stateless from
   the app's perspective until the user logs in post-reset.
4. **Cubit layer owns navigation**: the repository returns (or
   throws); the Cubit emits the corresponding state; the page's
   `BlocListener` does the `Navigator.push`. Never from the
   repository.
5. **`verifyOtp` is explicitly a shape check**: it does NOT
   guarantee the OTP is correct. Callers that rely on this method
   for security are broken. The real validation is at
   `resetPassword`.

---

## 3. Server contract (v1 — rento-go backend as it exists today)

| Method | HTTP | Endpoint | Request body | Success response | Failure response |
|--------|------|----------|--------------|------------------|------------------|
| `forgotPassword` | POST | `ApiEndpoints.authForgotPassword` (`auth/forgot-password`) | `{phone}` | `{success: true, message?: string}` | `{success: false, message: string}` |
| `verifyOtp` | (none — client-only) | — | — | — | — |
| `resendOtp` | POST | `ApiEndpoints.authResendOtp` (`auth/resend-otp`) | `{phone, type: 'password_reset'}` | `{success: true, message?: string}` | `{success: false, message: string}` |
| `resetPassword` | POST | `ApiEndpoints.authResetPassword` (`auth/reset-password`) | `{phone, otp, password}` | `{success: true, message?: string}` | `{success: false, message: string}` |

The response shape matches the existing `auth/login` + `auth/register`
envelope (`{success, message, data?}`). Only `resetPassword` omits
the `data` payload on success because no session is issued.

---

## 4. Failure-reason mapping

`AuthResponseParser` gains a new private helper
`_recoveryReasonFromMessage(String)` that recognises:

| Server message fragment (lowercased) | Mapped `AuthFailureReason` |
|--------------------------------------|----------------------------|
| `invalid otp`, `wrong code`, `incorrect code` | `invalidOtp` |
| `expired otp`, `otp expired`, `code expired` | `expiredOtp` |
| `required` | `missingRequiredFields` |
| `password` AND `least` | `weakPassword` |
| `invalid phone` | `invalidPhone` |
| *anything else* | `unknownLogin` |

`DioException` → reason mapping reuses the existing
`fromDioException(e, op: AuthOperation.login)` path.

---

## 5. Guarantees

| Guarantee | Verified by |
|-----------|-------------|
| Each of the 4 new methods throws `AuthException` — never `DioException` — on failure | `test/data/auth/auth_repository_impl_test.dart` (new cases) |
| `verifyOtp` with a 6-digit code returns normally without touching the network | Same test file |
| `verifyOtp` with a non-6-digit code throws `AuthException(invalidOtp)` | Same test file |
| Every legacy `_translateRegisterError`/`_translateLoginError` case continues to map identically | `auth_response_parser_test.dart` (unchanged + new cases for OTP variants) |
| The new OTP-specific variants produce the correct Arabic message | Cubit tests + widget smoke tests |

---

## 6. DI wiring

**No changes.** `AuthRepository` is already registered as a
`lazySingleton` in `setupLocator()` (feature 002 T028). The new
methods are accessible on the existing registered instance — callers
resolve `getIt<AuthRepository>()` and get the extended interface
transparently.
