# Rento Go Constitution
<!-- Project: rento_go (Flutter mobile app, pubspec v1.1.0+19) -->
<!-- Derived from existing codebase — preserves current architecture. -->

## Core Principles

### I. Preserve Working Code (NON-NEGOTIABLE)
Do NOT modify, refactor, rename, or "clean up" any code that is already working.
Changes to existing, working code are permitted ONLY when the user explicitly
requests an improvement, fix, or refactor of that specific code. This applies
equally to files in `lib/`, `admin/`, `deploy/`, and SQL schemas at the repo
root. New features must be added alongside existing code without rewriting it.

### II. Layered Feature-based Architecture
The app follows a layered structure under `lib/`. Every new code unit MUST be
placed in the layer matching its responsibility:

- `lib/core/` — cross-cutting concerns only: `constants/`, `theme/`,
  `localization/`. No feature logic here.
- `lib/models/` — plain Dart data classes with `fromJson` / `toJson`
  (see `listing_model.dart`, `user_model.dart`). No UI, no network calls.
- `lib/providers/` — state holders extending `ChangeNotifier`
  (see `app_provider.dart`, `auth_provider.dart`). Providers orchestrate
  services and expose state to the UI; they do NOT contain widgets.
- `lib/services/` — external integrations: REST (`api_service.dart`),
  Firebase/FCM, IAP (Apple/Google), chat, realtime. Services are stateless
  helpers (static methods or instance classes) and do NOT hold UI state.
- `lib/screens/` — UI. Organized by feature folder
  (`auth/`, `home/`, `listing_details/`, `my_listings/`, `chat/`, `checkout/`,
  `profile/`, `packages/`, `search/`, `notifications/`, `favorites/`,
  `add_listing/`, `edit_listing/`, `banner_details/`). Shared presentational
  widgets live in `lib/screens/widgets/`.

New features create a new folder under `lib/screens/<feature>/` plus a
matching provider/service/model only when needed. Do NOT introduce parallel
top-level directories (no `lib/features/`, `lib/bloc/`, `lib/controllers/`,
`lib/repositories/`, etc.).

### III. State Management — Provider Only
The single approved state management solution is `provider: ^6.1.1` with the
`ChangeNotifier` pattern, registered through `MultiProvider` in
[lib/main.dart](lib/main.dart).

- New global state MUST be a `ChangeNotifier` added to that `MultiProvider`.
- Screens consume state via `Consumer<T>`, `context.watch<T>()`, or
  `context.read<T>()` — consistent with existing usage.
- Do NOT introduce Riverpod, BLoC, GetX, Redux, MobX, InheritedWidget
  subclasses, or any other state library. Local ephemeral UI state uses
  `StatefulWidget` (as today).
- Persisted preferences go through `SharedPreferences` with keys defined in
  `StorageKeys` (`lib/core/constants/app_constants.dart`). Sensitive values
  use `flutter_secure_storage`.

### IV. Naming Conventions (Strict)
File and symbol naming mirrors the existing codebase exactly:

- Files: `snake_case.dart`.
- Suffix by layer (required):
  - Models → `*_model.dart` with class `XxxModel`
  - Providers → `*_provider.dart` with class `XxxProvider extends ChangeNotifier`
  - Services → `*_service.dart` with class `XxxService`
  - Screens → `*_screen.dart` with class `XxxScreen`
  - Reusable widgets → descriptive `snake_case.dart` (e.g.
    `listing_card.dart`, `search_bar_widget.dart`)
- Classes: `PascalCase`. Methods/variables: `camelCase`. Private members
  prefixed with `_`.
- Constants grouped in classes inside `lib/core/constants/app_constants.dart`
  (e.g. `AppConstants.baseUrl`, `StorageKeys.token`). Do NOT scatter raw
  string literals for endpoints, storage keys, or config.
- API endpoint strings follow the existing pattern (relative path, no leading
  slash — e.g. `'auth/register'`, `'users/update'`).

### V. Consistency Over Novelty
When adding code, match the style, idioms, and patterns already present in
sibling files. Examples:

- Network calls go through `ApiService.get/post/put/delete` returning
  `ApiResponse`. Do NOT call `http` or `dio` directly from providers/screens.
- Localization strings go through `AppLocalizations`; the app supports `ar`,
  `he`, `en` with RTL handling in [lib/main.dart](lib/main.dart). Every
  user-facing string MUST be localized in all three locales.
- Theming uses `AppTheme.lightTheme` / `AppTheme.darkTheme` and colors from
  `AppColors`. Do NOT hardcode colors or text styles in widgets.
- Navigation uses `go_router` v13 (already in `pubspec.yaml`); do not add
  a second router.

## Technology Stack (Locked)

Changing the stack is a constitutional amendment, not a routine change.

- Flutter / Dart SDK `^3.8.1`.
- State: `provider ^6.1.1`.
- Routing: `go_router ^13.0.0`.
- Network: `http ^1.2.0` (primary via `ApiService`), `dio ^5.4.0`
  (special cases only).
- Storage: `shared_preferences ^2.2.2`, `flutter_secure_storage ^9.0.0`.
- Firebase: `firebase_core ^2.25.4`, `firebase_messaging ^14.7.15`,
  `flutter_local_notifications ^17.0.0` — initialized in
  [lib/main.dart](lib/main.dart) with `kIsWeb` / `Platform.isAndroid` guards
  (do not remove those guards).
- IAP: `in_app_purchase ^3.1.13` via `apple_iap_service.dart` /
  `google_iap_service.dart`.
- Forms: `flutter_form_builder ^10.1.0` + `form_builder_validators ^11.0.0`.
- Platforms supported: Android + iOS. Web is guarded, not targeted.

New dependencies require explicit user approval and a justification that no
existing dependency already covers the need.

## Development Workflow

1. **Read before writing.** Before touching any file, read it and its
   siblings to confirm the pattern. Reuse existing helpers
   (`ApiService`, `StorageKeys`, `AppColors`, `AppLocalizations`).
2. **Add, don't alter.** New features land as new files in the correct
   layer. Touch existing files only when the user asks, or when integration
   is unavoidable (e.g. registering a new provider in `MultiProvider`, or
   adding a new locale key).
3. **Match the three locales.** Any new user-facing string is added to
   `ar`, `he`, and `en` together — never commit a string in only one locale.
4. **Respect RTL.** New UI must render correctly under `TextDirection.rtl`
   (Arabic/Hebrew) and `ltr` (English) using the existing `Directionality`
   wrapper from [lib/main.dart:77-80](lib/main.dart#L77-L80).
5. **Scope discipline.** Do not rename variables, reformat files, tidy
   imports, or "modernize" code in files unrelated to the task. Drive-by
   edits are prohibited.

## Governance

This constitution supersedes personal preference and general "best practice"
advice when they conflict. Any proposed change to:

- the architectural layers (`core/models/providers/services/screens`),
- the state management library,
- the naming conventions, or
- the locked technology stack

is an **amendment** and requires explicit user approval before implementation.
Routine feature work under these rules does not need approval beyond the
normal task request.

When a task seems to require breaking one of these principles, stop and ask
the user before proceeding. If in doubt about an architectural placement,
prefer the pattern used by the closest existing sibling file.

**Version**: 1.0.0 | **Ratified**: 2026-04-21 | **Last Amended**: 2026-04-21
