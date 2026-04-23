import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Pipeline position #2 — writes request / response / error summaries
/// to the debug console.
///
/// `kDebugMode` is a compile-time constant, so the handler bodies are
/// tree-shaken out of release builds entirely: the pipeline shape stays
/// identical, but no payloads ever reach log sinks in release.
///
/// The `Authorization` header is always rendered as `Bearer ***` to
/// keep tokens out of logs and screen recordings.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({DebugPrintCallback? debugPrinter})
      : _print = debugPrinter ?? debugPrint;

  final DebugPrintCallback _print;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      _print('[API] → ${options.method} ${options.uri}');
      _print('       headers: ${_redactHeaders(options.headers)}');
      if (options.data != null) {
        _print('       body   : ${_summarize(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      _print('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
      if (response.data != null) {
        _print('       body   : ${_summarize(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _print('[API] ✗ ${err.type} ${err.requestOptions.uri} → ${err.message}');
    }
    handler.next(err);
  }

  Map<String, Object?> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = <String, Object?>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        redacted[key] = 'Bearer ***';
      } else {
        redacted[key] = value;
      }
    });
    return redacted;
  }

  String _summarize(Object? data) {
    final text = data.toString();
    const maxLength = 500;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}… (${text.length} chars)';
  }
}
