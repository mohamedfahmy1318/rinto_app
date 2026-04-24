# Phase 0 Research: Auth Recovery Flows Migration

Scope: resolve every design decision the plan depends on so Phase 1
can produce concrete contracts. Seven decisions total — fewer than
002 because this feature builds heavily on what 002 established.

---

## R-001: `verifyOtp(phone, code)` — dedicated server call or client-side no-op?

**Question**: The spec adds `verifyOtp(phone, code)` to `AuthRepository`.
Does the OTP page call a dedicated server endpoint that validates the
code (and rejects if wrong), or does it pass the code forward to the
reset-password call (where the server validates it atomically with
the reset)?

**Decision**: **Client-side no-op passthrough.** `verifyOtp(phone, code)`
validates nothing against the server in v1 — it returns immediately
with a success marker, and the OTP is passed forward to the
reset-password call, which is where the server actually validates it.

**Rationale**:
- The rento-go backend has a `POST auth/verify-phone` endpoint, but
  it was designed for the **phone-verification** flow during
  onboarding (legacy `OtpScreen(type: 'phone_verification')` — dead
  code per spec FR-014). Repurposing it for password-reset OTP
  validation is semantically wrong and risks server-side behaviour
  we can't verify.
- The legacy password-reset flow never hits a verify endpoint. The
  OTP screen collects the code, then navigates straight to the reset
  screen with the code as a route argument. `POST auth/reset-password`
  validates the OTP atomically with the password update — if the OTP
  is wrong, the reset call fails with a 400 and the user sees the
  error on the reset screen, not on the OTP screen.
- Preserving this exact flow honours FR-007 (character-exact
  behaviour preservation).

