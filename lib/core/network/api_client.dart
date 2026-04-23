import 'package:dio/dio.dart';

import '../storage/locale_reader.dart';
import '../storage/token_reader.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/language_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_config.dart';

/// Builds the single shared [Dio] instance the app uses for every HTTP
/// call under the new Clean-Architecture data layer.
///
/// Called exclusively from `setupLocator()` in
/// `lib/core/di/service_locator.dart`. Data sources MUST NOT call
/// this directly — they resolve the shared [Dio] via `getIt<Dio>()`.
abstract final class ApiClient {
  ApiClient._();

  static Dio create({
    required TokenReader tokenReader,
    required LocaleReader localeReader,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: NetworkConfig.baseUrl,
        connectTimeout: NetworkConfig.connectTimeout,
        receiveTimeout: NetworkConfig.receiveTimeout,
        sendTimeout: NetworkConfig.sendTimeout,
        headers: Map<String, String>.from(NetworkConfig.defaultHeaders),
        responseType: ResponseType.json,
      ),
    );

    // Interceptor pipeline (see feature 001-core-network-di research
    // § R-003 — changing this order is a contract-breaking change):
    //   #0  AuthInterceptor
    //   #1  LanguageInterceptor
    //   #2  LoggingInterceptor
    //   #3  ErrorInterceptor
    dio.interceptors.add(AuthInterceptor(tokenReader));
    dio.interceptors.add(LanguageInterceptor(localeReader));
    dio.interceptors.add(LoggingInterceptor());
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}
