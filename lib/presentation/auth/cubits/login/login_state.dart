import 'package:equatable/equatable.dart';

import '../../../../domain/auth/auth_failure_reason.dart';
import '../../../../domain/auth/entities/session.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => const [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginSucceeded extends LoginState {
  const LoginSucceeded(this.session);
  final Session session;

  @override
  List<Object?> get props => [session];
}

final class LoginFailed extends LoginState {
  const LoginFailed(this.reason);
  final AuthFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
