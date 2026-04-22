# Feature Specification: Core Networking & DI Foundation

**Feature Branch**: `001-core-network-di`
**Created**: 2026-04-22
**Status**: Draft
**Input**: User description: "عايز أبدأ الـ Refactor ببناء الأساسيات (Core Layer): عمل Dio Factory/Wrapper بيدعم (Base URLs, Timeouts). إضافة Interceptors للـ (Logging, Auth Token, Header handling). عمل ملف ApiEndpoints لتنظيم الـ URLs. عمل Dependency Injection بسيط باستخدام get_it لتسجيل الـ Dio instance."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Single Network Client, Shared Across Features (Priority: P1)

As an engineer migrating a feature into the new Clean Architecture layout, I
need one already-configured network client available app-wide so I don't
re-wire base URL, timeouts, headers, or auth in every data source I write.

**Why this priority**: This is the ground-floor enabler for the entire
refactor. Without a shared, correctly-configured client, every subsequent
feature slice would redo the same plumbing, drift apart, and bring back the
inconsistencies the refactor is meant to remove.

**Independent Test**: Can be verified by running the app, resolving the
client from the DI container in a temporary test call site, issuing a
request against any existing `rento_go` endpoint (e.g. a public GET), and
confirming the response lands with the expected base URL applied and the
expected headers attached — no per-call setup required.

**Acceptance Scenarios**:

1. **Given** the app has finished startup, **When** any layer asks the DI
   container for the network client, **Then** it receives a ready-to-use
   client with the configured base URL, timeouts, and default headers
   already applied.
2. **Given** a new data source is being added, **When** it performs an API
   call through the shared client, **Then** no endpoint-specific base URL,
   timeout, or default header setup is needed in the data source itself.

---

### User Story 2 - Auth Token Attached Transparently (Priority: P1)

As an end user who has signed in, when any screen triggers a network
request on my behalf, my session token is attached to the request
automatically, without the feature code needing to know where the token is
stored or how to format it.

**Why this priority**: Every authenticated feature (listings, favorites,
chat, checkout, packages, profile) depends on this. If token handling is
duplicated at call sites, one forgotten call silently breaks auth in
production.

