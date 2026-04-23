// Quickstart walk-through verification (tasks.md T034).
//
// Builds the disposable data source described in
// `specs/001-core-network-di/quickstart.md` and confirms the full
// resolution path compiles and the `Dio` returned by `getIt` is wired
// with every configured interceptor in the documented order. Uses an
// in-memory SharedPreferences fake so no real network is touched.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/constants/api_endpoints.dart';
import 'package:rento_go/core/di/service_locator.dart';
import 'package:rento_go/core/network/interceptors/auth_interceptor.dart';
import 'package:rento_go/core/network/interceptors/error_interceptor.dart';
import 'package:rento_go/core/network/interceptors/language_interceptor.dart';
import 'package:rento_go/core/network/interceptors/logging_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ScratchRegionsRemoteDataSource {
  _ScratchRegionsRemoteDataSource(this._dio);
  final Dio _dio;

  /// Present to prove the data source signature compiles; not invoked
  /// during this test (we don't hit the network).
  Future<Response<dynamic>> fetchRegions() =>
      _dio.get<dynamic>(ApiEndpoints.regions);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await resetLocator();
  });

  test(
    'Quickstart walk-through: resolve Dio from DI, build a scratch data '
    'source, inspect the pipeline',
    () async {
      await setupLocator();

      // 1. Resolve the shared client.
      final dio = getIt<Dio>();

      // 2. Build a data source exactly as quickstart.md describes.
      final scratch = _ScratchRegionsRemoteDataSource(dio);
      expect(scratch, isNotNull);

      // 3. Confirm the app-level interceptor pipeline order matches
      //    research § R-003 and contracts/api_client.contract.md § 3.
      //
      //    Dio prepends its own ImplyContentTypeInterceptor to the
      //    list as a default helper; the feature's four interceptors
      //    land after it in the documented #0..#3 order. We assert on
      //    the app slice, not absolute indices.
      final appInterceptors = dio.interceptors
          .whereType<Interceptor>()
          .where((i) =>
              i is AuthInterceptor ||
              i is LanguageInterceptor ||
              i is LoggingInterceptor ||
              i is ErrorInterceptor)
          .toList();

      expect(appInterceptors, hasLength(4));
      expect(appInterceptors[0], isA<AuthInterceptor>());
      expect(appInterceptors[1], isA<LanguageInterceptor>());
      expect(appInterceptors[2], isA<LoggingInterceptor>());
      expect(appInterceptors[3], isA<ErrorInterceptor>());

      // 4. The endpoint reference compiles — no raw string at the call
      //    site. If ApiEndpoints.regions disappeared, this line would
      //    fail to compile, not fail at runtime.
      expect(ApiEndpoints.regions, isNotEmpty);
    },
  );
}
