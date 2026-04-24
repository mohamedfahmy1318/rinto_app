import 'package:flutter/widgets.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/auth/auth_failure_reason.dart';

/// Maps a typed [AuthFailureReason] to a localized string.
///
/// See `specs/002-auth-login-register/research.md` § R-005 for the
/// reason-to-key table and the "Arabic values in all three locales"
/// provisional behavior.
String failureReasonToMessage(
  BuildContext context,
  AuthFailureReason reason, {
  required AuthOperation op,
}) {
  final key = switch (reason) {
    AuthFailureReason.invalidCredentials => 'auth_error_invalid_credentials',
    AuthFailureReason.accountPendingApproval => 'auth_error_account_pending',
    AuthFailureReason.accountBlocked => 'auth_error_account_blocked',
    AuthFailureReason.emailAlreadyExists => 'auth_error_email_exists',
    AuthFailureReason.phoneAlreadyExists => 'auth_error_phone_exists',
    AuthFailureReason.invalidEmail => 'auth_error_invalid_email',
    AuthFailureReason.invalidPhone => 'auth_error_invalid_phone',
    AuthFailureReason.weakPassword => 'auth_error_weak_password',
    AuthFailureReason.missingRequiredFields => 'auth_error_missing_fields',
    AuthFailureReason.validationFailed => 'auth_error_validation_failed',
    AuthFailureReason.network => 'auth_error_network',
    AuthFailureReason.invalidOtp => 'auth_error_invalid_otp',
    AuthFailureReason.expiredOtp => 'auth_error_expired_otp',
    AuthFailureReason.unknownLogin ||
    AuthFailureReason.unknownRegister => op == AuthOperation.login
        ? 'auth_error_unknown_login'
        : 'auth_error_unknown_register',
  };
  return context.tr(key);
}
