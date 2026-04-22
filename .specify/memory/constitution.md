<!--
Sync Impact Report
==================
Version change: 1.0.0 → 2.0.0 (MAJOR — all principles redefined incompatibly)

Principles (old → new):
  I.  Preserve Working Code (NON-NEGOTIABLE)        → I.  Clean Architecture (NON-NEGOTIABLE)
  II. Layered Feature-based Architecture            → II. Cubit State Management (NON-NEGOTIABLE)
  III. State Management — Provider Only             → III. Dio-based Networking with Wrapper
  IV. Naming Conventions (Strict)                   → IV. DRY through Custom Widgets
  V.  Consistency Over Novelty                      → V.  Simple, Readable, Organized Code

Added sections:
  - Refactor Direction (replaces "Technology Stack (Locked)")
  - Folder Structure (Clean Architecture layout)

Removed sections:
  - "Preserve Working Code" constraint (explicitly revoked — refactor is authorized)
  - "Provider Only" lock (superseded by Cubit)
  - "http primary" rule (superseded by Dio wrapper)

Templates requiring updates:
  - ✅ .specify/memory/constitution.md (this file)
  - ⚠ pending .specify/templates/plan-template.md — Constitution Check gate
    is rule-driven and will consume the new principles automatically; no edit
    needed unless Clean-Arch-specific gates are desired later.
  - ⚠ pending .specify/templates/spec-template.md — no structural change
    required; specs remain tech-agnostic.
  - ⚠ pending .specify/templates/tasks-template.md — no structural change
    required; task categorization is feature-driven.
  - ⚠ pending CLAUDE.md / README.md — runtime guidance docs still reference
    the prior stack; update when next touched.

Deferred TODOs:
  - TODO(ratification_date_review): original constitution v1.0.0 was ratified
    2026-04-21 — retained as the adoption date.
-->

# Rento Go Constitution

<!-- Project: rento_go (Flutter mobile app, pubspec v1.1.0+19) -->
<!-- Refactor-phase constitution. Authorizes and governs a full migration
     away from the prior Provider/http layered architecture. -->

## Core Principles

### I. Clean Architecture (NON-NEGOTIABLE)

All Dart code under `lib/` MUST be organized into three explicit layers with
strict, one-way dependencies: **Presentation → Domain → Data**. Domain is the
center and depends on nothing; Presentation depends on Domain (and on Cubits
that consume use cases); Data implements Domain-defined contracts.

- **Data layer** (`lib/data/`): `models/` (DTOs with `fromJson`/`toJson`),
  `datasources/` (remote via Dio, local via SharedPreferences /
  SecureStorage), `repositories/` (concrete implementations of Domain
  repository interfaces). Data MUST NOT import from Presentation.
- **Domain layer** (`lib/domain/`): `entities/` (pure Dart, framework-free),
  `repositories/` (abstract interfaces), `usecases/` (single-responsibility
  callable classes). Domain MUST NOT import Flutter, Dio, Bloc, or any
  framework/package other than `dart:core` and `equatable`/`dartz`-class
  helpers if adopted.
- **Presentation layer** (`lib/presentation/`): `cubits/` (state + Cubit
  classes), `pages/` (screens, one folder per feature), `widgets/` (shared
  and feature-scoped custom widgets). Presentation MUST NOT call data
  sources or repositories directly — it goes through use cases exposed via
  Cubits.

Cross-layer wiring (dependency injection) lives in `lib/core/di/`. Shared
utilities (errors, constants, theme, localization, network client setup)
live in `lib/core/`. Any code that violates the dependency direction is a
constitutional violation and MUST be rejected in review.

**Rationale**: isolates business rules from UI and I/O, makes each layer
independently testable, and enables safe replacement of Dio/Bloc/etc. in the
future without rewriting domain logic.

### II. Cubit State Management (NON-NEGOTIABLE)

State MUST be managed with `flutter_bloc`'s **Cubit** API (not `Bloc`,
unless a feature provably needs event streams — in which case the migration
to `Bloc` requires explicit approval). Cubits MUST:

- Live under `lib/presentation/cubits/<feature>/` as a pair:
  `<feature>_cubit.dart` and `<feature>_state.dart`.
- Expose immutable state classes (sealed classes or `Equatable`
  subclasses — pick one and stay consistent). No mutable fields on state.
- Receive their dependencies (use cases) through the constructor. No
  service locators called inside methods.
- Be provided via `BlocProvider` at the nearest sensible scope — global
  cubits at app root (`MultiBlocProvider` in `main.dart`), feature cubits
  scoped to the feature's route.

