# Implementation Plan: Core Networking & DI Foundation

**Branch**: `001-core-network-di` | **Date**: 2026-04-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-core-network-di/spec.md`

## Summary

Stand up the shared infrastructure the Clean-Architecture refactor will
rely on: a single configured Dio client (with locked base URL and
timeouts), a composable interceptor pipeline (Auth → Language → Logging →
Error), a single `ApiEndpoints` catalog of URL paths, and a `get_it`
service locator that exposes the client to future data sources. No
feature is migrated in this PR; the legacy `http`-based `ApiService`
continues to operate untouched. The typed `Failure` hierarchy is stubbed
(so the Error interceptor seat compiles) and left for a follow-up
feature to flesh out.

## Technical Context

**Language/Version**: Dart `^3.8.1` / Flutter (as pinned by [pubspec.yaml](../../pubspec.yaml))
**Primary Dependencies**: `dio ^5.4.0` (already present), `get_it` (NEW — add at ^7.x), `shared_preferences ^2.2.2` (existing — token & locale reads), `flutter_secure_storage ^9.0.0` (present; NOT used in v1 of this feature)
**Storage**: `SharedPreferences` via `StorageKeys.token` and `StorageKeys.language` (existing — [lib/core/constants/app_constants.dart](../../lib/core/constants/app_constants.dart))
**Testing**: `flutter_test` (existing); unit tests for interceptors and the DI setup
**Target Platform**: Android + iOS (web guarded, not targeted) — matches `Platform.isAndroid` / `kIsWeb` guards in [lib/main.dart](../../lib/main.dart)
**Project Type**: mobile-app (Flutter, single-project layout rooted at `lib/`)
**Performance Goals**: DI setup completes in < 50 ms on cold start on mid-range Android; per-request interceptor overhead < 5 ms; no additional allocations on the hot request path beyond those Dio already performs
**Constraints**: three locales (`ar`/`he`/`en`), RTL for ar/he; legacy `http`-based `ApiService` MUST continue to work unchanged; no `provider`/`ChangeNotifier` touched in this PR
**Scale/Scope**: single app process; ~30 endpoints in the catalog at launch (extracted from the current `ApiService` call sites); one shared Dio instance

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Mapping against [.specify/memory/constitution.md](../../.specify/memory/constitution.md) v2.0.0:

| Principle | Applies? | Status | Notes |
|-----------|----------|--------|-------|
| I. Clean Architecture (NON-NEGOTIABLE) | Yes — infrastructure layer | ✅ PASS | All new files land under `lib/core/**`. No cross-layer imports from Presentation. No Domain code introduced here, so the dependency rule cannot be violated by this slice. |
| II. Cubit State Management (NON-NEGOTIABLE) | No — no UI/state introduced | ✅ N/A | This feature adds zero widgets, Cubits, or providers. |
| III. Dio-based Networking with Wrapper | Yes — direct subject | ✅ PASS | Feature IS the wrapper + interceptors + DI registration. Data sources never see raw `Dio` (FR-010). |
| IV. DRY through Custom Widgets | No — no UI introduced | ✅ N/A | Deferred until the first migrated screen. |
| V. Simple, Readable, Organized Code | Yes — baseline | ✅ PASS | Plan enforces: files ≤ 300 lines, functions ≤ 40 lines, intent-revealing names, imports `dart:` → `package:` → relative, no raw literals for base URL/paths, one-class-per-file. |

**Gate decision**: PASS — proceeding to Phase 0.

One additional guard worth stating upfront: the constitution's "Refactor
Direction" section declares `provider` and `http` as **being migrated
away from**, not deleted yet. This feature honors that by **adding**
`get_it` and Dio-wrapper code alongside the existing `provider`/`http`
stack — it does not touch [lib/main.dart](../../lib/main.dart)'s
`MultiProvider` or delete `ApiService`. First migrated feature will do
the first deletion.

### Post-Phase-1 Re-check (after research.md + data-model.md + contracts/ + quickstart.md)

Re-evaluated after every Phase 1 artifact was produced:

| Principle | Re-check | Notes |
|-----------|----------|-------|
| I. Clean Architecture | ✅ PASS | Every new file lands under `lib/core/**`. No `package:flutter_bloc` / `package:provider` / UI imports appear anywhere. Domain is not introduced (nothing to violate). Data-source consumption contract (see [contracts/api_client.contract.md](contracts/api_client.contract.md) §4) mandates constructor injection and bans `GetIt.instance` inside data-source methods. |
| II. Cubit State Management | ✅ N/A | Still no state introduced. |
| III. Dio-based Networking with Wrapper | ✅ PASS | Pipeline order fixed and documented (R-003); wrapper (`ApiClient.create`) is the single composition point (R-008); data-source contract forbids raw `http`. |
| IV. DRY through Custom Widgets | ✅ N/A | No UI. |
| V. Simple, Readable, Organized Code | ✅ PASS | Every new file projected ≤ 300 lines; no speculative abstractions (e.g. `Either` / `Result` deferred to a later feature, see R-007); endpoint catalog is the simplest shape that works (R-010). Two legacy one-liner edits (R-005, R-009) are the minimum needed to keep old and new in sync during migration — justified and scoped. |

Gate remains **PASS**. No new violations surfaced in Phase 1.

## Project Structure

### Documentation (this feature)

```text
specs/001-core-network-di/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (Dart interface contracts)
│   ├── api_client.contract.md
│   ├── api_endpoints.contract.md
│   └── service_locator.contract.md
├── checklists/
│   └── requirements.md  # From /speckit.specify
└── tasks.md             # Produced by /speckit.tasks (not this command)
```

### Source Code (repository root)

Layout follows the Clean-Architecture target locked by constitution II/III.
Only the `lib/core/**` slice is touched by this feature; the `data/`,
`domain/`, and `presentation/` folders are created **empty** (placeholder
`.gitkeep`) so first migrated feature has the layout ready.

```text
lib/
├── main.dart                               # EDIT — call setupLocator() before runApp
├── core/
│   ├── constants/
│   │   ├── app_constants.dart              # EXISTING — unchanged
│   │   └── api_endpoints.dart              # NEW — URL path catalog (one class, grouped)
│   ├── network/
│   │   ├── api_client.dart                 # NEW — Dio factory/wrapper (BaseOptions + pipeline)
│   │   ├── network_config.dart             # NEW — timeouts / default headers constants
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart       # NEW — reads token, injects Bearer
│   │       ├── language_interceptor.dart   # NEW — injects Accept-Language / custom header
│   │       ├── logging_interceptor.dart    # NEW — kDebugMode-gated
│   │       └── error_interceptor.dart      # NEW — seat + stub mapping to Failure
│   ├── di/
│   │   └── service_locator.dart            # NEW — getIt + setupLocator()
│   ├── error/
│   │   └── failure.dart                    # NEW — sealed stub (filled by a later feature)
│   ├── storage/
│   │   └── token_reader.dart               # NEW — thin sync-safe wrapper over SharedPreferences for the AuthInterceptor
│   ├── theme/                              # EXISTING
│   └── localization/                       # EXISTING
├── data/                                   # NEW empty (.gitkeep)
├── domain/                                 # NEW empty (.gitkeep)
├── presentation/                           # NEW empty (.gitkeep)
├── models/                                 # EXISTING (legacy — untouched)
├── providers/                              # EXISTING (legacy — untouched)
├── screens/                                # EXISTING (legacy — untouched)
└── services/                               # EXISTING (legacy — untouched)

pubspec.yaml                                # EDIT — add get_it ^7.x
analysis_options.yaml                       # EDIT — tighten lints (see Phase 1)
test/
└── core/
    └── network/
        ├── api_client_test.dart            # NEW — base options + interceptor order
        └── interceptors/
            ├── auth_interceptor_test.dart  # NEW
            ├── language_interceptor_test.dart  # NEW
            └── logging_interceptor_test.dart  # NEW (release-silence check is manual)
```

**Structure Decision**: Single-project Flutter mobile-app layout (Option 3
variant with no separate API folder — backend lives outside this repo).
`lib/{core,data,domain,presentation}` is the target structure; legacy
`lib/{models,providers,screens,services}` coexists during migration and
is explicitly **not** touched by this feature. Empty `data/`/`domain/`/
`presentation/` directories are created with `.gitkeep` so the first
migrated feature drops straight into the right place.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified.**

No violations — table intentionally empty.
