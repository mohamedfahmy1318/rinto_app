import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';

/// Thin Dio wrapper around the two auth endpoints. Returns raw
/// response maps; classification into success / failure lives in
/// [AuthResponseParser].
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, Object?>> login({
    required String login,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      ApiEndpoints.authLogin,
      data: <String, Object?>{'login': login, 'password': password},
    );
    return response.data ?? const <String, Object?>{};
  }

  Future<Map<String, Object?>> register({
    required Map<String, Object?> body,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      ApiEndpoints.authRegister,
      data: body,
    );
    return response.data ?? const <String, Object?>{};
  }
}
