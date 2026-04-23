import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/network/interceptors/auth_interceptor.dart';
import 'package:rento_go/core/storage/token_reader.dart';

class _StubTokenReader implements TokenReader {
  _StubTokenReader(this._token);

  String? _token;

  @override
  String? get currentToken {
    final value = _token;
    if (value == null || value.isEmpty) return null;
    return value;
  }

  @override
  Future<void> refreshFromStorage() async {}

  @override
  void setToken(String? token) => _token = token;

  @override
  void clear() => _token = null;
}

RequestOptions _runOnRequest(AuthInterceptor interceptor) {
  final options = RequestOptions(path: '/fake');
  interceptor.onRequest(options, RequestInterceptorHandler());
  return options;
}

void main() {
  group('AuthInterceptor', () {
    test('attaches Bearer header when token is non-empty', () {
      final interceptor = AuthInterceptor(_StubTokenReader('tok-123'));

      final req = _runOnRequest(interceptor);

      expect(req.headers['Authorization'], 'Bearer tok-123');
    });

    test('attaches no Authorization header when token is null', () {
      final interceptor = AuthInterceptor(_StubTokenReader(null));

      final req = _runOnRequest(interceptor);

      expect(req.headers.containsKey('Authorization'), isFalse);
    });

    test('attaches no Authorization header when token is empty string', () {
      final interceptor = AuthInterceptor(_StubTokenReader(''));

      final req = _runOnRequest(interceptor);

      expect(req.headers.containsKey('Authorization'), isFalse);
    });

    test('picks up a token change made after construction', () {
      final reader = _StubTokenReader(null);
      final interceptor = AuthInterceptor(reader);

      final before = _runOnRequest(interceptor);
      expect(before.headers.containsKey('Authorization'), isFalse);

      reader.setToken('fresh-token');

      final after = _runOnRequest(interceptor);
      expect(after.headers['Authorization'], 'Bearer fresh-token');
    });
  });
}
