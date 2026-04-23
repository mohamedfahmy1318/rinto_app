import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../storage/locale_reader.dart';
import '../storage/token_reader.dart';

/// App-wide service locator. Initialized once at startup by
/// [setupLocator]; safe to resolve against only after that call
/// completes.
final GetIt getIt = GetIt.instance;

/// Registers every singleton the network core needs.
///
/// Idempotent: a second call is a no-op (checks the last registered
/// type). MUST be awaited in `main.dart` before `runApp`.
///
/// Registration order is intentional — readers must be populated from
/// storage before the Dio factory resolves them. See
/// [contracts/service_locator.contract.md] for the full rationale.
Future<void> setupLocator() async {
  if (getIt.isRegistered<Dio>()) return;

  getIt.registerSingleton<TokenReader>(SharedPreferencesTokenReader());
  getIt.registerSingleton<LocaleReader>(SharedPreferencesLocaleReader());

  await getIt<TokenReader>().refreshFromStorage();
  await getIt<LocaleReader>().refreshFromStorage();

  getIt.registerLazySingleton<Dio>(
    () => ApiClient.create(
      tokenReader: getIt<TokenReader>(),
      localeReader: getIt<LocaleReader>(),
    ),
  );
}

/// Test-only: tears down every registration so the next
/// [setupLocator] call starts from a clean slate.
Future<void> resetLocator() => getIt.reset();
