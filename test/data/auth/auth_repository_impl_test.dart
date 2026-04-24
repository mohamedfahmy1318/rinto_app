import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/core/storage/token_reader.dart';
import 'package:rento_go/data/auth/auth_remote_datasource.dart';
import 'package:rento_go/data/auth/auth_repository_impl.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/auth_repository.dart';
import 'package:rento_go/domain/auth/entities/auth_credentials.dart';
import 'package:rento_go/domain/auth/entities/register_details.dart';
import 'package:rento_go/domain/auth/entities/register_outcome.dart';
import 'package:rento_go/domain/auth/entities/user_type.dart';

class _MockDataSource extends Mock implements AuthRemoteDataSource {}

class _RecordingTokenReader implements TokenReader {
  String? _current;
  final List<String?> writes = [];

  @override
  String? get currentToken => _current;

  @override
  Future<void> refreshFromStorage() async {}

  @override
  void setToken(String? token) {
    _current = token;
    writes.add(token);
  }

  @override
  void clear() => setToken(null);
}

void main() {
  late _MockDataSource dataSource;
  late _RecordingTokenReader tokenReader;
  late AuthRepositoryImpl repo;

  setUp(() {
    dataSource = _MockDataSource();
    tokenReader = _RecordingTokenReader();
    repo = AuthRepositoryImpl(
      dataSource: dataSource,
      tokenReader: tokenReader,
    );
  });

  const credentials = AuthCredentials(
    login: '+972501234567',
    password: 'secret',
  );

  group('login', () {
    test('pushes token to TokenReader on success', () async {
      when(() => dataSource.login(
            login: any(named: 'login'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => <String, Object?>{
            'success': true,
            'data': <String, Object?>{
              'token': 'tok-abc',
              'user': <String, Object?>{'id': 1, 'user_type': 'renter'},
            },
          });

      final session = await repo.login(credentials);

      expect(session.token, 'tok-abc');
      expect(tokenReader.writes, ['tok-abc']);
    });

    test('throws AuthException on server-side failure', () async {
      when(() => dataSource.login(
            login: any(named: 'login'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => <String, Object?>{
            'success': false,
            'message': 'invalid credentials',
          });

      await expectLater(
        repo.login(credentials),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidCredentials,
          ),
        ),
      );
    });

    test('does not leak DioException — maps to AuthException.network', () async {
      when(() => dataSource.login(
            login: any(named: 'login'),
            password: any(named: 'password'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ));

      await expectLater(
        repo.login(credentials),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.network,
          ),
        ),
      );
    });
  });

  group('register', () {
    const details = RegisterDetails(
      name: 'A User',
      email: 'a@example.test',
      phone: '+972501234567',
      password: 'secret',
      userType: UserType.renter,
    );

    test('returns RegisterAuthenticated and pushes token on token-present success',
        () async {
      when(() => dataSource.register(body: any(named: 'body'))).thenAnswer(
        (_) async => <String, Object?>{
          'success': true,
          'data': <String, Object?>{
            'token': 'new-tok',
            'user': <String, Object?>{'id': 2, 'user_type': 'renter'},
          },
        },
      );

      final outcome = await repo.register(details);

      expect(outcome, isA<RegisterAuthenticated>());
      expect(tokenReader.writes, ['new-tok']);
    });

    test('returns RegisterPendingApproval without pushing a token', () async {
      when(() => dataSource.register(body: any(named: 'body'))).thenAnswer(
        (_) async => <String, Object?>{
          'success': true,
          'message': 'pending',
          'data': <String, Object?>{'requires_approval': true},
        },
      );

      final outcome = await repo.register(details);

      expect(outcome, isA<RegisterPendingApproval>());
      expect(tokenReader.writes, isEmpty);
    });

    test('throws AuthException for server validation failures', () async {
      when(() => dataSource.register(body: any(named: 'body'))).thenAnswer(
        (_) async => <String, Object?>{
          'success': false,
          'message': 'email already exists',
        },
      );

      await expectLater(
        repo.register(details),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.emailAlreadyExists,
          ),
        ),
      );
    });
  });

  group('forgotPassword', () {
    test('returns normally on success envelope', () async {
      when(() => dataSource.forgotPassword(any())).thenAnswer(
        (_) async => <String, Object?>{'success': true},
      );

      await repo.forgotPassword('+972501234567');
      // No throw = success.
    });

    test('throws AuthException on server-side failure', () async {
      when(() => dataSource.forgotPassword(any())).thenAnswer(
        (_) async => <String, Object?>{
          'success': false,
          'message': 'Phone is required',
        },
      );

      await expectLater(
        repo.forgotPassword(''),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.missingRequiredFields,
          ),
        ),
      );
    });

    test('maps DioException to AuthException.network', () async {
      when(() => dataSource.forgotPassword(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(
        repo.forgotPassword('+972501234567'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.network,
          ),
        ),
      );
    });
  });

  group('verifyOtp', () {
    test('returns normally for a 6-digit code (no network)', () async {
      await repo.verifyOtp('+972501234567', '123456');
      verifyNever(() => dataSource.forgotPassword(any()));
      verifyNever(() => dataSource.resendOtp(any()));
    });

    test('throws AuthException(invalidOtp) for a non-6-digit code', () async {
      await expectLater(
        repo.verifyOtp('+972501234567', '12345'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidOtp,
          ),
        ),
      );
    });

    test('throws AuthException(invalidOtp) for an empty code', () async {
      await expectLater(
        repo.verifyOtp('+972501234567', ''),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidOtp,
          ),
        ),
      );
    });
  });

  group('resendOtp', () {
    test('sends {phone, type: password_reset} on success', () async {
      when(() => dataSource.resendOtp(any())).thenAnswer(
        (_) async => <String, Object?>{'success': true},
      );

      await repo.resendOtp('+972501234567');
      verify(() => dataSource.resendOtp('+972501234567')).called(1);
    });

    test('maps DioException to AuthException.network', () async {
      when(() => dataSource.resendOtp(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      await expectLater(
        repo.resendOtp('+972501234567'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.network,
          ),
        ),
      );
    });
  });

  group('resetPassword', () {
    test('returns normally on success envelope', () async {
      when(() => dataSource.resetPassword(
            phone: any(named: 'phone'),
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => <String, Object?>{'success': true});

      await repo.resetPassword('+972501234567', '123456', 'newSecret');
    });

    test('throws AuthException(invalidOtp) on server-side reject', () async {
      when(() => dataSource.resetPassword(
            phone: any(named: 'phone'),
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => <String, Object?>{
            'success': false,
            'message': 'invalid otp',
          });

      await expectLater(
        repo.resetPassword('+972501234567', '999999', 'newSecret'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidOtp,
          ),
        ),
      );
    });

    test('throws AuthException(expiredOtp) on expired code', () async {
      when(() => dataSource.resetPassword(
            phone: any(named: 'phone'),
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => <String, Object?>{
            'success': false,
            'message': 'otp expired',
          });

      await expectLater(
        repo.resetPassword('+972501234567', '111111', 'newSecret'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.expiredOtp,
          ),
        ),
      );
    });
  });
}