UI MUST consume state via `BlocBuilder`, `BlocListener`, `BlocConsumer`, or
`context.read<T>()` / `context.watch<T>()`. **`provider` and `ChangeNotifier`
MUST NOT be used for new code** and MUST be removed from migrated features.
Local ephemeral UI state (scroll controllers, form controllers, animation
state) stays in `StatefulWidget`.

**Rationale**: Cubit gives predictable, testable state with a minimal API,
trivial to unit-test in isolation, and aligns with the Clean Architecture
dependency rule (Cubits live in Presentation and call use cases).

### III. Dio-based Networking with Wrapper

All HTTP traffic MUST go through a single Dio client wrapper. Direct use of
`package:http` is forbidden in new code and MUST be removed from migrated
features.

- The wrapper lives at `lib/core/network/api_client.dart` (or equivalent)
  and MUST centralize:
  - **BaseOptions**: `baseUrl`, `connectTimeout`, `receiveTimeout`,
    `sendTimeout`, default `headers` (`Content-Type`, `Accept`).
  - **Interceptors** (required):
    - `AuthInterceptor` — injects `Authorization: Bearer <token>` from
      secure storage; triggers refresh or logout on 401.
    - `LoggerInterceptor` — debug-only request/response logging
      (gated by `kDebugMode`, never in release).
    - `ErrorInterceptor` — maps `DioException` to typed `Failure` objects
      defined in `lib/core/error/`.
    - `LanguageInterceptor` — injects the active locale header so the
      server returns the correct `ar` / `he` / `en` response.
- Data sources MUST depend on the wrapper, not on raw `Dio`. The raw Dio
  instance is instantiated once in `lib/core/di/` and is not exported.
- Repository implementations MUST catch `DioException` (or its mapped
  `Failure`) and return a typed result (`Either<Failure, T>` or an explicit
  sealed `Result` type — decide once per the refactor plan).
- Timeouts, retry policy, and cache policy are configured on the wrapper,
  not duplicated at call sites.

**Rationale**: one place to change for auth/logging/retries, uniform error
handling, and a clean seam to mock the network in tests.

### IV. DRY through Custom Widgets

Repeated UI patterns MUST be extracted into reusable custom widgets. A
pattern is "repeated" once it appears in **two** places — on the third, a
custom widget is mandatory, not optional.

- Shared widgets live in `lib/presentation/widgets/` (app-wide) or
  `lib/presentation/pages/<feature>/widgets/` (feature-scoped).
- Custom widgets MUST be:
  - **Configurable** via parameters, not forked per caller.
  - **Stateless where possible**; use `StatefulWidget` only for widgets
    that own genuine local state.
  - **Theme-driven** — read from `Theme.of(context)` and app color/text
    tokens; never hardcode colors, sizes, paddings, or text styles inline
    in a screen.
- Primitive building blocks MUST exist and be used: `AppButton`,
  `AppTextField`, `AppAppBar`, `AppLoader`, `AppErrorView`, `AppEmptyView`,
  `AppImage`/`CachedImage`. Screens compose these — they do not re-derive
  them.
- **No copy-paste UI.** A pull request that duplicates a widget block
  already present elsewhere MUST either reuse the existing widget or
  extract a new one in the same PR.

**Rationale**: DRY reduces visual drift across the app, shrinks PR
diffs during design changes, and keeps screens readable as composition
rather than markup.

### V. Simple, Readable, Organized Code

Every file, class, and function MUST be written for the next reader.

- **Simplicity**: prefer the smallest solution that works. No premature
  abstraction, no "in case we need it later" parameters, no speculative
  generality. If a feature works with one class, do not split it into
  three.
- **Readability**:
  - Naming: intent-revealing. Methods are verbs (`fetchListings`,
    `toggleFavorite`); booleans are questions (`isLoading`, `hasError`);
    classes are nouns (`ListingCubit`, `AuthRepository`).
  - File names: `snake_case.dart`. Class names: `PascalCase`. Methods,
    fields: `camelCase`. Private members: leading `_`.
  - Suffix by role (required): `*_model.dart` (Data DTOs),
    `*_entity.dart` (Domain entities), `*_repository.dart` (Domain
    interfaces) + `*_repository_impl.dart` (Data impls),
    `*_usecase.dart`, `*_cubit.dart`, `*_state.dart`, `*_page.dart`,
    `*_widget.dart`, `*_datasource.dart`.
  - Functions do one thing; target ≤ 40 lines. Files target ≤ 300 lines.
    Exceeding these is a smell that triggers extraction — not a hard ban,
    but requires a note in review.
