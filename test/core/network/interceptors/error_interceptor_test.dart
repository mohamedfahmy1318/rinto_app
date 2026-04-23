import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/error/failure.dart';
import 'package:rento_go/core/network/interceptors/error_interceptor.dart';

/// Adapter that simulates a failing request by translating itself into
/// a pre-built [DioException] thrown from [fetch].
class _FailingAdapter implements HttpClientAdapter {
  _FailingAdapter(this._buildException);

  final DioException Function(RequestOptions options) _buildException;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw _buildException(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_FailingAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ErrorInterceptor());
  return dio;
}

void main() {
  group('ErrorInterceptor', () {
    test('wraps DioException.error with an UnexpectedFailure', () async {
      final dio = _dioWith(
        _FailingAdapter(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            message: 'something went wrong',
          ),
        ),
      );

      try {
        await dio.get<dynamic>('https://example.test/fake');
        fail('expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<Failure>());
        expect(e.error, isA<UnexpectedFailure>());
        expect((e.error as Failure).message, 'something went wrong');
      }
    });

    test('preserves type and requestOptions', () async {
      final dio = _dioWith(
        _FailingAdapter(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            message: 'boom',
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 500,
              data: utf8.encode('{"error":"server"}'),
            ),
          ),
        ),
      );

      try {
        await dio.get<dynamic>('https://example.test/fake');
        fail('expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.type, DioExceptionType.badResponse);
        expect(e.response?.statusCode, 500);
        expect(e.requestOptions.path, 'https://example.test/fake');
      }
    });

    test('leaves an already-mapped Failure alone', () async {
      const preExisting = NetworkFailure('preexisting');
      final dio = _dioWith(
        _FailingAdapter(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: preExisting,
          ),
        ),
      );

      try {
        await dio.get<dynamic>('https://example.test/fake');
        fail('expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, same(preExisting));
      }
    });

    test('uses a default message when DioException.message is null', () async {
      final dio = _dioWith(
        _FailingAdapter(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
          ),
        ),
      );

      try {
        await dio.get<dynamic>('https://example.test/fake');
        fail('expected DioException to be thrown');
      } on DioException catch (e) {
        expect((e.error as Failure).message, 'Unexpected error');
      }
    });
  });
}
