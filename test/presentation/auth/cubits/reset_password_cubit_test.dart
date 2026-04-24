import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/auth_repository.dart';
import 'package:rento_go/presentation/auth/cubits/reset_password/reset_password_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/reset_password/reset_password_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _phone = '+972501234567';
const _code = '123456';
const _newPass = 'newSecret6';

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  ResetPasswordCubit build() =>
      ResetPasswordCubit(repository: repo, phone: _phone, code: _code);

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'happy path: emits [Submitting, Succeeded(phone, code)]',
    build: build,
    setUp: () => when(() => repo.resetPassword(any(), any(), any()))
        .thenAnswer((_) async {}),
    act: (cubit) => cubit.submit(_newPass),
    expect: () => [
      isA<ResetPasswordSubmitting>()
          .having((s) => s.phone, 'phone', _phone)
          .having((s) => s.code, 'code', _code),
      isA<ResetPasswordSucceeded>()
          .having((s) => s.phone, 'phone', _phone)
          .having((s) => s.code, 'code', _code),
    ],
  );

  for (final reason in AuthFailureReason.values) {
    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'failure $reason → ResetPasswordFailed',
      build: build,
      setUp: () => when(() => repo.resetPassword(any(), any(), any()))
          .thenThrow(AuthException(reason)),
      act: (cubit) => cubit.submit(_newPass),
      expect: () => [
        isA<ResetPasswordSubmitting>(),
        isA<ResetPasswordFailed>()
            .having((s) => s.reason, 'reason', reason)
            .having((s) => s.phone, 'phone', _phone)
            .having((s) => s.code, 'code', _code),
      ],
    );
  }

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'idempotent: second submit while Submitting is ignored',
    build: build,
    setUp: () => when(() => repo.resetPassword(any(), any(), any()))
        .thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }),
    act: (cubit) async {
      // ignore: unawaited_futures
      cubit.submit(_newPass);
      await cubit.submit(_newPass);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ResetPasswordSubmitting>(),
      isA<ResetPasswordSucceeded>(),
    ],
    verify: (_) =>
        verify(() => repo.resetPassword(any(), any(), any())).called(1),
  );

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'reset() transitions Failed → Initial (phone + code preserved)',
    build: build,
    seed: () => const ResetPasswordFailed(
      phone: _phone,
      code: _code,
      reason: AuthFailureReason.invalidOtp,
    ),
    act: (cubit) => cubit.reset(),
    expect: () => [
      isA<ResetPasswordInitial>()
          .having((s) => s.phone, 'phone', _phone)
          .having((s) => s.code, 'code', _code),
    ],
  );
}
