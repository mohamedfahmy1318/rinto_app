import 'package:dio/dio.dart';

import '../../storage/locale_reader.dart';

/// Pipeline position #1 — injects the active UI locale into every
/// outbound request.
///
/// Sends both `Accept-Language` (IETF standard) and `X-App-Language`
/// (legacy backend convention) so the rento-go backend can read either.
/// The reader is consulted on every request so a runtime language
/// switch takes effect on the next call without rebuilding the client.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._localeReader);

  final LocaleReader _localeReader;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final code = _localeReader.currentLanguageCode;
    options.headers['Accept-Language'] = code;
    options.headers['X-App-Language'] = code;
    handler.next(options);
  }
}
