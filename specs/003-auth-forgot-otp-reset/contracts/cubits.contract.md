# Contract: `ForgotPasswordCubit` + `OtpCubit` + `ResetPasswordCubit`

**Files**:
- `lib/presentation/auth/cubits/forgot_password/{forgot_password_cubit,forgot_password_state}.dart`
- `lib/presentation/auth/cubits/otp/{otp_cubit,otp_state}.dart`
- `lib/presentation/auth/cubits/reset_password/{reset_password_cubit,reset_password_state}.dart`

**Consumed by**: `ForgotPasswordPage`, `OtpPage`, `ResetPasswordPage` via
`BlocProvider` + `BlocBuilder` / `BlocListener`.
**Status**: stable. Each Cubit follows the `LoginCubit` shape
established by feature 002.

---

## 1. `ForgotPasswordCubit`

Simplest of the three. Single `submit(phone)` action.

### State machine

```text
     ┌───────────┐  submit(phone)   ┌──────────────┐
     │ Initial   │─────────────────▶│  Submitting  │
     └───────────┘                  └──────┬───────┘
           ▲                               │
           │ reset()                       │
     ┌─────┴─────┐                  ┌──────▼───────┐
     │  Failed   │◀─────────────────│  Submitting  │
     └───────────┘     error        └──────┬───────┘
                                           │ success
                                           ▼
                                   ┌────────────────┐
                                   │ Succeeded      │
                                   │ (phone)        │
                                   └────────────────┘
```

### Invariants
- Idempotent `submit`: second call while `Submitting` is a no-op.
- No side effects beyond the `AuthRepository` call.
- `Succeeded` carries the phone — the page's `BlocListener`
  forwards it to `otpRoute(phone: state.phone)`.

### Page-level contract
```dart
BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
  listenWhen: (_, curr) => curr is ForgotPasswordSucceeded,
  listener: (ctx, state) {
    if (state is ForgotPasswordSucceeded) {
      Navigator.pushReplacement(ctx, otpRoute(phone: state.phone));
    }
  },
  child: ...,
)
```

---

## 2. `OtpCubit`

More complex — owns two actions (`submit`, `resend`) and six state
variants (3 submit + 3 resend).

### State machine

```text
  OtpInitial(phone)
       │
       │ submit(code)                          │ resend()
       ▼                                       ▼
  OtpSubmitting(phone)                    OtpResending(phone)
       │                                       │
       ├─── success ──────▶ OtpSucceeded(      ├─── success ──▶ OtpResendSucceeded(phone)
       │                      phone, code)     │                       │
       │                                       │                       │ (auto-drops)
       └─── AuthException ─▶ OtpFailed(        └─── AuthException ──▶ OtpResendFailed(phone, reason)
                              phone, reason)                           │       │
                                                                       │       │ (auto-drops)
                                                                       ▼       ▼
                                                              OtpInitial(phone)
```

### Invariants
- `phone` is present on every variant (sub-class constructor
  requires it). Tests rely on `state.phone` always being readable.
- `submit()` is idempotent while in `OtpSubmitting` OR
  `OtpResending` (a resend in-flight blocks a submit to avoid race
  conditions).
- `resend()` is idempotent under the same two-state guard.
- **`OtpResendSucceeded` auto-drops to `OtpInitial`** — the page's
  `BlocListener` fires a SnackBar on `OtpResendSucceeded` and the
  state moves on. This prevents the Cubit from getting stuck in a
  "success confirmation" state that blocks the next submit.
- `OtpResendFailed` follows the same auto-drop pattern so users can
  retry.

### Constructor signature
```dart
OtpCubit({
  required AuthRepository repository,
  required String phone,          // from the previous screen's route arg
})
```

### Page-level contract
```dart
BlocConsumer<OtpCubit, OtpState>(
  listenWhen: (_, curr) =>
      curr is OtpSucceeded ||
      curr is OtpResendSucceeded ||
      curr is OtpResendFailed,
  listener: (ctx, state) {
    if (state is OtpSucceeded) {
      Navigator.pushReplacement(
        ctx, resetPasswordRoute(phone: state.phone, code: state.code),
      );
    } else if (state is OtpResendSucceeded) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(ctx.tr('code_resent'))),
      );
    } else if (state is OtpResendFailed) {
      final msg = failureReasonToMessage(ctx, state.reason,
          op: AuthOperation.login);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  },
  builder: (ctx, state) { ... },
)
```

---

## 3. `ResetPasswordCubit`

Standard `LoginCubit`-shape. Constructed with `phone` + `code` from
route args; `submit(newPassword)` does the work.

### State machine

```text
  ResetPasswordInitial(phone, code)
       │
       │ submit(newPassword)
       ▼
  ResetPasswordSubmitting(phone, code)
       │
       ├─── success ─────▶ ResetPasswordSucceeded(phone, code)
       │                       │
       │                       │ page: SnackBar("password_reset_success")
       │                       │       + Navigator.popUntil(first route)
       │                       ▼
       │                   (back to LoginPage)
       │
       └─── AuthException ─▶ ResetPasswordFailed(phone, code, reason)
                               │
                               │ reset()
                               ▼
                           ResetPasswordInitial(phone, code)
```

### Invariants
- `phone` + `code` are captured at construction time and preserved
  on every state variant. The Cubit never mutates them.
- Standard idempotent `submit` guard.
- `ResetPasswordSucceeded` carries `phone` + `code` forward for
  completeness, but the page's listener ignores them and navigates
  away — they're recorded in state for test convenience.

### Constructor signature
```dart
ResetPasswordCubit({
  required AuthRepository repository,
  required String phone,
  required String code,
})
```

### Page-level contract
```dart
BlocListener<ResetPasswordCubit, ResetPasswordState>(
  listenWhen: (_, curr) => curr is ResetPasswordSucceeded,
  listener: (ctx, state) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(ctx.tr('password_reset_success'))),
    );
    Navigator.of(ctx).popUntil((r) => r.isFirst);
  },
  child: ...,
)
```

---

## 4. Shared invariants (all three Cubits)

- **Framework imports**: each Cubit file imports only
  `package:flutter_bloc/flutter_bloc.dart`, `package:equatable/equatable.dart`,
  and Domain types. Never `flutter/material`, never `dio`, never
  `provider`, never `flutter/services`.
- **No storage access**: no `SharedPreferences`, no
  `TokenReader` calls. Password recovery doesn't authenticate.
- **No navigation**: the Cubit emits a state; the page's
  `BlocListener` navigates.
- **No `legacy AuthProvider` touches**: unlike `LoginCubit` /
  `RegisterCubit`, these three never call
  `AuthProvider.hydrateFromSession` — no session is established.
- **Typed errors only**: every failure path produces an
  `AuthException(reason)` at the Domain boundary, never a raw
  `Exception` or `DioException`.

---

## 5. Guarantees

| Guarantee | Verified by |
|-----------|-------------|
| Each Cubit's state sequence matches the state machine diagrams above | Per-Cubit `blocTest` files under `test/presentation/auth/cubits/` |
| `submit()` on each Cubit is idempotent while already `Submitting` | Same tests (double-submit test case per Cubit) |
| Every `AuthFailureReason` variant the Cubit can emit produces the correct state transition | Table-driven tests per Cubit |
| `OtpResendSucceeded` / `OtpResendFailed` auto-drop to `OtpInitial` so subsequent submits aren't blocked | `OtpCubit` test file specifically verifies the auto-drop sequence |
| No widget tests exercise any network or storage (all behavior mockable via the repository) | Widget tests use `MockCubit` from `bloc_test` |
