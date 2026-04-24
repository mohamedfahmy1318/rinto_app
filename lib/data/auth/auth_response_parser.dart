import 'package:dio/dio.dart';

import '../../domain/auth/auth_failure_reason.dart';
import '../../domain/auth/entities/register_outcome.dart';
import '../../domain/auth/entities/session.dart';
import '../../domain/auth/entities/user_type.dart';
import 'dtos/session_dto.dart';

/// Result of running an auth response through the parser.
sealed class AuthResponse {
  const AuthResponse();
}

class AuthResponseSuccess extends AuthResponse {
  const AuthResponseSuccess({required this.session, this.outcome});
  final Session session;

  /// Non-null only for register responses.
  final RegisterOutcome? outcome;
}

class AuthResponseFailure extends AuthResponse {
  const AuthResponseFailure(this.reason);
  final AuthFailureReason reason;
}

/// Classifies backend responses into domain types. This is the single
/// source of truth for the mapping previously split between
/// `AuthProvider._translateLoginError` and `._translateRegisterError`.
abstract final class AuthResponseParser {
  AuthResponseParser._();

  /// Login responses look like:
  ///   { success: true,  data: { token: ..., user: { ... } } }
  ///   { success: false, message: "invalid credentials" }
  ///
  /// The [ApiResponse] wrapper is not used here — [AuthRemoteDataSource]
  /// returns the raw response map, and if Dio's default `validateStatus`
  /// produced a 4xx/5xx it has already thrown a [DioException] that
  /// [fromDioException] handles.
  static AuthResponse parseLogin(Map<String, Object?> response) {
    if (response['success'] == false) {
      final message = (response['message'] ?? '').toString();
      return AuthResponseFailure(_loginReasonFromMessage(message));
    }
    final data = response['data'];
    if (data is! Map<String, Object?>) {
      return const AuthResponseFailure(AuthFailureReason.unknownLogin);
    }
    if ((data['token'] ?? '').toString().isEmpty) {
      return const AuthResponseFailure(AuthFailureReason.unknownLogin);
    }
    final session = SessionDto.fromJson(data).toDomain();
    return AuthResponseSuccess(session: session);
  }

  /// Register responses can land in four shapes:
  ///   - failure with message     → [AuthResponseFailure]
  ///   - success + token          → [RegisterAuthenticated]
  ///   - success + requires_approval (no token)     → [RegisterPendingApproval]
  ///   - success + requires_verification (no token) → [RegisterNeedsVerification]
  static AuthResponse parseRegister(Map<String, Object?> response) {
    if (response['success'] == false) {
      final message = (response['message'] ?? '').toString();
      return AuthResponseFailure(_registerReasonFromMessage(message));
    }
    final data = response['data'];
    if (data is! Map<String, Object?>) {
      return const AuthResponseFailure(AuthFailureReason.unknownRegister);
    }

    final message = (response['message'] ?? '').toString();
    final hasToken = (data['token'] ?? '').toString().isNotEmpty;

    if (hasToken) {
      final session = SessionDto.fromJson(data).toDomain();
      return AuthResponseSuccess(
        session: session,
        outcome: RegisterAuthenticated(session),
      );
    }

    // No token issued; distinguish approval vs verification vs the
    // generic "success but we'll contact you later" bucket.
    if (data['requires_approval'] == true) {
      return AuthResponseSuccess(
        session: _emptySession(),
        outcome: RegisterPendingApproval(message),
      );
    }
    if (data['requires_verification'] == true) {
      return AuthResponseSuccess(
        session: _emptySession(),
        outcome: RegisterNeedsVerification(message),
      );
    }
    // Fallback — treat as pending approval to match the legacy UX
    // where a no-token success ended up showing the "under review"
    // message.
    return AuthResponseSuccess(
      session: _emptySession(),
      outcome: RegisterPendingApproval(message),
    );
  }

  /// Maps a raw [DioException] into an [AuthFailureReason]. Network
  /// errors become [AuthFailureReason.network]; everything else
  /// falls back to the operation-appropriate unknown bucket.
  static AuthFailureReason fromDioException(
    DioException e, {
    required AuthOperation op,
  }) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return AuthFailureReason.network;
      case DioExceptionType.badResponse:
        // Try to classify by body message if the server put one there.
        final data = e.response?.data;
        if (data is Map<String, Object?>) {
          final message = (data['message'] ?? '').toString();
          return op == AuthOperation.login
              ? _loginReasonFromMessage(message)
              : _registerReasonFromMessage(message);
        }
        return op == AuthOperation.login
            ? AuthFailureReason.unknownLogin
            : AuthFailureReason.unknownRegister;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return op == AuthOperation.login
            ? AuthFailureReason.unknownLogin
            : AuthFailureReason.unknownRegister;
    }
  }

  // ─────────── private — message pattern matching ───────────

  // Mirrors AuthProvider._translateLoginError.
  static AuthFailureReason _loginReasonFromMessage(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('pending') || msg.contains('approval')) {
      return AuthFailureReason.accountPendingApproval;
    }
    if (msg.contains('blocked')) {
      return AuthFailureReason.accountBlocked;
    }
    if (msg.contains('invalid') || msg.contains('credentials')) {
      return AuthFailureReason.invalidCredentials;
    }
    if (msg.contains('required')) {
      return AuthFailureReason.missingRequiredFields;
    }
    return AuthFailureReason.unknownLogin;
  }

  // Mirrors AuthProvider._translateRegisterError.
  static AuthFailureReason _registerReasonFromMessage(String message) {
    final msg = message.toLowerCase();
    if ((msg.contains('email') && msg.contains('exists')) ||
        msg.contains('email already')) {
      return AuthFailureReason.emailAlreadyExists;
    }
    if ((msg.contains('phone') && msg.contains('exists')) ||
        msg.contains('phone already')) {
      return AuthFailureReason.phoneAlreadyExists;
    }
    if (msg.contains('invalid email')) {
      return AuthFailureReason.invalidEmail;
    }
    if (msg.contains('invalid phone')) {
      return AuthFailureReason.invalidPhone;
    }
    if (msg.contains('password') && msg.contains('least')) {
      return AuthFailureReason.weakPassword;
    }
    if (msg.contains('required')) {
      return AuthFailureReason.missingRequiredFields;
    }
    if (msg.contains('validation')) {
      return AuthFailureReason.validationFailed;
    }
    return AuthFailureReason.unknownRegister;
  }

  static Session _emptySession() => const Session(
    token: '',
    userId: 0,
    name: '',
    email: '',
    phone: '',
    userType: UserType.renter,
    rawUserJson: <String, Object?>{},
    requiresApproval: true,
  );
}
