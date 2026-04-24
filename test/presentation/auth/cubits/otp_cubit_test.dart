import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/auth_repository.dart';
import 'package:rento_go/presentation/auth/cubits/otp/otp_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/otp/otp_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _phone = '+972501234567';
const _code = '123456';

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  OtpCubit build() => OtpCubit(repository: repo, phone: _phone);

  blocTest<OtpCubit, OtpState>(
    'happy path: emits [Submitting, Succeeded(phone, code)]',
    build: build,
    setUp: () =>
        when(() => repo.verifyOtp(any(), any())).thenAnswer((_) async {}),
    act: (cubit) => cubit.submit(_code),
    expect: () => [
      isA<OtpSubmitting>().having((s) => s.phone, 'phone', _phone),
      isA<OtpSucceeded>()
          .having((s) => s.phone, 'phone', _phone)
          .having((s) => s.code, 'code', _code),
    ],
  );

  for (final reason in AuthFailureReason.values) {
    blocTest<OtpCubit, OtpState>(
      'submit failure $reason → OtpFailed',
      build: build,
      setUp: () => when(() => repo.verifyOtp(any(), any()))
          .thenThrow(AuthException(reason)),
      act: (cubit) => cubit.submit(_code),
      expect: () => [
        isA<OtpSubmitting>(),
        isA<OtpFailed>().having((s) => s.reason, 'reason', reason),
      ],
    );
  }

  blocTest<OtpCubit, OtpState>(
    'resend happy path: emits [Resending, ResendSucceeded, Initial]',
    build: build,
    setUp: () =>
        when(() => repo.resendOtp(any())).thenAnswer((_) async {}),
    act: (cubit) => cubit.resend(),
    expect: () => [
      isA<OtpResending>(),
      isA<OtpResendSucceeded>(),
      isA<OtpInitial>().having((s) => s.phone, 'phone', _phone),
    ],
  );

  blocTest<OtpCubit, OtpState>(
    'resend failure: emits [Resending, ResendFailed, Initial] (auto-drops)',
    build: build,
    setUp: () => when(() => repo.resendOtp(any()))
        .thenThrow(const AuthException(AuthFailureReason.network)),
    act: (cubit) => cubit.resend(),
    expect: () => [
      isA<OtpResending>(),
      isA<OtpResendFailed>()
          .having((s) => s.reason, 'reason', AuthFailureReason.network),
      isA<OtpInitial>(),
    ],
  );

  blocTest<OtpCubit, OtpState>(
    'idempotent submit while already Submitting',
    build: build,
    setUp: () =>
        when(() => repo.verifyOtp(any(), any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }),
    act: (cubit) async {
      // ignore: unawaited_futures
      cubit.submit(_code);
      await cubit.submit(_code);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<OtpSubmitting>(), isA<OtpSucceeded>()],
    verify: (_) => verify(() => repo.verifyOtp(any(), any())).called(1),
  );

  blocTest<OtpCubit, OtpState>(
    'submit is blocked while Resending is in-flight',
    build: build,
    setUp: () => when(() => repo.resendOtp(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }),
    act: (cubit) async {
      // ignore: unawaited_futures
      cubit.resend();
      await cubit.submit(_code); // guarded — should be no-op
    },
    wait: const Duration(milliseconds: 120),
    verify: (_) => verifyNever(() => repo.verifyOtp(any(), any())),
  );
}
