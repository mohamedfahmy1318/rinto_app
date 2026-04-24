import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/auth/auth_repository.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({
    required AuthRepository repository,
    required String phone,
    required String code,
  }) : _repository = repository,
       super(ResetPasswordInitial(phone: phone, code: code));

  final AuthRepository _repository;

  Future<void> submit(String newPassword) async {
    if (state is ResetPasswordSubmitting) return;
    final phone = state.phone;
    final code = state.code;
    emit(ResetPasswordSubmitting(phone: phone, code: code));
    try {
      await _repository.resetPassword(phone, code, newPassword);
      emit(ResetPasswordSucceeded(phone: phone, code: code));
    } on AuthException catch (e) {
      emit(ResetPasswordFailed(phone: phone, code: code, reason: e.reason));
    }
  }

  void reset() =>
      emit(ResetPasswordInitial(phone: state.phone, code: state.code));
}
