import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/auth/auth_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthRepository repository})
    : _repository = repository,
      super(const ForgotPasswordInitial());

  final AuthRepository _repository;

  Future<void> submit(String phone) async {
    if (state is ForgotPasswordSubmitting) return;
    emit(const ForgotPasswordSubmitting());
    try {
      await _repository.forgotPassword(phone);
      emit(ForgotPasswordSucceeded(phone));
    } on AuthException catch (e) {
      emit(ForgotPasswordFailed(e.reason));
    }
  }

  void reset() => emit(const ForgotPasswordInitial());
}
