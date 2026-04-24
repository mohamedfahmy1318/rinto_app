import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/data/auth/auth_response_parser.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/entities/register_outcome.dart';

void main() {
  group('parseLogin', () {
    test('success produces AuthResponseSuccess with Session', () {
      final result = AuthResponseParser.parseLogin(<String, Object?>{
        'success': true,
        'data': <String, Object?>{
          'token': 't',
          'user': <String, Object?>{'id': 1, 'user_type': 'renter'},
        },
      });

      expect(result, isA<AuthResponseSuccess>());
      expect((result as AuthResponseSuccess).session.token, 't');
    });

    test('missing token on success is an unknown-login failure', () {
      final result = AuthResponseParser.parseLogin(<String, Object?>{
        'success': true,
        'data': <String, Object?>{
          'user': <String, Object?>{'id': 1},
        },
      });

      expect(result, isA<AuthResponseFailure>());
      expect(
        (result as AuthResponseFailure).reason,
        AuthFailureReason.unknownLogin,
      );
    });

    // Exhaustive mapping — mirrors AuthProvider._translateLoginError.
    for (final entry in <String, AuthFailureReason>{
      'invalid credentials': AuthFailureReason.invalidCredentials,
      'Invalid email or password': AuthFailureReason.invalidCredentials,
      'account pending approval': AuthFailureReason.accountPendingApproval,
      'Your account needs approval': AuthFailureReason.accountPendingApproval,
      'your account is blocked': AuthFailureReason.accountBlocked,
      'Required fields are missing': AuthFailureReason.missingRequiredFields,
      'something else entirely': AuthFailureReason.unknownLogin,
    }.entries) {
      test('login failure message "${entry.key}" → ${entry.value}', () {
        final result = AuthResponseParser.parseLogin(<String, Object?>{
          'success': false,
          'message': entry.key,
        });

        expect(result, isA<AuthResponseFailure>());
        expect((result as AuthResponseFailure).reason, entry.value);
      });
    }
  });

  group('parseRegister', () {
    test('success with token → RegisterAuthenticated + Session', () {
      final result = AuthResponseParser.parseRegister(<String, Object?>{
        'success': true,
        'data': <String, Object?>{
          'token': 't',
          'user': <String, Object?>{'id': 1, 'user_type': 'renter'},
        },
      });

      expect(result, isA<AuthResponseSuccess>());
      expect(
        (result as AuthResponseSuccess).outcome,
        isA<RegisterAuthenticated>(),
      );
    });

    test('success without token but requires_approval → PendingApproval', () {
      final result = AuthResponseParser.parseRegister(<String, Object?>{
        'success': true,
        'message': 'pending',
        'data': <String, Object?>{'requires_approval': true},
      });

      expect(
        (result as AuthResponseSuccess).outcome,
        isA<RegisterPendingApproval>(),
      );
    });

    test('success without token but requires_verification → NeedsVerification',
        () {
      final result = AuthResponseParser.parseRegister(<String, Object?>{
        'success': true,
        'message': 'verify',
        'data': <String, Object?>{'requires_verification': true},
      });

      expect(
        (result as AuthResponseSuccess).outcome,
        isA<RegisterNeedsVerification>(),
      );
    });

    // Register failure mapping — mirrors AuthProvider._translateRegisterError.
    for (final entry in <String, AuthFailureReason>{
      'email already exists': AuthFailureReason.emailAlreadyExists,
      'phone already exists': AuthFailureReason.phoneAlreadyExists,
      'Invalid email format': AuthFailureReason.invalidEmail,
      'Invalid phone number': AuthFailureReason.invalidPhone,
      'password must be at least 6 chars': AuthFailureReason.weakPassword,
      'missing required field': AuthFailureReason.missingRequiredFields,
      'validation failed': AuthFailureReason.validationFailed,
      'weird server error': AuthFailureReason.unknownRegister,
    }.entries) {
      test('register failure message "${entry.key}" → ${entry.value}', () {
        final result = AuthResponseParser.parseRegister(<String, Object?>{
          'success': false,
          'message': entry.key,
        });

        expect((result as AuthResponseFailure).reason, entry.value);
      });
    }
  });

  group('parseForgotPassword', () {
    test('success envelope produces AuthResponseSuccess', () {
      final result = AuthResponseParser.parseForgotPassword(<String, Object?>{
        'success': true,
        'message': 'otp sent',
      });

      expect(result, isA<AuthResponseSuccess>());
    });

    test('failure with "required" message → missingRequiredFields', () {
      final result = AuthResponseParser.parseForgotPassword(<String, Object?>{
        'success': false,
        'message': 'Phone is required',
      });

      expect(
        (result as AuthResponseFailure).reason,
        AuthFailureReason.missingRequiredFields,
      );
    });

    test('failure with "invalid phone" message → invalidPhone', () {
      final result = AuthResponseParser.parseForgotPassword(<String, Object?>{
        'success': false,
        'message': 'Invalid phone format',
      });

      expect(
        (result as AuthResponseFailure).reason,
        AuthFailureReason.invalidPhone,
      );
    });
  });

  group('parseResetPassword', () {
    test('success envelope produces AuthResponseSuccess', () {
      final result = AuthResponseParser.parseResetPassword(<String, Object?>{
        'success': true,
      });

      expect(result, isA<AuthResponseSuccess>());
    });

    // Table-driven: every OTP-specific failure fragment maps to the
    // right AuthFailureReason — the FR-007 character-exact guard.
    for (final entry in <String, AuthFailureReason>{
      'invalid otp': AuthFailureReason.invalidOtp,
      'wrong code': AuthFailureReason.invalidOtp,
      'incorrect code provided': AuthFailureReason.invalidOtp,
      'expired otp': AuthFailureReason.expiredOtp,
      'otp expired': AuthFailureReason.expiredOtp,
      'code expired': AuthFailureReason.expiredOtp,
      'password must be at least 6 chars': AuthFailureReason.weakPassword,
      'required field missing': AuthFailureReason.missingRequiredFields,
      'something unrelated': AuthFailureReason.unknownLogin,
    }.entries) {
      test('reset-password failure "${entry.key}" → ${entry.value}', () {
        final result = AuthResponseParser.parseResetPassword(<String, Object?>{
          'success': false,
          'message': entry.key,
        });

        expect((result as AuthResponseFailure).reason, entry.value);
      });
    }
  });

  group('fromDioException', () {
    RequestOptions opts() => RequestOptions(path: '/x');

    test('connection timeouts map to network', () {
      for (final type in <DioExceptionType>[
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        final reason = AuthResponseParser.fromDioException(
          DioException(requestOptions: opts(), type: type),
          op: AuthOperation.login,
        );
        expect(reason, AuthFailureReason.network, reason: 'type=$type');
      }
    });

    test('badResponse with a classifiable body is classified', () {
      final reason = AuthResponseParser.fromDioException(
        DioException(
          requestOptions: opts(),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: opts(),
            statusCode: 400,
            data: <String, Object?>{'message': 'invalid credentials'},
          ),
        ),
        op: AuthOperation.login,
      );
      expect(reason, AuthFailureReason.invalidCredentials);
    });

    test('unknown DioException falls back to the op-specific unknown reason',
        () {
      final reasonLogin = AuthResponseParser.fromDioException(
        DioException(requestOptions: opts(), type: DioExceptionType.unknown),
        op: AuthOperation.login,
      );
      expect(reasonLogin, AuthFailureReason.unknownLogin);

      final reasonRegister = AuthResponseParser.fromDioException(
        DioException(requestOptions: opts(), type: DioExceptionType.unknown),
        op: AuthOperation.register,
      );
      expect(reasonRegister, AuthFailureReason.unknownRegister);
    });
  });
}
