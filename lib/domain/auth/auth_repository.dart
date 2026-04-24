import 'auth_failure_reason.dart';
import 'entities/auth_credentials.dart';
import 'entities/register_details.dart';
import 'entities/register_outcome.dart';
import 'entities/session.dart';

/// Domain-level contract for authentication operations.
///
/// Side effect on successful [login] / register-with-token: the
/// implementation updates the shared `TokenReader` so subsequent
/// HTTP calls carry the Bearer token. The contract does not require
/// SharedPreferences persistence — that remains the legacy
/// `AuthProvider.hydrateFromSession`'s responsibility.
abstract interface class AuthRepository {
  Future<Session> login(AuthCredentials credentials);

  Future<RegisterOutcome> register(RegisterDetails details);

  /// Initiates a password-recovery OTP for the given phone.
  /// Throws [AuthException] on failure.
  Future<void> forgotPassword(String phone);

  /// Client-side shape check. Throws [AuthException(invalidOtp)] if
  /// [code] is not exactly 6 digits. Server-side OTP validation
  /// happens at [resetPassword] time — see feature 003 research § R-001.
  Future<void> verifyOtp(String phone, String code);

  /// Re-requests the OTP for an ongoing password-reset flow.
  /// Throws [AuthException] on failure.
  Future<void> resendOtp(String phone);

  /// Atomically validates the OTP and updates the password.
  /// Throws [AuthException] with [AuthFailureReason.invalidOtp] /
  /// [AuthFailureReason.expiredOtp] / etc. on failure.
  Future<void> resetPassword(
    String phone,
    String code,
    String newPassword,
  );
}

/// Typed error thrown by [AuthRepository] implementations. Presentation
/// pattern-matches on [reason] to render a localized message.
class AuthException implements Exception {
  const AuthException(this.reason);
  final AuthFailureReason reason;

  @override
  String toString() => 'AuthException($reason)';
}
