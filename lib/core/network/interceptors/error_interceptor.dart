import 'package:dio/dio.dart';

import '../../error/failure.dart';

/// Pipeline position #3 — last outbound, first inbound.
///
/// v1 behaviour: wraps every `DioException` so its `error` field holds
/// a [Failure] value. Only the catch-all [UnexpectedFailure] is emitted
/// at this stage; concrete mapping into [NetworkFailure] / [ServerFailure]
/// is delivered by a follow-up feature without any call-site changes
/// (`e.error as Failure` remains the stable contract).
///
/// The original `DioExceptionType`, `Response`, and `RequestOptions`
/// fields are preserved — only `error` is rewritten.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final existingFailure = err.error;
    if (existingFailure is Failure) {
      handler.next(err);
      return;
    }

    final wrapped = err.copyWith(
      error: UnexpectedFailure(err.message ?? 'Unexpected error'),
    );
    handler.next(wrapped);
  }
}
