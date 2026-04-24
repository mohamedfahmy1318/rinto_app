import 'package:equatable/equatable.dart';

import '../../../../domain/auth/auth_failure_reason.dart';

/// Every variant carries [phone] so `resend` and the downstream
/// `resetPasswordRoute` navigation can access it without extra plumbing.
sealed class OtpState extends Equatable {
  const OtpState({required this.phone});
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class OtpInitial extends OtpState {
  const OtpInitial({required super.phone});
}

final class OtpSubmitting extends OtpState {
  const OtpSubmitting({required super.phone});
}

final class OtpSucceeded extends OtpState {
  const OtpSucceeded({required super.phone, required this.code});
  final String code;

  @override
  List<Object?> get props => [phone, code];
}

final class OtpFailed extends OtpState {
  const OtpFailed({required super.phone, required this.reason});
  final AuthFailureReason reason;

  @override
  List<Object?> get props => [phone, reason];
}

final class OtpResending extends OtpState {
  const OtpResending({required super.phone});
}

final class OtpResendSucceeded extends OtpState {
  const OtpResendSucceeded({required super.phone});
}

final class OtpResendFailed extends OtpState {
  const OtpResendFailed({required super.phone, required this.reason});
  final AuthFailureReason reason;

  @override
  List<Object?> get props => [phone, reason];
}