**Impact on UX**: The user types a wrong OTP → submits → the OTP
page shows a loading spinner for ~0ms → navigates to the reset
screen → user types a new password → **now** the error appears ("OTP
غير صحيح" or equivalent). This is slightly worse than a dedicated
verify endpoint (error appears one screen later than ideal), but it
matches today exactly.

**Alternatives considered**:
- **Reuse `auth/verify-phone`**: Semantically wrong. Rejected.
- **Add `auth/verify-otp` as a new backend endpoint**: out of scope
  for a client-only feature; would require coordinated backend work.
  Rejected.
- **Skip `verifyOtp` method entirely, just pass OTP forward**: would
  contradict the user's explicit request to add the method. Rejected.
  Keeping the method as an abstraction seam — when the backend ever
  gains a real verify endpoint, we swap the impl body without
  touching any caller.

---

## R-002: `resendOtp(phone)` — dedicated method or reuse `forgotPassword`?

**Question**: Does the repository expose `resendOtp(phone)` as a
distinct method, or does the OTP page call `forgotPassword(phone)`
again?

**Decision**: **Dedicated `resendOtp(phone)` method**, backed by the
existing `POST auth/resend-otp` endpoint (with `type: 'password_reset'`
hardcoded for this feature's scope).

**Rationale**:
- The rento-go backend already has `auth/resend-otp` as a distinct
  endpoint (confirmed in `AuthProvider.resendOtp`). Reusing the
  existing surface is the least surprising.
- Semantically: "resend" is not the same as "start a new recovery"
  — the backend may track attempt counts or use different rate
  limits for resends. Preserving the split lets the backend do its
  thing.
- API surface stays clean: the OTP page has a single reason to call
  `resendOtp` (user tapped the resend button), and the repository
  method name matches the UI action.

**`type` parameter handling**: The legacy endpoint accepts a
`{phone, type}` body where `type` disambiguates `password_reset` vs.
`phone_verification`. Since this feature migrates only the
`password_reset` branch (FR-014), the new repository method sends
`{phone, type: 'password_reset'}` hard-coded. If a future feature
adds phone verification during onboarding, it can introduce its own
`resendPhoneVerificationOtp(phone)` method or expand the existing
one.

**Alternatives considered**:
- **Reuse `forgotPassword`**: technically the same HTTP call shape,
  but the backend distinguishes the two flows (different cooldowns
  probably). Rejected.
- **Make `type` a parameter**: over-generalises. The one caller in
  this feature sends `'password_reset'`; parameterising it now
  speculates about callers that don't exist. Rejected — YAGNI.

---

## R-003: Should the OTP step be skippable if the backend silently accepts any code?

**Question**: Given R-001's decision (no dedicated verify endpoint),
what stops a malicious caller from skipping the OTP page entirely
and going straight to reset-password with any 6-digit string?

**Decision**: **Server enforces it.** The backend validates the OTP
at reset-password time and rejects invalid codes. The client trusts
that enforcement — it doesn't try to double-check.

**Rationale**:
- This is exactly today's behaviour. The legacy flow has the same
  property: the OTP screen is a UX step, not a security check.
- Security enforcement belongs server-side. A client-side check with
  no backend counterpart would be security theatre.
- The spec's FR-011 (idempotent submit + typed state machine) still
  holds: the `OtpCubit`'s `Succeeded` state carries the code forward
  but doesn't claim the code is valid. The validation happens at the
  `ResetPasswordCubit.submit` step.

**What the `OtpCubit.submit` actually does**:
1. Validates client-side that the code is 6 digits (shape check).
2. Emits `OtpSubmitting` → immediately emits `OtpSucceeded(phone, code)`
   via the `AuthRepository.verifyOtp` passthrough.
3. The page's `BlocListener` catches `OtpSucceeded` and navigates
   to the reset-password page, passing `phone` + `code` as route args.

The `OtpCubit` shape still matches `LoginCubit`'s state machine — it
just happens that the "server call" inside `submit` is a synchronous
no-op. When we eventually add a real verify endpoint, we swap the
body of `AuthRepository.verifyOtp` and the Cubit code needs no
change.

---

## R-004: Where does the OTP code live between the OTP page and the reset-password page?

**Question**: The reset-password page needs the OTP that the user
typed on the OTP page. How does it receive it?

**Decision**: **As a route argument**, passed when constructing the
`ResetPasswordPage` via `resetPasswordRoute(phone, code)`. Mirrors
the legacy pattern exactly (legacy `ResetPasswordScreen(phone, otp)`).

**Rationale**:
- Simple, stateless, matches legacy.
- The `ResetPasswordCubit` is constructed with `phone` + `code` as
  initial state — injected by the route helper into the
  `BlocProvider`.
- No global state carries the code — if the user backgrounds the app
  during the flow, they can back out and redo the OTP step. Same as
  today.

**Alternatives considered**:
- **Store in a `SessionCubit`**: over-engineered for a one-screen
  carryover. Rejected.
- **Store in `SharedPreferences`**: security concern (OTP in plain
  prefs) + no need. Rejected.
- **Store in a singleton `RecoveryFlowState`**: introduces a new
  abstraction for one use case. Rejected — YAGNI.

---

## R-005: New `AuthFailureReason` variants for OTP errors

**Question**: Does the existing 13-variant `AuthFailureReason` enum
cover every error case the new flows can produce? If not, which
variants need adding?

**Decision**: **Add two new variants: `invalidOtp` and `expiredOtp`.**

**Rationale**:
- **`invalidOtp`**: the server rejects a wrong code. Today's legacy
  `_translateRegisterError` doesn't have a pattern for this because
  OTP errors happen in the password-reset path, not the register
  path. We need the new variant so the Presentation mapper renders
  the right localized message.
- **`expiredOtp`**: OTPs expire (typically 5 minutes). A user who
  waits too long between requesting the code and submitting gets an
  "expired" error from the server. Separate variant because the
  user-facing message is different ("العملية انتهت صلاحيتها" vs
  "رمز غير صحيح").

**Mapping (server message → variant)** — added to
`AuthResponseParser`:
| Server message fragment | New variant |
|-------------------------|-------------|
| `invalid otp`, `wrong code`, `incorrect code` | `invalidOtp` |
| `expired otp`, `otp expired`, `code expired` | `expiredOtp` |

**All other** failure cases (network, unknown, `missingRequiredFields`,
`weakPassword` on reset) map to existing variants.

**Alternatives considered**:
- **Single `otpError` variant**: collapses two user-visible cases
  into one, loses the UX distinction. Rejected.
- **Add more variants (rate-limited, blocked-after-N-attempts, etc.)**:
  speculative — not in the legacy flow. Defer until we see them in
  practice. Rejected (YAGNI).

---

## R-006: `AppOtpCodeField` — widget API shape

**Question**: What exactly does `AppOtpCodeField` expose to callers?

**Decision**:

```dart
class AppOtpCodeField extends StatefulWidget {
  const AppOtpCodeField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;
}
```

**Behaviour**:
- Renders `length` square input boxes in a row, left-to-right under
  `Directionality(TextDirection.ltr)` (OTP is always LTR regardless
  of the app's RTL locale — matches legacy behaviour).
- Auto-advances focus on typing a digit; auto-backtracks on delete.
- Fires `onChanged(fullString)` on every keystroke with the
  concatenation of the currently-typed digits.
- Fires `onCompleted(fullString)` once when the last field receives
  its digit. Useful for auto-submit.
- Owns all controllers + focus nodes internally — caller provides
  no plumbing.
- Theme-driven: square size, border radius, and text style come from
  `Theme.of(context)`. No hardcoded colors or paddings inline.

**Rationale**:
- Minimal surface. The three parameters callers actually need are
  `length`, `onChanged`, and optionally `onCompleted`.
- `autoFocus: true` matches legacy (opens the keyboard immediately
  on page open).
- Keeping the widget stateful-but-self-contained matches 002's
  `AppPasswordField` pattern (it also has internal state for the
  obscure toggle).

**Not exposed**:
- **No `controller` parameter**: callers would misuse it. The widget
  is the single source of truth.
- **No `clearOnComplete`**: the reset-flow never clears after
  completion; if a future caller needs it, add then.
- **No `keyboardType` parameter**: hard-coded to `TextInputType.number`
  with a `FilteringTextInputFormatter.digitsOnly`.

**Alternatives considered**:
- **Expose `FocusNode` list**: leaks implementation. Rejected.
- **Use an external package** (`pin_code_fields`, `flutter_otp_text_field`):
  adds a dependency for ~50 lines of code we can write ourselves.
  Constitution V (simplicity) + dependency-tree discipline reject
  this. Stay first-party.

---

## R-007: Testing scope for the three Cubits

**Question**: How much Cubit test coverage is enough?

**Decision**: Mirror 002's pattern exactly.

- **Per-Cubit unit test file** under
  `test/presentation/auth/cubits/<cubit>_test.dart`.
- **Required cases per Cubit**:
  1. Happy path: `Initial → Submitting → Succeeded`.
  2. Table-driven failure: for every `AuthFailureReason` variant the
     Cubit can emit, `Initial → Submitting → Failed(reason)`.
  3. Idempotent submit: two calls in quick succession produce one
     `Submitting` → one `Succeeded` and one network call (verified
     via `mocktail.verify()`).
  4. `reset()` transitions `Failed → Initial`.
- **Expected test counts**: `ForgotPasswordCubit` ~6 tests,
  `OtpCubit` ~6 tests (happy path + 2 new OTP-specific failure
  variants + 2 network variants + idempotent), `ResetPasswordCubit`
  ~6 tests. ~18 total.
- **Widget tests**: one per page at minimum (happy path + failure
  banner). ~5 total.

**Rationale**: same coverage floor as 002, proven to catch
regressions without exploding. The OTP Cubit specifically needs the
two new `AuthFailureReason` variants exercised to satisfy SC-002
(character-exact Arabic preservation for every legacy case).

---

## Consolidated decisions summary

| Area | Decision |
|------|----------|
| `verifyOtp(phone, code)` | Client-side no-op passthrough; server validates at `resetPassword` time |
| `resendOtp(phone)` | Dedicated method, hits `auth/resend-otp` with hard-coded `type: 'password_reset'` |
| OTP page security | Server-enforced (reset endpoint rejects wrong OTPs) — client trusts |
| OTP handoff between pages | Route argument `resetPasswordRoute(phone, code)` |
| New `AuthFailureReason` variants | Add `invalidOtp` + `expiredOtp` |
| `AppOtpCodeField` API | 4 params: length=6, onChanged, onCompleted?, autoFocus=true. Self-contained state. |
| Testing scope | Per-Cubit state-machine unit tests (≥5 each) + one widget test per page |
| Endpoints to add to catalog | `authVerifyPhone`, `authResendOtp`, `authResetPassword` (3 new entries) |

No `NEEDS CLARIFICATION` items remain.
