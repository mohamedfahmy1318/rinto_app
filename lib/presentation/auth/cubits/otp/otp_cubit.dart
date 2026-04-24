import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/auth/auth_repository.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required AuthRepository repository,
    required String phone,
  }) : _repository = repository,
       super(OtpInitial(phone: phone));

  final AuthRepository _repository;

  /// Idempotent while already submitting OR resending — either
  /// in-flight action blocks a submit.
  Future<void> submit(String code) async {
    if (state is OtpSubmitting || state is OtpResending) return;
    final phone = state.phone;
    emit(OtpSubmitting(phone: phone));
    try {
      await _repository.verifyOtp(phone, code);
      emit(OtpSucceeded(phone: phone, code: code));
    } on AuthException catch (e) {
      emit(OtpFailed(phone: phone, reason: e.reason));
    }
  }

  /// `OtpResendSucceeded` / `OtpResendFailed` auto-drop back to
  /// `OtpInitial` so subsequent submits aren't blocked by the
  /// idempotency guard.
  Future<void> resend() async {
    if (state is OtpSubmitting || state is OtpResending) return;
    final phone = state.phone;
    emit(OtpResending(phone: phone));
    try {
      await _repository.resendOtp(phone);
      emit(OtpResendSucceeded(phone: phone));
    } on AuthException catch (e) {
      emit(OtpResendFailed(phone: phone, reason: e.reason));
    }
    emit(OtpInitial(phone: phone));
  }

  void reset() => emit(OtpInitial(phone: state.phone));
}