**Independent Test**: Can be verified by signing in on a test build,
triggering a request that requires auth (e.g. fetching the logged-in
user's listings), and confirming via the network log that the request
carries `Authorization: Bearer <token>` — and that the same request, made
while signed out, carries no `Authorization` header (not a malformed one).

**Acceptance Scenarios**:

1. **Given** a user is logged in, **When** any request flows through the
   network client, **Then** the request is sent with the current
   authorization header attached.
2. **Given** a user is signed out, **When** a request flows through the
   network client, **Then** the request is sent with no authorization
   header (and no placeholder or empty header).
3. **Given** the user logs out mid-session, **When** a subsequent request
   is issued, **Then** the request does not carry the previous token.

---

### User Story 3 - Debuggable Traffic in Development, Silent in Release (Priority: P2)

As an engineer debugging a network issue, I can see the full outbound
request and inbound response in the debug console without adding temporary
print statements; in release builds, that same traffic is not logged, so
user data is not written to device logs.

**Why this priority**: High dev-experience value and a non-trivial
privacy/compliance concern in release. Lower than P1 because feature work
can proceed on a silent client, but missing this forces engineers back
into ad-hoc logging that leaks.

**Independent Test**: Can be verified by running the app in debug, issuing
any request, and confirming the request/response appear in the debug
console in a readable form; then running a release build and confirming
no network payloads appear in system logs.

**Acceptance Scenarios**:

1. **Given** the app runs in debug mode, **When** a request is issued,
   **Then** the method, URL, headers, and body are visible in the debug
   console along with the response status and body.
2. **Given** the app runs in release mode, **When** a request is issued,
   **Then** neither request nor response payloads are written to any log
   sink.

---

### User Story 4 - Correct Language-Tagged Responses (Priority: P2)

As an end user, when I switch the app language (Arabic / Hebrew / English),
every subsequent network response that includes server-localized content
returns in the language I selected — because the active locale is sent
with every request automatically.

**Why this priority**: `rento_go` already supports three locales with RTL
for Arabic/Hebrew. Language must travel with every request so server text
(notifications, error messages, localized catalog data) matches the UI.
Dropping it at the network layer produces UI inconsistencies that users
notice but rarely report cleanly.

**Independent Test**: Can be verified by changing the in-app language,
issuing a request that returns server-localized text, and confirming the
response uses the selected locale — without the feature code adding a
language header itself.

**Acceptance Scenarios**:

1. **Given** the active locale is Arabic, **When** any request is issued,
   **Then** the request carries a language indicator matching `ar`.
2. **Given** the user changes the language at runtime, **When** the next
   request is issued, **Then** the request carries the new locale without
   the app being restarted.

---

### User Story 5 - One Place for URL Paths (Priority: P3)

As an engineer updating or adding an endpoint, I change the URL path in
exactly one catalog file; every data source that calls that endpoint
picks up the change with no further edits.

**Why this priority**: Quality-of-life and drift prevention. The app works
today with raw strings scattered across services; consolidating them is
valuable but not blocking for the first migrated feature.

**Independent Test**: Can be verified by changing a single path constant
in the catalog and observing that all call sites now target the new path
without any other edits — confirmed by grep showing zero raw endpoint
string literals outside the catalog.

**Acceptance Scenarios**:

1. **Given** the catalog defines endpoint paths as named constants,
   **When** an engineer renames a path in the catalog, **Then** every
   call site compiles and uses the new path.
2. **Given** a PR is opened, **When** a reviewer greps the data layer for
   raw URL literals, **Then** none are found outside the catalog file.

---

### Edge Cases

- **Cold start request ordering**: a request is issued before the
  authentication state has finished loading from persistent storage. The
  client MUST NOT attach a malformed/empty `Authorization` header; it
  sends the request unauthenticated, and the caller handles the resulting
  401 through normal error paths.
- **Token absent vs. token empty string**: both cases are treated
  identically — no authorization header is attached.
- **401 on an authenticated request**: the client does not retry
  automatically in this feature; the typed error surfaces to the caller
  for the Cubit to decide (logout vs. refresh is out of scope here).
- **Language changed mid-flight**: the next request picks up the new
  locale; in-flight requests are not cancelled or retried.
- **No network connectivity**: surfaces as a typed connectivity error
  consistent across all call sites (no `SocketException` leaking into
  presentation code).
- **Server responds with invalid JSON / unexpected status**: surfaces as a
  typed parse / unexpected-response error, not as an unhandled throw.
- **Request timeout exceeded**: surfaces as a typed timeout error; timeout
  values are the same across the app (no per-call overrides in v1).
- **DI lookup before initialization**: resolving the client before the DI
  container has been configured at app startup fails immediately with a
  clear error (not a null pointer later in a request).
- **Re-initialization in tests**: the DI setup is safely callable more
  than once per process (or explicitly rejects re-registration with a
  clear message), so widget tests can share or reset the container.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST expose a single configured network client
  (based on `dio`) that carries the app-wide base URL, connect/receive/send
  timeouts, and default content/accept headers.
- **FR-002**: The network client MUST be registered as an app-wide
  singleton in the DI container (`get_it`) and resolvable from any layer
  that holds a reference to the container.
- **FR-003**: The DI container MUST be initialized once at app startup,
  before the first widget tree is built.
- **FR-004**: The system MUST attach a Logging interceptor that writes
  request/response information to the debug console only when the app
  runs in debug mode; it MUST be inert in release builds.
- **FR-005**: The system MUST attach an Auth interceptor that reads the
  current session token from the app's existing token store and, when a
  token is present, injects `Authorization: Bearer <token>` on outgoing
  requests.
- **FR-006**: When no token is available (signed-out state or cold start
  before auth loads), the Auth interceptor MUST attach no authorization
  header at all (not an empty, malformed, or placeholder header).
- **FR-007**: The system MUST attach a Header interceptor that injects
  the active UI locale (`ar` / `he` / `en`) into every outgoing request,
  and keeps the value in sync with the user's in-app language selection.
- **FR-008**: Base URL and timeout values MUST be read from a centralized
  configuration source (app constants), with no duplicated literals at
  individual call sites or interceptors.
- **FR-009**: The system MUST expose API endpoint paths via a single
  `ApiEndpoints` catalog (constants grouped in one file); data sources
  MUST reference the catalog rather than literal path strings.
- **FR-010**: The system MUST NOT expose the raw network client library
  type across layer boundaries — data sources depend on the configured
  wrapper; Domain/Presentation layers never see it.
- **FR-011**: The system MUST support adding an Error-mapping interceptor
  seat (wired, but the concrete typed-failure mapping is implemented by a
  later feature); the interceptor pipeline order MUST be deterministic
  and documented.
- **FR-012**: The system MUST NOT break existing features that still use
  the legacy `http`-based `ApiService`; both clients coexist until each
  feature is migrated individually.
- **FR-013**: The system MUST operate on Android and iOS runtime targets
  supported by the existing app; web is not a target.

### Key Entities *(include if feature involves data)*

- **Network Client (Wrapper)**: The shared, configured entry point for
  all outbound HTTP traffic; carries base URL, timeouts, default headers,
  and the interceptor pipeline. One per app process.
- **Interceptor Pipeline**: An ordered chain of request/response
  transformers: `Auth` → `Language/Headers` → `Logging` → `Error`
  (logging last outbound / first inbound so it sees the final request and
  the raw response). Composed once at client construction time.
- **API Endpoint Catalog**: A single namespace of endpoint path constants
  (e.g. `ApiEndpoints.authRegister`, `ApiEndpoints.usersUpdate`,
  `ApiEndpoints.listings`, …) grouped by domain section.
- **Service Locator**: The DI container holding the shared network client
  (and, over time, shared repositories/use cases). Initialized once at
  startup via a single `setupLocator()` call.
- **Typed Failure** *(referenced, defined later)*: The error shape the
  Error interceptor eventually produces and that repositories return
  upward; scoped out of this feature, stubbed in.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Any new or migrated data source obtains a ready-to-use
  network client in a single DI lookup, with zero per-call configuration
  code — verified by the first migrated feature touching the network
  adding exactly one DI resolution line.
- **SC-002**: Adding a new endpoint to the app requires edits in exactly
  two files: the endpoint catalog and the data source that calls it.
- **SC-003**: 100% of API calls made through the new client carry the
  active locale indicator; 100% of calls made while the user is logged
  in carry the session token — verified by inspecting outgoing requests
  in debug mode across every migrated feature.
- **SC-004**: Changing the base URL or any timeout value takes effect
  across all API calls via a single-file edit.
- **SC-005**: In debug builds, every request yields a readable
  request/response log line; in release builds, zero request or response
  payload content appears in any log sink.
- **SC-006**: The Core Layer is reusable without modification across the
  first three feature migrations that follow this feature — verified by
  those migrations landing without edits to files under the core network
  directory.
- **SC-007**: A request issued before auth state has loaded (cold start)
  results in a well-formed unauthenticated request — not a malformed
  header, not a crash — confirmed by an explicit acceptance check at
  first-run startup.
- **SC-008**: Attempting to resolve the network client before DI setup
  runs fails fast with a clear, actionable error message (not a silent
  null or a crash buried inside a request).

## Assumptions

- The token used by the Auth interceptor continues to live where the
  current app places it — the existing token store read by
  [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart).
  Moving the token into dedicated secure storage is a separate future
  feature and not scoped here.
- The base URL is a single value taken from the existing app constants
  (`AppConstants.baseUrl`); environment flavors (dev/staging/prod) are
  not introduced by this feature and remain out of scope.
- Default timeouts are set to 30 seconds (matching the current behavior
  in [lib/services/api_service.dart](lib/services/api_service.dart)),
  applied uniformly — no per-call overrides in v1.
- The active locale is read from the current user-facing language
  selection persisted under `StorageKeys.language` (as used today by
  [lib/providers/app_provider.dart](lib/providers/app_provider.dart)).
- Typed-failure error modelling (sealed `Failure` hierarchy + `Either` /
  `Result` plumbing) is a separate foundation feature; this feature wires
  the Error-interceptor seat but leaves the concrete mapping to that
  later feature.
- The legacy `http`-based `ApiService` remains available and untouched
  during this feature; both coexist and features migrate off the legacy
  path one at a time.
- Three locales supported end-to-end: `ar`, `he`, `en` — unchanged from
  the current app.
- Target platforms: Android and iOS only (web is guarded but not a
  deployment target, consistent with existing app behavior).
- The DI library is `get_it` (locked by the constitution); no separate
  ServiceLocator abstraction is introduced.
