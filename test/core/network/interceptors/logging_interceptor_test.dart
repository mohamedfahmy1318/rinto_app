import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/network/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor (debug mode)', () {
    // These tests rely on `flutter test` running in debug mode, where
    // `kDebugMode` is true. The release-silence equivalent is verified
    // manually per spec SC-005 and tasks.md T033.
    if (!kDebugMode) return;

    late List<String> captured;
    late LoggingInterceptor interceptor;

    setUp(() {
      captured = <String>[];
      interceptor = LoggingInterceptor(
        debugPrinter: (message, {wrapWidth}) {
          if (message != null) captured.add(message);
        },
      );
    });

    test('writes method, URL, and headers for outbound requests', () {
      final options = RequestOptions(
        path: 'auth/login',
        method: 'POST',
        baseUrl: 'https://example.test/api',
        headers: <String, dynamic>{'Accept-Language': 'ar'},
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(
        captured.any((line) => line.contains('POST') && line.contains('auth/login')),
        isTrue,
        reason: 'should log method + URL',
      );
      expect(
        captured.any((line) => line.contains('Accept-Language')),
        isTrue,
        reason: 'should log non-sensitive headers',
      );
    });

    test('redacts Authorization header to "Bearer ***"', () {
      final options = RequestOptions(
        path: 'me',
        baseUrl: 'https://example.test/api',
        headers: <String, dynamic>{'Authorization': 'Bearer super-secret-token'},
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      final joined = captured.join('\n');
      expect(joined.contains('super-secret-token'), isFalse,
          reason: 'raw token MUST NOT appear in logs');
      expect(joined.contains('Bearer ***'), isTrue,
          reason: 'Authorization should be redacted');
    });

    test('writes status code on response', () {
      final options = RequestOptions(
        path: 'regions',
        baseUrl: 'https://example.test/api',
      );
      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: {'ok': true},
      );

      interceptor.onResponse(response, ResponseInterceptorHandler());

      expect(
        captured.any((line) => line.contains('200') && line.contains('regions')),
        isTrue,
      );
    });

    test('writes error type on DioException', () async {
      final options = RequestOptions(
        path: 'regions',
        baseUrl: 'https://example.test/api',
      );
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
        message: 'timeout',
      );

      // handler.next(err) propagates the DioException asynchronously;
      // the Zone swallows it — we only care about what was logged
      // synchronously inside onError itself.
      await runZonedGuarded(() async {
        interceptor.onError(error, ErrorInterceptorHandler());
        await Future<void>.delayed(Duration.zero);
      }, (_, __) {});

      expect(
        captured.any((line) => line.contains('connectionTimeout')),
        isTrue,
      );
    });
  });
}
