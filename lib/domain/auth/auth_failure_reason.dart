/// Typed domain-level reason for an authentication failure.
///
/// Every variant corresponds to a case the legacy
/// `_translateLoginError` / `_translateRegisterError` helpers
/// recognise. Presentation maps each reason to a localized message
/// via `failureReasonToMessage` in
/// `lib/presentation/auth/auth_error_messages.dart`.
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
  invalidOtp,
  expiredOtp,
}

/// Which operation produced a failure — used by the presentation-layer
/// message mapper to disambiguate the generic `unknown*` reasons.
enum AuthOperation { login, register }
