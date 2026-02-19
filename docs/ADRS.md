# Architecture Decision Records

Use this file to capture important decisions with tradeoffs.

## ADR Template

### Title
- Short decision statement.

### Date
- YYYY-MM-DD

### Status
- Proposed | Accepted | Superseded

### Context
- What problem are you solving?
- What constraints exist?

### Decision
- The specific approach selected.

### Consequences
- Positive outcomes
- Negative outcomes
- Follow-up work required

### Alternatives Considered
- Option A: pros/cons
- Option B: pros/cons

---

### Session Version Invalidation
- Date: 2026-02-19
- Status: Accepted
- Context: Password reset must invalidate previously issued sessions.
- Decision: Add `users.session_version`, store it in session cookie at login, and reject stale versions on each request.
- Consequences: Clean global session invalidation with no server-side session store; requires one extra integer column and per-request comparison.
- Alternatives Considered: rotating secret per user; centralized session table.

### Explicit Activity Logging Service
- Date: 2026-02-19
- Status: Accepted
- Context: We need immutable activity records without hidden callback side effects.
- Decision: Add `ActivityLogger.log!` service and call it explicitly from mutation service/controller paths.
- Consequences: Clear write-path ownership and testability; requires discipline to log from every mutation entrypoint.
- Alternatives Considered: model callbacks; database triggers.

### Optimistic Locking for Write Conflicts
- Date: 2026-02-19
- Status: Accepted
- Context: Concurrent updates to tasks/projects can silently overwrite each other.
- Decision: Add `lock_version` on `projects` and `tasks`, include hidden `lock_version` in forms, and surface stale update errors.
- Consequences: Prevents lost updates and forces conflict resolution UX; stale submissions now return validation-like errors.
- Alternatives Considered: last-write-wins; pessimistic row locking for all writes.

### Digest and Assignment Notification Preferences
- Date: 2026-02-19
- Status: Accepted
- Context: Outbound emails should be user-controllable and respected consistently.
- Decision: Add `NotificationPreference` per user with `digest_enabled` and `assignment_enabled` toggles; check preferences before sending mail.
- Consequences: Better user control and lower spam risk; introduces preference lifecycle handling for legacy users.
- Alternatives Considered: global config only; per-mailer ad-hoc flags.

### One Digest per User per Day
- Date: 2026-02-19
- Status: Accepted
- Context: Daily digest generation must be idempotent and safe if jobs retry.
- Decision: Add `TaskDigestDelivery(user_id, delivered_on)` unique key and gate mail delivery on it inside `DueTaskDigestJob`.
- Consequences: Strong dedupe guarantees and retry safety; adds a small tracking table and index maintenance.
- Alternatives Considered: cache-based dedupe; mail provider dedupe only.

### API v1 Bearer Token Authentication
- Date: 2026-02-19
- Status: Accepted
- Context: External clients need JSON access to project/task operations without browser sessions.
- Decision: Add `ApiToken` with SHA256 digest storage and expiration, require Bearer tokens in `Api::V1::BaseController`.
- Consequences: Enables scoped API access with revocation/expiration support; requires token issuance and secure storage discipline.
- Alternatives Considered: reusing cookie sessions for API; static shared API key.

### Centralized Policy Authorization
- Date: 2026-02-19
- Status: Accepted
- Context: Authorization checks were spread across controllers and difficult to audit.
- Decision: Introduce plain Ruby policy classes (`OrganizationPolicy`, `ProjectPolicy`, `TaskPolicy`, etc.) and route controller/API checks through them.
- Consequences: Clear deny-by-default access model and easier policy testing; requires maintaining policy coverage when new actions are added.
- Alternatives Considered: continuing ad-hoc controller conditionals; adopting a third-party authorization gem immediately.

### Query Budget Guardrails
- Date: 2026-02-19
- Status: Accepted
- Context: We need automated protection against silent N+1 regressions on key pages.
- Decision: Add a custom SQL query counter in tests and enforce query budgets on dashboard and project pages.
- Consequences: Lightweight regression safety without new runtime dependencies; thresholds require occasional tuning as features grow.
- Alternatives Considered: adding Bullet in development only; relying on manual review.

### Dashboard Cache Key Versioning
- Date: 2026-02-19
- Status: Accepted
- Context: Dashboard data was repeatedly queried on every request and needed controlled caching.
- Decision: Cache dashboard snapshots with keys that include membership/task update versions at microsecond precision.
- Consequences: Better read performance with deterministic invalidation when relevant data changes; cache key logic must stay aligned with dashboard dependencies.
- Alternatives Considered: fixed TTL-only cache keys; manual cache deletes in callbacks.

### Immutable Audit Logs for Security Events
- Date: 2026-02-19
- Status: Accepted
- Context: Security-relevant actions (auth, password reset, membership changes) need tamper-resistant auditability.
- Decision: Add append-only `AuditLog` records via `AuditLogger` and forbid update/destroy operations at model level.
- Consequences: Better compliance and incident forensics with consistent metadata capture; increased write volume and retention concerns over time.
- Alternatives Considered: ad-hoc controller logging only; external log-only approach without relational traceability.

### Soft Delete with Explicit Recovery Methods
- Date: 2026-02-19
- Status: Accepted
- Context: Product/project/task/comment data should be recoverable after deletion while staying hidden from normal reads.
- Decision: Add `deleted_at` columns with a `SoftDeletable` concern (`soft_delete!`, `restore!`, `with_deleted`) and default hidden scope behavior.
- Consequences: Safer recovery for accidental deletes; query paths must be explicit when including deleted data.
- Alternatives Considered: hard delete only; separate archive tables.

### Database Role Routing via Small Abstraction
- Date: 2026-02-19
- Status: Accepted
- Context: Read paths should be ready for replicas and write paths should stay pinned to primary.
- Decision: Add `DatabaseRole.read`/`DatabaseRole.write` wrappers, configure `ApplicationRecord` role mapping, and route query objects/services through these wrappers.
- Consequences: Safer readiness for follower reads with low call-site overhead; role boundaries need to stay explicit in new code.
- Alternatives Considered: ad-hoc `connected_to` calls in controllers; defer role separation to infrastructure only.

### Structured Logging + Classified Error Capture
- Date: 2026-02-19
- Status: Accepted
- Context: We need request-level correlation and actionable production error visibility from inside the app.
- Decision: Add `Observability::StructuredLogger`, `ErrorEvent` storage via `Observability::ErrorTracker`, and `/observability/errors` dashboard.
- Consequences: Better incident triage and classification trends with request IDs; introduces retention and dashboard access considerations.
- Alternatives Considered: external log aggregation only; no in-app error classification view.

### Deployment Preflight as Release Gate
- Date: 2026-02-19
- Status: Accepted
- Context: Deploys need consistent migration safety checks and smoke coverage before rollout.
- Decision: Add `bin/preflight`, `deployment:migration_safety`, smoke tests, and CI jobs for migration safety/smoke.
- Consequences: Faster, repeatable release confidence; extra CI runtime and maintenance of smoke checks.
- Alternatives Considered: manual deploy checklist only; full e2e suite as the only gate.

### PostgreSQL as Primary Datastore
- Date: 2026-02-19
- Status: Accepted
- Context: SQLite does not match expected production concurrency and operational behavior for this app.
- Decision: Replace SQLite with PostgreSQL (`pg` gem), update Rails DB configs for all environments, and run CI/tests against Postgres service containers.
- Consequences: Better parity with production behavior and stronger transactional semantics; requires running a local/CI Postgres service and managing DB environment variables.
- Alternatives Considered: keep SQLite for dev/test only; mixed adapter strategy by environment.
