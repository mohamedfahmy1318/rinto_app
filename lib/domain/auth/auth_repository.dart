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
}

/// Typed error thrown by [AuthRepository] implementations. Presentation
/// pattern-matches on [reason] to render a localized message.
class AuthException implements Exception {
  const AuthException(this.reason);
  final AuthFailureReason reason;

  @override
  String toString() => 'AuthException($reason)';
}
