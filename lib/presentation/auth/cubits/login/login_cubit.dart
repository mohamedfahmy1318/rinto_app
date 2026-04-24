import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/auth/auth_repository.dart';
import '../../../../domain/auth/entities/auth_credentials.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository repository})
    : _repository = repository,
      super(const LoginInitial());

  final AuthRepository _repository;

  /// Idempotent while already submitting — protects against duplicate
  /// submit events from a stuck button or programmatic re-submit.
  Future<void> submit(AuthCredentials credentials) async {
    if (state is LoginSubmitting) return;
    emit(const LoginSubmitting());
    try {
      final session = await _repository.login(credentials);
      emit(LoginSucceeded(session));
    } on AuthException catch (e) {
      emit(LoginFailed(e.reason));
    }
  }

  void reset() {
    emit(const LoginInitial());
  }
}
