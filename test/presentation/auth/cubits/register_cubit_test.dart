import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/auth_repository.dart';
import 'package:rento_go/domain/auth/entities/register_details.dart';
import 'package:rento_go/domain/auth/entities/register_outcome.dart';
import 'package:rento_go/domain/auth/entities/session.dart';
import 'package:rento_go/domain/auth/entities/user_type.dart';
import 'package:rento_go/domain/locations/city.dart';
import 'package:rento_go/domain/locations/locations_repository.dart';
import 'package:rento_go/domain/locations/region.dart';
import 'package:rento_go/presentation/auth/cubits/register/register_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/register/register_state.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

class _MockLocationsRepo extends Mock implements LocationsRepository {}

const _details = RegisterDetails(
  name: 'X',
  email: 'x@example.test',
  phone: '+972501234567',
  password: 'secret6',
  userType: UserType.renter,
);

const _session = Session(
  token: 't',
  userId: 1,
  name: 'X',
  email: 'x@example.test',
  phone: '+972501234567',
  userType: UserType.renter,
  rawUserJson: <String, Object?>{},
);

final _regions = [
  const Region(id: 1, nameAr: 'r'),
];
final _cities = [
  const City(id: 10, regionId: 1, nameAr: 'c'),
];

void main() {
  late _MockAuthRepo authRepo;
  late _MockLocationsRepo locationsRepo;

  setUp(() {
    authRepo = _MockAuthRepo();
    locationsRepo = _MockLocationsRepo();
    registerFallbackValue(_details);
  });

  RegisterCubit build() => RegisterCubit(
    authRepository: authRepo,
    locationsRepository: locationsRepo,
  );

  blocTest<RegisterCubit, RegisterState>(
    'loadLocations populates regions + cities and clears loading flag',
    build: build,
    setUp: () {
      when(() => locationsRepo.fetchRegions())
          .thenAnswer((_) async => _regions);
      when(() => locationsRepo.fetchCities()).thenAnswer((_) async => _cities);
    },
    act: (cubit) => cubit.loadLocations(),
    expect: () => [
      isA<RegisterInitial>()
          .having((s) => s.regions.length, 'regions.length', 1)
          .having((s) => s.cities.length, 'cities.length', 1)
          .having((s) => s.isLocationsLoading, 'isLocationsLoading', false),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'loadLocations failure emits RegisterLocationsFailed',
    build: build,
    setUp: () => when(() => locationsRepo.fetchRegions())
        .thenThrow(const LocationsException()),
    act: (cubit) => cubit.loadLocations(),
    expect: () => [isA<RegisterLocationsFailed>()],
  );

  blocTest<RegisterCubit, RegisterState>(
    'submit success with token → [Submitting, SucceededAuthenticated]',
    build: build,
    setUp: () => when(() => authRepo.register(any()))
        .thenAnswer((_) async => const RegisterAuthenticated(_session)),
    act: (cubit) => cubit.submit(_details),
    expect: () => [
      isA<RegisterSubmitting>(),
      isA<RegisterSucceededAuthenticated>(),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'submit pending-approval → [Submitting, PendingApprovalState]',
    build: build,
    setUp: () => when(() => authRepo.register(any())).thenAnswer(
      (_) async => const RegisterPendingApproval('pending message'),
    ),
    act: (cubit) => cubit.submit(_details),
    expect: () => [
      isA<RegisterSubmitting>(),
      isA<RegisterPendingApprovalState>().having(
        (s) => s.message,
        'message',
        'pending message',
      ),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'submit needs-verification → [Submitting, NeedsVerificationState]',
    build: build,
    setUp: () => when(() => authRepo.register(any())).thenAnswer(
      (_) async => const RegisterNeedsVerification('please verify'),
    ),
    act: (cubit) => cubit.submit(_details),
    expect: () => [
      isA<RegisterSubmitting>(),
      isA<RegisterNeedsVerificationState>(),
    ],
  );

  for (final reason in AuthFailureReason.values) {
    blocTest<RegisterCubit, RegisterState>(
      'submit failure $reason → RegisterFailed($reason)',
      build: build,
      setUp: () => when(() => authRepo.register(any()))
          .thenThrow(AuthException(reason)),
      act: (cubit) => cubit.submit(_details),
      expect: () => [
        isA<RegisterSubmitting>(),
        isA<RegisterFailed>().having((s) => s.reason, 'reason', reason),
      ],
    );
  }

  blocTest<RegisterCubit, RegisterState>(
    'idempotent: second submit while Submitting is ignored',
    build: build,
    setUp: () => when(() => authRepo.register(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return const RegisterAuthenticated(_session);
    }),
    act: (cubit) async {
      // ignore: unawaited_futures
      cubit.submit(_details);
      await cubit.submit(_details);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<RegisterSubmitting>(),
      isA<RegisterSucceededAuthenticated>(),
    ],
    verify: (_) => verify(() => authRepo.register(any())).called(1),
  );
}
