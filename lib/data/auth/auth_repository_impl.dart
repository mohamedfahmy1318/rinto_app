import 'package:dio/dio.dart';

import '../../core/storage/token_reader.dart';
import '../../domain/auth/auth_failure_reason.dart';
import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/entities/auth_credentials.dart';
import '../../domain/auth/entities/register_details.dart';
import '../../domain/auth/entities/register_outcome.dart';
import '../../domain/auth/entities/session.dart';
import 'auth_remote_datasource.dart';
import 'auth_response_parser.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenReader tokenReader,
  }) : _dataSource = dataSource,
       _tokenReader = tokenReader;

  final AuthRemoteDataSource _dataSource;
  final TokenReader _tokenReader;

  @override
  Future<Session> login(AuthCredentials credentials) async {
    try {
      final raw = await _dataSource.login(
        login: credentials.login,
        password: credentials.password,
      );
      final parsed = AuthResponseParser.parseLogin(raw);
      return switch (parsed) {
        AuthResponseSuccess(:final session) => _afterSuccess(session),
        AuthResponseFailure(:final reason) => throw AuthException(reason),
      };
    } on DioException catch (e) {
      throw AuthException(
        AuthResponseParser.fromDioException(e, op: AuthOperation.login),
      );
    }
  }

  @override
  Future<RegisterOutcome> register(RegisterDetails details) async {
    try {
      final body = <String, Object?>{
        'name': details.name,
        'company_name': details.companyName,
        'email': details.email,
        'phone': details.phone,
        'password': details.password,
        'user_type': details.userType.apiValue,
        'region_id': details.regionId,
        'city_id': details.cityId,
      };
      final raw = await _dataSource.register(body: body);
      final parsed = AuthResponseParser.parseRegister(raw);
      return switch (parsed) {
        AuthResponseSuccess(:final outcome) => _resolveRegisterOutcome(outcome),
        AuthResponseFailure(:final reason) => throw AuthException(reason),
      };
    } on DioException catch (e) {
      throw AuthException(
        AuthResponseParser.fromDioException(e, op: AuthOperation.register),
      );
    }
  }

  @override
  Future<void> forgotPassword(String phone) async {
    try {
      final raw = await _dataSource.forgotPassword(phone);
      final parsed = AuthResponseParser.parseForgotPassword(raw);
      if (parsed is AuthResponseFailure) throw AuthException(parsed.reason);
    } on DioException catch (e) {
      throw AuthException(
        AuthResponseParser.fromDioException(e, op: AuthOperation.login),
      );
    }
  }

  @override
  Future<void> verifyOtp(String phone, String code) async {
    // Client-side shape check only — server validates at resetPassword
    // time. See specs/003-auth-forgot-otp-reset/research.md § R-001.
    if (code.length != 6) {
      throw const AuthException(AuthFailureReason.invalidOtp);
    }
  }

  @override
  Future<void> resendOtp(String phone) async {
    try {
      final raw = await _dataSource.resendOtp(phone);
      final parsed = AuthResponseParser.parseForgotPassword(raw);
      if (parsed is AuthResponseFailure) throw AuthException(parsed.reason);
    } on DioException catch (e) {
      throw AuthException(
        AuthResponseParser.fromDioException(e, op: AuthOperation.login),
      );
    }
  }

  @override
  Future<void> resetPassword(
    String phone,
    String code,
    String newPassword,
  ) async {
    try {
      final raw = await _dataSource.resetPassword(
        phone: phone,
        code: code,
        newPassword: newPassword,
      );
      final parsed = AuthResponseParser.parseResetPassword(raw);
      if (parsed is AuthResponseFailure) throw AuthException(parsed.reason);
    } on DioException catch (e) {
      throw AuthException(
        AuthResponseParser.fromDioException(e, op: AuthOperation.login),
      );
    }
  }

  Session _afterSuccess(Session session) {
    if (session.token.isNotEmpty) {
      _tokenReader.setToken(session.token);
    }
    return session;
  }

  RegisterOutcome _resolveRegisterOutcome(RegisterOutcome? outcome) {
    if (outcome == null) {
      throw const AuthException(AuthFailureReason.unknownRegister);
    }
    if (outcome is RegisterAuthenticated) {
      _afterSuccess(outcome.session);
    }
    return outcome;
  }
}
