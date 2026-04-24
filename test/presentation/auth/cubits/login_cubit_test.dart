import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/auth_repository.dart';
import 'package:rento_go/domain/auth/entities/auth_credentials.dart';
import 'package:rento_go/domain/auth/entities/session.dart';
import 'package:rento_go/domain/auth/entities/user_type.dart';
import 'package:rento_go/presentation/auth/cubits/login/login_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/login/login_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _credentials = AuthCredentials(
  login: '+972501234567',
  password: 'secret',
);

const _session = Session(
  token: 'tok',
  userId: 1,
  name: 'A',
  email: 'a@example.test',
  phone: '+972501234567',
  userType: UserType.renter,
  rawUserJson: <String, Object?>{},
);

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
    registerFallbackValue(_credentials);
  });

  blocTest<LoginCubit, LoginState>(
    'happy path: emits [Submitting, Succeeded]',
    build: () => LoginCubit(repository: repo),
    setUp: () =>
        when(() => repo.login(any())).thenAnswer((_) async => _session),
    act: (cubit) => cubit.submit(_credentials),
    expect: () => [isA<LoginSubmitting>(), isA<LoginSucceeded>()],
  );

  // Table-driven: every AuthFailureReason from the repository maps
  // to a LoginFailed carrying the same reason.
  for (final reason in AuthFailureReason.values) {
    blocTest<LoginCubit, LoginState>(
      'failure $reason → [Submitting, Failed($reason)]',
      build: () => LoginCubit(repository: repo),
      setUp: () => when(() => repo.login(any()))
          .thenThrow(AuthException(reason)),
      act: (cubit) => cubit.submit(_credentials),
      expect: () => [
        const LoginSubmitting(),
        LoginFailed(reason),
      ],
    );
  }

  blocTest<LoginCubit, LoginState>(
    'idempotent: second submit while Submitting is ignored',
    build: () => LoginCubit(repository: repo),
    setUp: () => when(() => repo.login(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return _session;
    }),
    act: (cubit) async {
      // Fire twice quickly; the second call must be a no-op.
      // ignore: unawaited_futures
      cubit.submit(_credentials);
      await cubit.submit(_credentials);
    },
    wait: const Duration(milliseconds: 100),
    // Expect exactly one Submitting → one Succeeded (not two of each).
    expect: () => [isA<LoginSubmitting>(), isA<LoginSucceeded>()],
    verify: (_) =>
        verify(() => repo.login(any())).called(1),
  );

  blocTest<LoginCubit, LoginState>(
    'reset() transitions Failed → Initial',
    build: () => LoginCubit(repository: repo),
    seed: () => const LoginFailed(AuthFailureReason.invalidCredentials),
    act: (cubit) => cubit.reset(),
    expect: () => [isA<LoginInitial>()],
  );
}
