import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/network/api_client.dart';
import 'package:rento_go/core/network/network_config.dart';
import 'package:rento_go/core/storage/locale_reader.dart';
import 'package:rento_go/core/storage/token_reader.dart';

class _FakeTokenReader implements TokenReader {
  @override
  String? get currentToken => null;

  @override
  Future<void> refreshFromStorage() async {}

  @override
  void setToken(String? token) {}

  @override
  void clear() {}
}

class _FakeLocaleReader implements LocaleReader {
  @override
  String get currentLanguageCode => 'ar';

  @override
  Future<void> refreshFromStorage() async {}

  @override
  void setLanguageCode(String code) {}
}

void main() {
  group('ApiClient.create', () {
    late Dio dio;

    setUp(() {
      dio = ApiClient.create(
        tokenReader: _FakeTokenReader(),
        localeReader: _FakeLocaleReader(),
      );
    });

    test('applies NetworkConfig.baseUrl', () {
      expect(dio.options.baseUrl, NetworkConfig.baseUrl);
    });

    test('applies the three timeouts from NetworkConfig', () {
      expect(dio.options.connectTimeout, NetworkConfig.connectTimeout);
      expect(dio.options.receiveTimeout, NetworkConfig.receiveTimeout);
      expect(dio.options.sendTimeout, NetworkConfig.sendTimeout);
    });

    test('applies default JSON content/accept headers', () {
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('uses ResponseType.json', () {
      expect(dio.options.responseType, ResponseType.json);
    });
  });
}
