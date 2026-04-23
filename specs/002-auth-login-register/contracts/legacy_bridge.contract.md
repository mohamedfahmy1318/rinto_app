# Contract: Legacy `AuthProvider` bridge

**File**: `lib/providers/auth_provider.dart` (edited — two new methods added)
**Consumed by**: `LoginPage`, `RegisterPage` (in their `BlocListener`).
**Status**: **temporary** — this bridge exists only for the duration
of the migration and is deleted when the last non-auth consumer of
`AuthProvider` migrates off Provider.

---

## 1. Why this bridge exists

After feature 002 ships, the codebase has **two** sources of
authentication state that must agree:

| Source | Used by |
|--------|---------|
| `LoginCubit` / `RegisterCubit` (new) | `LoginPage`, `RegisterPage` |
| `AuthProvider` via Provider (legacy) | `home_screen`, `profile_screen`, `my_listings_screen`, `packages_screen`, `listing_details_screen`, `splash_screen`, `chat_service`, `subscription_warning_banner`, … ~15 call sites |

Migrating all legacy consumers in this PR explodes scope. The bridge
is the pragmatic solution: the new pages push successful auth state
into the legacy provider so every legacy consumer keeps working
unchanged.

Symmetry with feature 001: that feature added guarded one-liners in
`AuthProvider.login` / `logout` that pushed state INTO the new
`TokenReader`. This feature adds the reverse path — the new Cubit
pushes state INTO the legacy `AuthProvider`.

---

## 2. Public surface added

```dart
class AuthProvider extends ChangeNotifier {
  // ... existing fields ...

  /// Call-site: new AuthCubit success path (via BlocListener in the
  /// migrated auth pages).
  ///
  /// Hydrates the legacy provider from a Domain [Session] without
  /// making a network call. Mirrors the state-update half of
  /// [_saveAuth]. Also subscribes to the Android FCM topics (the
  /// existing behavior).
  ///
  /// Safe to call from any place that already has a Session in hand.
  Future<void> hydrateFromSession(Session session);

  /// Call-site: a future `LogoutCubit` or a local-only logout path.
  /// Clears the legacy provider state WITHOUT making a network call.
  /// Mirrors the state-clear half of [logout].
  Future<void> clearSession();
}
```

No other changes to `AuthProvider` in this feature. Existing
`register()`, `login()`, `logout()`, `refreshUser()`,
`forgotPassword()`, `verifyOtp()`, `resetPassword()`, `_saveAuth()`,
`_translateLoginError()`, `_translateRegisterError()` remain
unchanged and continue to serve legacy screens.

---

## 3. Invocation contract

```dart
// Inside LoginPage (Presentation)
BlocListener<LoginCubit, LoginState>(
  listenWhen: (prev, curr) => curr is LoginSucceeded,
  listener: (ctx, state) async {
    if (state is! LoginSucceeded) return;
    await ctx.read<AuthProvider>().hydrateFromSession(state.session);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (r) => false,
    );
  },
  child: ...,
)
```

Rules:
- The `BlocListener` is the ONLY place in new Presentation code that
  imports `package:provider/provider.dart` (for `context.read`).
- `hydrateFromSession` is awaited before navigation fires so the
  destination screen sees the updated provider state on its first
  build.
- `clearSession` is not invoked in this feature (no logout path
  migrated yet) — the method is shipped but unused until a later
  feature removes the legacy `logout` entry point.

---

## 4. Imports the Pages MUST have, and MUST NOT have

**MUST have** (the full import set for a migrated auth page):
- `package:flutter/material.dart` (widgets)
- `package:flutter_bloc/flutter_bloc.dart` (Cubit consumption)
- `package:provider/provider.dart` (**only** for `context.read<AuthProvider>()` in the bridge listener)
- Relative: Domain types, Presentation widgets, Cubit + State

**MUST NOT have**:
- `package:dio/dio.dart`
- `package:http/http.dart`
- `package:shared_preferences/shared_preferences.dart`
- `../../services/api_service.dart`
- `../../providers/app_provider.dart` (language lives in `LocaleReader` now)
- Any `lib/data/**` or `lib/core/network/**` path (Data-layer types are repository's business)

---

## 5. Deletion plan (for the future feature that removes the bridge)

1. Migrate the remaining `AuthProvider` consumers (home, profile, …)
   to read from a new `SessionCubit` or equivalent.
2. Delete the `BlocListener` bridge from `LoginPage` and `RegisterPage`.
3. Delete `AuthProvider.hydrateFromSession` and `AuthProvider.clearSession`.
4. Remove `AuthProvider` from `MultiProvider` in `main.dart`.
5. Delete `lib/providers/auth_provider.dart` entirely.

This is a linear, trackable deletion path — the bridge exists so the
migration can proceed feature-by-feature without any big-bang change.

---

## 6. Guarantees

| Guarantee | Verified by |
|-----------|-------------|
| `hydrateFromSession` produces the same in-memory state as `_saveAuth` does today | Side-by-side manual check during implementation; mirrored field-by-field against the legacy method |
| `hydrateFromSession` persists the same SharedPreferences keys (`token`, `user`) | Inspection in the integration test (widget test driving the full happy path) |
| `LoginPage` / `RegisterPage` contain exactly ONE `context.read<AuthProvider>()` call each (the bridge listener) | Grep in code review; reasserted by the spec's FR-012 check |
| Removing the bridge in the future requires touching only the three files listed in § 5 | Ensured by the import discipline in § 4 |