- **Organization**:
  - No mixed layers in one file. No UI code in Data. No Dio imports in
    Domain. No business logic in widgets.
  - Imports ordered: `dart:*` → `package:*` → relative. Use
    `flutter_lints` (already in `pubspec.yaml`) plus stricter rules added
    to `analysis_options.yaml` (unused imports, prefer_const_constructors,
    prefer_final_locals, always_declare_return_types).
  - Constants centralized (`lib/core/constants/`); raw string literals for
    endpoints, storage keys, or config are forbidden.
  - Localization: every user-facing string lives in the ARB-based
    `AppLocalizations` with `ar`, `he`, `en` entries added together.
- **Comments**: default to none. Write a short comment ONLY when the *why*
  is non-obvious (a workaround, an invariant, a known edge case). Do not
  describe *what* the code already shows.

**Rationale**: simple code survives refactors; readable code ships faster;
organized code makes the Clean Architecture boundaries self-enforcing.

## Refactor Direction

This constitution authorizes an ongoing, **incremental** refactor of the
existing `rento_go` codebase toward the target architecture above. The old
structure under `lib/{core,models,providers,screens,services}` is being
superseded by `lib/{core,data,domain,presentation}`.

- **Target stack (locked during refactor)**:
  - State: `flutter_bloc` (Cubit).
  - Network: `dio` + typed wrapper + interceptors.
  - Error modelling: sealed `Failure` types under `lib/core/error/`
    (adopting `dartz`'s `Either` or an explicit `Result` — pick once,
    use everywhere).
  - DI: `get_it` (or injected manually through constructors + a
    composition root in `lib/core/di/`). Choose one; do not mix.
  - Routing: `go_router` (already in `pubspec.yaml`) — retained.
  - Storage: `shared_preferences` + `flutter_secure_storage` — retained,
    accessed only from Data layer data sources.
  - Firebase / FCM / IAP / forms / localization packages retained as in
    `pubspec.yaml`.
- **Removed / migrated away from**:
  - `provider: ^6.1.1` — removed once every `ChangeNotifier` is replaced.
  - `http: ^1.2.0` — removed once every `ApiService` call is ported to
    the Dio wrapper.
- **Migration rule**: a feature is "migrated" only when its Cubit, use
  cases, repository (interface + impl), data sources, and pages all live
  under the new layout and the legacy files are deleted — not when they
  coexist. No feature may permanently straddle both architectures.

## Development Workflow

1. **Plan before code.** For each feature or migration slice, identify the
   entities, use cases, repository interface, data sources, Cubit, and
   pages. A PR that adds UI without the supporting layers MUST be split.
2. **Build from Domain outward.** Entities and use cases first (with
   tests where applicable), then Data implementations, then the Cubit,
   then the Page/Widgets. This order guarantees the dependency direction.
3. **Lint is a gate.** Treat `flutter analyze` warnings as errors in
   review. Add stricter lints to `analysis_options.yaml` as the refactor
   progresses.
4. **Three-locale discipline.** Any new user-facing string is added to
   `ar`, `he`, and `en` in the same PR. RTL layout must render correctly
   under both Arabic and Hebrew.
5. **No drive-by edits.** Refactor only the files in scope for the current
   task. Unrelated formatting, renames, or "cleanups" are rejected.
6. **Delete as you go.** When a feature is migrated, delete the legacy
   provider/service/screen files. Do not leave dead code "for reference."

## Governance

This constitution supersedes personal preference and any prior guidance
(including v1.0.0 of this document). Any change to:

- the three-layer Clean Architecture split,
- the choice of Cubit for state,
- the Dio-wrapper rule,
- the DRY / custom-widget requirement,
- the simple/readable/organized baseline,

is an **amendment** requiring explicit user approval and a version bump
below.

**Versioning policy (semantic)**:
- **MAJOR**: a principle is removed, redefined incompatibly, or the stack
  is changed in a way that invalidates in-flight work.
- **MINOR**: a new principle or section is added; an existing principle is
  materially expanded.
- **PATCH**: wording, clarification, typo, or non-semantic refinement.

**Compliance review**:
- Every PR description MUST declare which principles apply and how they
  are upheld (a one-line note is sufficient).
- Reviewers MUST reject PRs that violate principles I–V without a written
  justification in the PR body; unjustified violations are not merged.
- Ambiguous cases are resolved in favour of the pattern already used by
  the most recently migrated feature.

**Version**: 2.0.0 | **Ratified**: 2026-04-21 | **Last Amended**: 2026-04-22
