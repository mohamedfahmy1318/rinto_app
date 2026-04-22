# Contract: `ServiceLocator` (`get_it` boot)

**File**: `lib/core/di/service_locator.dart`
**Consumed by**: `lib/main.dart` (boot), every layer that resolves
singletons (`getIt<Dio>()`, `getIt<TokenReader>()`, `getIt<LocaleReader>()`).
**Status**: stable.

---

## 1. Public surface

```dart
// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Registers all singletons the app needs for the network core.
/// Idempotent: safe to call multiple times (second call is a no-op).
/// MUST be awaited before the first widget tree is built.
Future<void> setupLocator() async { ... }

/// Test-only: tears down every registration. Widget tests should call
/// this between cases to avoid cross-test leakage.
Future<void> resetLocator() async { ... }
```

No other names are exported from this file.

---

## 2. Registration order (fixed)

`setupLocator()` performs these steps in order. If any step throws,
`setupLocator()` rethrows — the app boot fails loudly rather than
silently proceeding with a half-initialized DI graph.

```text
1. If getIt.isRegistered<Dio>() → return (idempotent guard)
2. getIt.registerSingleton<TokenReader>(SharedPreferencesTokenReader())
3. getIt.registerSingleton<LocaleReader>(SharedPreferencesLocaleReader())
4. await getIt<TokenReader>().refreshFromStorage()
5. await getIt<LocaleReader>().refreshFromStorage()
6. getIt.registerLazySingleton<Dio>(() => ApiClient.create(
       tokenReader: getIt<TokenReader>(),
       localeReader: getIt<LocaleReader>(),
   ))
```

Rationale:
- Readers first, populated from storage, then Dio. Guarantees that the
  first request after boot sees real token/locale values, not
  defaults.
- Dio is lazy — feature factories that depend on Dio can register
  themselves immediately after `setupLocator()` without forcing
  construction.

---

## 3. Boot sequence (in `main.dart`)

The only edit `main.dart` receives in this feature:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  await setupLocator();                         // ← ADDED

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      if (Platform.isAndroid) {
        try {
          await FCMService.initialize();
        } catch (fcmError) {
          debugPrint('FCM initialization error (non-fatal): $fcmError');
        }
      }
    } catch (firebaseError) {
      debugPrint('Firebase initialization error: $firebaseError');
    }
  }

  runApp(const RentoGoApp());
}
```

Order rationale: DI boots **before** Firebase, because a failure to
populate the network readers is a correctness issue (requests would
proceed without auth/locale), while Firebase is already `try/catch`-ed
as non-fatal. Firebase does not depend on the network core, so the
reordering is safe.

---

## 4. Consumption from other layers

```dart
// Anywhere outside lib/domain/**
final dio = getIt<Dio>();                    // shared lazy singleton
final tokenReader = getIt<TokenReader>();    // populated at boot
final localeReader = getIt<LocaleReader>();  // populated at boot
```

- **Domain** layer MUST NOT import `service_locator.dart` nor
  `package:get_it/get_it.dart`. Domain receives its dependencies via
  constructor injection from the wiring layer only. Violations are
  rejected in review.
- **Presentation** (Cubits, widgets) SHOULD receive dependencies via
  constructor in production code. `getIt<T>()` inside widgets is
  permitted only at the composition root (where `BlocProvider` is
  created). This keeps Cubits testable.
- **Data** layer uses `getIt<Dio>()` in its `registerFactory` call
  during its own feature wiring, not in hot paths.

---

## 5. Interaction with legacy providers

Two one-line edits to legacy files to keep old and new in sync during
the migration window. Both are guarded so they no-op if `setupLocator()`
hasn't run (defensive; widget-test friendliness).

```dart
// lib/providers/auth_provider.dart — inside login() success branch
if (getIt.isRegistered<TokenReader>()) {
  getIt<TokenReader>().setToken(_token);
}

// lib/providers/auth_provider.dart — inside logout()
if (getIt.isRegistered<TokenReader>()) {
  getIt<TokenReader>().clear();
}

// lib/providers/app_provider.dart — inside setLocale()
if (getIt.isRegistered<LocaleReader>()) {
  getIt<LocaleReader>().setLanguageCode(locale.languageCode);
}
```

These lines are the **only** legacy-code edits this feature ships. They
are deleted when each corresponding feature is migrated into Cubit
form.

---

## 6. Guarantees

| Guarantee                                                                | Verified by                                      |
|--------------------------------------------------------------------------|--------------------------------------------------|
| `setupLocator()` is idempotent (second call is a no-op)                  | `test/core/di/service_locator_test.dart`         |
| `getIt<Dio>()` before `setupLocator()` throws with a clear `StateError` (`get_it`'s default) | same test                                        |
| After `setupLocator()`, `getIt<TokenReader>().currentToken` reflects the persisted value | same test (uses an in-memory fake `SharedPreferences`) |
| After `setupLocator()`, `getIt<LocaleReader>().currentLanguageCode` reflects the persisted value | same test                                        |
| `resetLocator()` followed by `setupLocator()` re-registers cleanly       | same test                                        |
