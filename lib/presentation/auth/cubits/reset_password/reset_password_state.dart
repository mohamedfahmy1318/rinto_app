import 'package:equatable/equatable.dart';

import '../../../../domain/auth/auth_failure_reason.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState({required this.phone, required this.code});
  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
}

final class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial({required super.phone, required super.code});
}

final class ResetPasswordSubmitting extends ResetPasswordState {
  const ResetPasswordSubmitting({required super.phone, required super.code});
}

final class ResetPasswordSucceeded extends ResetPasswordState {
  const ResetPasswordSucceeded({required super.phone, required super.code});
}

final class ResetPasswordFailed extends ResetPasswordState {
  const ResetPasswordFailed({
    required super.phone,
    required super.code,
    required this.reason,
  });
  final AuthFailureReason reason;

  @override
  List<Object?> get props => [phone, code, reason];
}
