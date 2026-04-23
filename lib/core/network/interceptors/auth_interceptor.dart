import 'package:dio/dio.dart';

import '../../storage/token_reader.dart';

/// Pipeline position #0 — first interceptor on the outbound path.
///
/// Attaches `Authorization: Bearer <token>` iff [TokenReader.currentToken]
/// is a non-empty string. Does nothing when signed out; does nothing on
/// responses or errors.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenReader);

  final TokenReader _tokenReader;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _tokenReader.currentToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
