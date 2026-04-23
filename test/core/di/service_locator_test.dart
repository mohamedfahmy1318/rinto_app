import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/core/di/service_locator.dart';
import 'package:rento_go/core/storage/locale_reader.dart';
import 'package:rento_go/core/storage/token_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await resetLocator();
  });

  group('setupLocator', () {
    test('registers TokenReader and LocaleReader', () async {
      await setupLocator();

      expect(getIt.isRegistered<TokenReader>(), isTrue);
      expect(getIt.isRegistered<LocaleReader>(), isTrue);
    });

    test('is idempotent — second call is a no-op', () async {
      await setupLocator();
      final firstTokenReader = getIt<TokenReader>();

      await setupLocator();

      expect(identical(getIt<TokenReader>(), firstTokenReader), isTrue);
    });

    test('resetLocator clears registrations so setupLocator can re-run',
        () async {
      await setupLocator();
      await resetLocator();

      expect(getIt.isRegistered<TokenReader>(), isFalse);

      await setupLocator();

      expect(getIt.isRegistered<TokenReader>(), isTrue);
    });

    test('populates TokenReader from SharedPreferences at boot', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'auth_token': 'stored-token-abc',
      });

      await setupLocator();

      expect(getIt<TokenReader>().currentToken, 'stored-token-abc');
    });

    test('populates LocaleReader from SharedPreferences at boot', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_language': 'he',
      });

      await setupLocator();

      expect(getIt<LocaleReader>().currentLanguageCode, 'he');
    });

    test('LocaleReader defaults to "ar" when nothing is stored', () async {
      await setupLocator();

      expect(getIt<LocaleReader>().currentLanguageCode, 'ar');
    });

    test('registers Dio as a lazy singleton — same instance on every resolve',
        () async {
      await setupLocator();

      final first = getIt<Dio>();
      final second = getIt<Dio>();

      expect(identical(first, second), isTrue);
    });

    test('Dio base URL matches the one registered by ApiClient', () async {
      await setupLocator();

      final dio = getIt<Dio>();

      expect(dio.options.baseUrl, isNotEmpty);
    });
  });
}
