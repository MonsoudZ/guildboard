# GuildBoard (Rails Monolith Learning Repo)

GuildBoard is a shell-first Rails monolith designed to train senior-level habits:

- Data integrity first (constraints + validations + indexes)
- Clear authorization boundaries
- Test-driven vertical slices
- Repeatable quality gates from the terminal

## Current Slice

- Sign up and sign in with secure password handling
- Password reset flow with expiring one-time tokens
- Organizations with membership roles
- Role-based organization invitations and acceptance links
- Read-only archived projects
- Task status transition guardrails
- Organization-scoped project/task search
- Immutable activity feed with event logging service
- Service-object write path for core mutations
- Optimistic locking for project/task updates
- Daily due-task digest job with deduping
- User notification preferences (digest + assignment email opt-in/out)
- API v1 for organization projects/tasks with bearer token auth
- Centralized policy layer for authorization decisions
- Query-object layer for search/dashboard data retrieval
- Query-budget integration tests to catch N+1 regressions
- Versioned dashboard caching with explicit invalidation keys
- Immutable audit log stream for security-sensitive actions
- Soft deletion and restore path for projects/tasks/comments
- Read/write DB role routing (`DatabaseRole`) for replica-read readiness
- Structured JSON logs with request correlation and context IDs
- Error classification capture with in-app `/observability/errors` dashboard
- Deployment preflight command with migration safety + smoke checks
- Projects under organizations
- Tasks under projects with assignee/creator constraints
- Task comments with membership authorization checks
- Controller, model, and integration tests

## Stack

- Ruby `4.0.1`
- Rails `8.1.2`
- SQLite (development + test)
- Minitest
- RuboCop + Brakeman + Bundler Audit

## Shell-First Workflow

```bash
# install deps
bundle install

# setup db and boot app
bin/setup --skip-server
bin/rails server

# run all quality gates
bin/check

# run deployment preflight (migration safety + smoke tests)
bin/preflight

# run one test file
bin/rails test test/controllers/tasks_controller_test.rb
```

## Learning Loop (Per Ticket)

1. Clarify scope and acceptance criteria.
2. Write/adjust tests first (or at least in the same commit).
3. Implement with explicit schema and domain boundaries.
4. Run `bin/check`.
5. Record architecture tradeoffs in `docs/ADRS.md`.

Shell command playbook: `docs/SHELL_WORKFLOW.md`

## Project Structure Highlights

- `app/controllers/concerns/authentication.rb`: session auth lifecycle
- `app/models/current.rb`: request-scoped user context
- `app/models/`: domain rules and invariants
- `config/routes.rb`: nested boundaries (`organization -> project -> task -> comments`)
- `test/`: integration + model coverage on critical behavior
- `docs/TICKETS.md`: progressive backlog for your implementation practice

## Seeds

```bash
bin/rails db:seed
```

Seeded test users:
- `alice@guildboard.local` / `password123456`
- `bob@guildboard.local` / `password123456`

## Next Work

Core ticket backlog through `T20` is implemented. Use `docs/TICKETS.md` to review implemented scope and extract your own follow-up tickets (performance, infra, and product depth).

Deployment runbook: `docs/DEPLOYMENT_RUNBOOK.md`
