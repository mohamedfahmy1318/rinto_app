<!-- SPECKIT START -->
Active feature: `003-auth-forgot-otp-reset` (Auth Recovery Flows — Clean-Arch Migration).

- Plan: [specs/003-auth-forgot-otp-reset/plan.md](specs/003-auth-forgot-otp-reset/plan.md)
- Spec: [specs/003-auth-forgot-otp-reset/spec.md](specs/003-auth-forgot-otp-reset/spec.md)
- Research: [specs/003-auth-forgot-otp-reset/research.md](specs/003-auth-forgot-otp-reset/research.md)
- Data model: [specs/003-auth-forgot-otp-reset/data-model.md](specs/003-auth-forgot-otp-reset/data-model.md)
- Contracts: [specs/003-auth-forgot-otp-reset/contracts/](specs/003-auth-forgot-otp-reset/contracts/)
- Quickstart: [specs/003-auth-forgot-otp-reset/quickstart.md](specs/003-auth-forgot-otp-reset/quickstart.md)
- Constitution: [.specify/memory/constitution.md](.specify/memory/constitution.md)

Previous:
- `002-auth-login-register` (Auth Login + Register migration) — merged to main.
- `001-core-network-di` (Core Networking & DI Foundation) — merged to main.

Next candidates (to be decided):
- `004-session-cubit-migration` — introduce `SessionCubit` and migrate the remaining ~15 `AuthProvider` consumers so the legacy bridge (`hydrateFromSession` / `clearSession` + `BlocListener` shims) can be deleted.
- Deliver the typed `Failure` hierarchy follow-up scoped out of feature 001 (concrete `NetworkFailure` / `ServerFailure` mapping in the error interceptor).
- Migrate a non-auth feature (Favorites / Notifications / Profile / ...).
<!-- SPECKIT END -->
