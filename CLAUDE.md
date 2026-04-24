<!-- SPECKIT START -->
Active feature: `002-auth-login-register` (Auth Clean-Arch Migration) — implemented, pending merge.

- Plan: [specs/002-auth-login-register/plan.md](specs/002-auth-login-register/plan.md)
- Spec: [specs/002-auth-login-register/spec.md](specs/002-auth-login-register/spec.md)
- Research: [specs/002-auth-login-register/research.md](specs/002-auth-login-register/research.md)
- Data model: [specs/002-auth-login-register/data-model.md](specs/002-auth-login-register/data-model.md)
- Contracts: [specs/002-auth-login-register/contracts/](specs/002-auth-login-register/contracts/)
- Quickstart: [specs/002-auth-login-register/quickstart.md](specs/002-auth-login-register/quickstart.md)
- Constitution: [.specify/memory/constitution.md](.specify/memory/constitution.md)

Previous: `001-core-network-di` (Core Networking & DI Foundation) — merged to main.

Next candidates (to be decided):
- Migrate the remaining legacy auth screens (`forgot_password`, `otp`, `reset_password`) onto the same Cubit + Clean-Arch layout used here.
- Introduce a `SessionCubit` and migrate the ~15 downstream `AuthProvider` consumers so the legacy bridge (`hydrateFromSession` / `clearSession` + `BlocListener` shims on the pages) can be removed.
- Deliver the typed `Failure` hierarchy follow-up scoped out of feature 001 (concrete `NetworkFailure` / `ServerFailure` mapping in the error interceptor).
<!-- SPECKIT END -->
