import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/network/interceptors/language_interceptor.dart';
import 'package:rento_go/core/storage/locale_reader.dart';

class _StubLocaleReader implements LocaleReader {
  _StubLocaleReader(this._code);

  String _code;

  @override
  String get currentLanguageCode => _code;

  @override
  Future<void> refreshFromStorage() async {}

  @override
  void setLanguageCode(String code) => _code = code;
}

RequestOptions _runOnRequest(LanguageInterceptor interceptor) {
  final options = RequestOptions(path: '/fake');
  interceptor.onRequest(options, RequestInterceptorHandler());
  return options;
}

void main() {
  group('LanguageInterceptor', () {
    test('injects Accept-Language and X-App-Language for "ar"', () {
      final interceptor = LanguageInterceptor(_StubLocaleReader('ar'));

      final req = _runOnRequest(interceptor);

      expect(req.headers['Accept-Language'], 'ar');
      expect(req.headers['X-App-Language'], 'ar');
    });

    test('injects headers matching "he"', () {
      final interceptor = LanguageInterceptor(_StubLocaleReader('he'));

      final req = _runOnRequest(interceptor);

      expect(req.headers['Accept-Language'], 'he');
      expect(req.headers['X-App-Language'], 'he');
    });

    test('picks up a locale change made after construction', () {
      final reader = _StubLocaleReader('ar');
      final interceptor = LanguageInterceptor(reader);

      final before = _runOnRequest(interceptor);
      expect(before.headers['Accept-Language'], 'ar');

      reader.setLanguageCode('en');

      final after = _runOnRequest(interceptor);
      expect(after.headers['Accept-Language'], 'en');
      expect(after.headers['X-App-Language'], 'en');
    });
  });
}
