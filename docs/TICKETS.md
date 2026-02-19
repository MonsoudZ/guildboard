# GuildBoard Ticket Backlog

This backlog is intentionally progressive. Start at T01 and move in order.

## Completed

- T01 - Password Reset Flow (implemented in app and tests)
- T02 - Membership Invitations (implemented in app and tests)
- T03 - Project Archiving Rules (implemented in app and tests)
- T04 - Task State Machine (implemented in app and tests)
- T05 - Search (Organization Scope) (implemented in app and tests)
- T06 - Activity Feed (implemented in app and tests)
- T07 - Service Object Layer (implemented for project/task/comment writes)
- T08 - Optimistic Locking (implemented for projects and tasks)
- T09 - Background Job for Due Digest (implemented in app and tests)
- T10 - Notification Preferences (implemented in app and tests)
- T11 - API Namespace (v1) (implemented for org-scoped project/task CRUD)
- T12 - Policy Layer (implemented with policy classes + controller/API integration)
- T13 - Query Objects (implemented for dashboard and organization search)
- T14 - N+1 and Query Budgeting (implemented with SQL-count budgets in integration tests)
- T15 - Caching Strategy (implemented for dashboard with explicit versioned keys)
- T16 - Full Audit Log (implemented for security-sensitive auth/membership actions)
- T17 - Soft Deletion Strategy (implemented for project/task/comment visibility + restoration)
- T18 - Multi-DB Read Replica Readiness (implemented with read/write role wrappers + tests)
- T19 - Production Observability (implemented with structured logs + request error classification dashboard)
- T20 - Deployment Hardening (implemented with runbook, preflight command, and CI migration/smoke stages)

## Mid-Level Foundation

### T01 - Password Reset Flow
- Scope: implement reset token generation, expiration, email delivery, and secure password change.
- Acceptance: expired/invalid token is rejected; successful reset invalidates prior sessions.
- Tests: model tests for token TTL, integration tests for happy/failure paths.
- Senior review checklist: no user enumeration in responses; token entropy and one-time use.

### T02 - Membership Invitations
- Scope: invite users by email to organizations with role selection and acceptance flow.
- Acceptance: only managers/owners can invite; invitee can accept once.
- Tests: authorization and acceptance lifecycle tests.
- Senior review checklist: enforce idempotency; clear audit trail of inviter and accepted time.

### T03 - Project Archiving Rules
- Scope: prevent new tasks/comments on archived projects while preserving read access.
- Acceptance: archived project is read-only in UI and controllers.
- Tests: request tests for blocked writes and allowed reads.
- Senior review checklist: enforce at model and controller boundaries.

### T04 - Task State Machine
- Scope: formalize allowed state transitions (`todo -> in_progress -> done`, with blocked exits).
- Acceptance: invalid transition returns validation error and is not persisted.
- Tests: model tests for transition matrix and edge cases.
- Senior review checklist: explicit transitions over callback magic.

### T05 - Search (Organization Scope)
- Scope: implement task/project search scoped to one organization.
- Acceptance: results include only current org data with pagination.
- Tests: request tests for scope safety and ranking expectations.
- Senior review checklist: SQL injection-safe query composition.

### T06 - Activity Feed
- Scope: append immutable activity events for task/project changes.
- Acceptance: each create/update/comment produces a structured event.
- Tests: model and integration coverage for event creation.
- Senior review checklist: avoid callback storms; explicit service entrypoint.

## Senior-Level Application Design

### T07 - Service Object Layer
- Scope: introduce command objects for project/task mutations.
- Acceptance: controllers delegate writes to services with transaction boundaries.
- Tests: service tests for happy paths and rollback behavior.
- Senior review checklist: clear inputs/outputs; no hidden side effects.

### T08 - Optimistic Locking
- Scope: prevent lost updates on tasks and projects using lock versioning.
- Acceptance: stale updates fail with user-visible conflict response.
- Tests: concurrent update simulation tests.
- Senior review checklist: conflict handling UX and retry strategy.

### T09 - Background Job for Due Digest
- Scope: create daily digest job for overdue/upcoming tasks per user.
- Acceptance: one digest per user/day with deduping.
- Tests: job tests plus scheduler integration.
- Senior review checklist: idempotency and failure retry safety.

### T10 - Notification Preferences
- Scope: user-level opt-in/opt-out for digest and task assignment notifications.
- Acceptance: preferences respected for all outbound notifications.
- Tests: model + integration tests across preference combinations.
- Senior review checklist: sane defaults and migration strategy.

### T11 - API Namespace (v1)
- Scope: JSON endpoints for projects/tasks with token auth.
- Acceptance: parity with core read/write operations and validation errors.
- Tests: request tests for contracts, auth, and error shapes.
- Senior review checklist: stable response schema; explicit versioning strategy.

### T12 - Policy Layer
- Scope: centralize authorization in plain Ruby policy objects.
- Acceptance: controllers call policies, not ad-hoc membership checks.
- Tests: policy unit tests and request-level policy enforcement tests.
- Senior review checklist: deny-by-default and easy-to-audit policy map.

### T13 - Query Objects
- Scope: extract complex list/filter queries into query objects.
- Acceptance: controllers stop embedding query logic.
- Tests: query object tests with filtering/pagination cases.
- Senior review checklist: composability and predictable SQL.

## Senior-Level Reliability and Scale

### T14 - N+1 and Query Budgeting
- Scope: add Bullet or custom query budget checks for dashboard/project views.
- Acceptance: target pages stay under agreed query thresholds.
- Tests: integration test assertions for query counts.
- Senior review checklist: include eager loading plan in ADR.

### T15 - Caching Strategy
- Scope: cache expensive dashboard sections with explicit invalidation.
- Acceptance: cache keys include organization/user scope and bust correctly.
- Tests: cache hit/miss behavior tests.
- Senior review checklist: correctness first, then speed.

### T16 - Full Audit Log
- Scope: immutable audit records for security-sensitive actions (auth, role changes, deletes).
- Acceptance: actor, target, action, and metadata captured consistently.
- Tests: request tests for audit creation and tamper resistance.
- Senior review checklist: append-only semantics and retention policy.

### T17 - Soft Deletion Strategy
- Scope: add recoverable soft delete for projects/tasks/comments.
- Acceptance: deleted records hidden from default scopes but recoverable.
- Tests: model and integration tests for visibility and restoration.
- Senior review checklist: avoid accidental default-scope bugs.

### T18 - Multi-DB Read Replica Readiness
- Scope: prepare query paths for follower reads and primary writes.
- Acceptance: read-only queries routed safely; writes stay on primary.
- Tests: integration tests with role switching in test env.
- Senior review checklist: transaction safety and replica lag assumptions.

### T19 - Production Observability
- Scope: structured logging, request IDs, and error classification dashboard.
- Acceptance: key flows emit logs with actor/org/project/task context.
- Tests: log payload tests for critical actions.
- Senior review checklist: PII filtering and useful correlation IDs.

### T20 - Deployment Hardening
- Scope: define release checklist, rollback plan, migration safety checks, and smoke tests.
- Acceptance: documented runbook and one-command preflight check.
- Tests: CI includes migration + smoke test stages.
- Senior review checklist: reversible migrations and failure-domain clarity.

## Definition of Done (All Tickets)

- All relevant tests added and passing.
- `bin/check` passes locally.
- ADR entry added for significant design decisions.
- PR includes a short risk section and rollback notes.
