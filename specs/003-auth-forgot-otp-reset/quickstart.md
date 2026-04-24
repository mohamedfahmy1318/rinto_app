# Quickstart: Using the migrated recovery flows

Runtime-level guide for engineers after feature 003 lands. Focuses
on the new surfaces and how to extend them.

---

## TL;DR

- **Open the forgot-password flow**: `Navigator.push(context, forgotPasswordRoute())`.
- **Inside a recovery page**: `context.read<ForgotPasswordCubit>().submit(phone)` (or the OTP / reset equivalents).
- **Reuse the 6-digit code input elsewhere**: drop in `AppOtpCodeField(onChanged: ...)`.
- **Auth errors → localized strings**: same `failureReasonToMessage(ctx, reason, op: AuthOperation.login)` as feature 002 — now covers `invalidOtp` and `expiredOtp` too.

---

## Entry points

| From | Action | Lands on |
|------|--------|----------|
| Migrated `LoginPage` → "forgot password?" link | `Navigator.push(context, forgotPasswordRoute())` | `ForgotPasswordPage` |
| `ForgotPasswordPage` (after successful OTP request) | `Navigator.pushReplacement(ctx, otpRoute(phone: state.phone))` | `OtpPage` |
| `OtpPage` (after successful code entry) | `Navigator.pushReplacement(ctx, resetPasswordRoute(phone: ..., code: ...))` | `ResetPasswordPage` |
| `ResetPasswordPage` (on success) | `Navigator.popUntil((r) => r.isFirst)` + SnackBar | Back to `LoginPage` |

No deep links to the OTP page or reset page exist — they are
reachable only via the sequential flow.

---

## Add a new verification-code screen (e.g. 2FA, phone verification during onboarding)

`AppOtpCodeField` is the shared primitive. Drop it into a new page:

```dart
import 'package:rento_go/presentation/widgets/app_otp_code_field.dart';

class MyVerificationPage extends StatefulWidget {
  const MyVerificationPage({super.key});

  @override
  State<MyVerificationPage> createState() => _MyVerificationPageState();
}

class _MyVerificationPageState extends State<MyVerificationPage> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return AppFormScaffold(
      titleKey: 'verify_code',
      children: [
        AppOtpCodeField(
          onChanged: (value) => setState(() => _code = value),
          onCompleted: (value) {
            // Auto-submit when the last digit lands, if you want.
            context.read<MyCubit>().submit(value);
          },
        ),
        // submit button, etc.
      ],
    );
  }
}
```

No focus-node plumbing. No controllers. Theme-driven styling
inherited from the app theme.

---

## Add a new auth error case

Same five-file touch as feature 002 documented:

1. Add a variant to `AuthFailureReason` (Domain).
2. Add the server-message matching line to
   `AuthResponseParser._recoveryReasonFromMessage` (or the
   login/register mapper if it applies there).
3. Add the localization key in
   `lib/core/localization/app_localizations.dart` across `ar`/`he`/`en`.
4. Add the `reason → key` row to `failureReasonToMessage`
   (Presentation).
5. Add a test case in `auth_response_parser_test.dart`.

---

## Adding a new repository method

If your feature needs a new auth-adjacent server call (e.g.
`changeEmail`, `deleteAccount`), extend `AuthRepository`:

1. Add the method signature to `lib/domain/auth/auth_repository.dart`.
2. Implement it in `lib/data/auth/auth_repository_impl.dart`,
   delegating to `_dataSource` and mapping via
   `AuthResponseParser`.
3. Add the Dio call to `lib/data/auth/auth_remote_datasource.dart`
   using an `ApiEndpoints.*` constant.
4. Add the endpoint constant to
   `lib/core/constants/api_endpoints.dart`.
5. Add a test in `test/data/auth/auth_repository_impl_test.dart`.

`AuthRepository` is registered in `setupLocator()` as a
`lazySingleton`; the extension picks up transparently — no DI
change.

---

## Testing a new recovery-flow Cubit

Template (copy from
`test/presentation/auth/cubits/forgot_password_cubit_test.dart`):

```dart
class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  blocTest<MyCubit, MyState>(
    'happy path: emits [Submitting, Succeeded]',
    build: () => MyCubit(repository: repo),
    setUp: () =>
        when(() => repo.myMethod(any())).thenAnswer((_) async {}),
    act: (cubit) => cubit.submit('input'),
    expect: () => [isA<MySubmitting>(), isA<MySucceeded>()],
  );

  for (final reason in AuthFailureReason.values) {
    blocTest<MyCubit, MyState>(
      'failure $reason → [Submitting, Failed($reason)]',
      build: () => MyCubit(repository: repo),
      setUp: () =>
          when(() => repo.myMethod(any())).thenThrow(AuthException(reason)),
      act: (cubit) => cubit.submit('input'),
      expect: () => [
        isA<MySubmitting>(),
        isA<MyFailed>().having((s) => s.reason, 'reason', reason),
      ],
    );
  }

  blocTest<MyCubit, MyState>(
    'idempotent: second submit while Submitting is ignored',
    build: () => MyCubit(repository: repo),
    setUp: () => when(() => repo.myMethod(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }),
    act: (cubit) async {
      // ignore: unawaited_futures
      cubit.submit('input');
      await cubit.submit('input');
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<MySubmitting>(), isA<MySucceeded>()],
    verify: (_) => verify(() => repo.myMethod(any())).called(1),
  );
}
```

---

## FAQ

**Q: Why doesn't `verifyOtp` actually verify against the server?**
See [research.md § R-001](research.md#r-001-verifyotpphone-code--dedicated-server-call-or-client-side-no-op).
The rento-go backend has no dedicated password-reset-OTP verify
endpoint. The legacy flow passes the code forward to `resetPassword`
which validates atomically. We preserve that behaviour; the
`verifyOtp` method is an abstraction seam for the day the backend
grows a real endpoint.

**Q: Why is there a separate `OtpResending` state?**
So the page can render a loading indicator on the "resend" button
specifically, while keeping the main submit button independently
active. Merging resend into `OtpSubmitting` would block both
actions, which matches legacy but feels worse.

**Q: Why does `OtpResendSucceeded` / `OtpResendFailed` auto-drop
back to `OtpInitial`?**
Because the user needs to stay on the OTP page and type a code
after a resend. If the state stuck at `OtpResendSucceeded`, the
next `submit()` would bail out under the idempotency guard. The
auto-drop keeps the flow moving.

**Q: Where does the OTP code live between the OTP page and the
reset page?**
Route argument, passed into the `ResetPasswordCubit` constructor.
No global state. See [research § R-004](research.md#r-004-where-does-the-otp-code-live-between-the-otp-page-and-the-reset-password-page).

**Q: How is `AppOtpCodeField` different from an inline Row of
TextFormFields?**
It isolates the 40+ lines of focus-node + controller plumbing into
one theme-aware widget. Callers provide `onChanged` and
`onCompleted`; they don't think about focus chains. See
[research § R-006](research.md#r-006-appotpcodefield--widget-api-shape).
