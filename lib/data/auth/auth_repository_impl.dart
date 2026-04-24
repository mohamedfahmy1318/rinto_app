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
