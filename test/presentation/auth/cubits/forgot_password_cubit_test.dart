import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/auth_repository.dart';
import 'package:rento_go/presentation/auth/cubits/forgot_password/forgot_password_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/forgot_password/forgot_password_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _phone = '+972501234567';

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'happy path: emits [Submitting, Succeeded(phone)]',
    build: () => ForgotPasswordCubit(repository: repo),
    setUp: () =>
        when(() => repo.forgotPassword(any())).thenAnswer((_) async {}),
    act: (cubit) => cubit.submit(_phone),
    expect: () => [
      isA<ForgotPasswordSubmitting>(),
      isA<ForgotPasswordSucceeded>().having((s) => s.phone, 'phone', _phone),
    ],
  );

  for (final reason in AuthFailureReason.values) {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'failure $reason → [Submitting, Failed($reason)]',
      build: () => ForgotPasswordCubit(repository: repo),
      setUp: () => when(() => repo.forgotPassword(any()))
          .thenThrow(AuthException(reason)),
      act: (cubit) => cubit.submit(_phone),
      expect: () => [
        const ForgotPasswordSubmitting(),
        ForgotPasswordFailed(reason),
      ],
    );
  }

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'idempotent: second submit while Submitting is ignored',
    build: () => ForgotPasswordCubit(repository: repo),
    setUp: () => when(() => repo.forgotPassword(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }),
    act: (cubit) async {
      // ignore: unawaited_futures
      cubit.submit(_phone);
      await cubit.submit(_phone);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ForgotPasswordSubmitting>(),
      isA<ForgotPasswordSucceeded>(),
    ],
    verify: (_) => verify(() => repo.forgotPassword(any())).called(1),
  );

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'reset() transitions Failed → Initial',
    build: () => ForgotPasswordCubit(repository: repo),
    seed: () => const ForgotPasswordFailed(AuthFailureReason.network),
    act: (cubit) => cubit.reset(),
    expect: () => [isA<ForgotPasswordInitial>()],
  );
}
