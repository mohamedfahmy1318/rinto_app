import 'package:equatable/equatable.dart';

import '../../../../domain/auth/auth_failure_reason.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => const [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordSubmitting extends ForgotPasswordState {
  const ForgotPasswordSubmitting();
}

final class ForgotPasswordSucceeded extends ForgotPasswordState {
  const ForgotPasswordSucceeded(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class ForgotPasswordFailed extends ForgotPasswordState {
  const ForgotPasswordFailed(this.reason);
  final AuthFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
