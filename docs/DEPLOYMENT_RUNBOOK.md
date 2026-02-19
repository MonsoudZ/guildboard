# Deployment Runbook

This runbook defines the minimum safe release workflow for GuildBoard.

## Release Checklist

1. Run local quality gates: `bin/check`
2. Run deploy preflight: `bin/preflight`
3. Confirm no pending migrations: `bin/rails db:migrate:status`
4. Review `docs/ADRS.md` for recent behavior changes
5. Confirm CI green on:
   - lint
   - tests
   - migration-safety
   - smoke

## Migration Safety Rules

1. New migrations should be additive where possible.
2. Avoid destructive schema changes in the same deploy as code that still references old shape.
3. Avoid explicitly irreversible migrations unless there is a documented operational exception.
4. `deployment:migration_safety` must pass before deploy.

## Smoke Test Scope

`test/smoke/deployment_smoke_test.rb` currently verifies:

1. Health endpoint (`/up`) responds `200`.
2. Session sign-in redirects and dashboard renders.
3. API rejects unauthorized requests.

## Rollback Plan

1. Roll back app code to previous release artifact.
2. If migration was additive and safe, keep migrated schema and redeploy previous app code.
3. If a migration introduced incompatible behavior:
   - Stop rollout.
   - Deploy rollback migration (or emergency forward-fix migration).
   - Redeploy previous stable app version.
4. Validate rollback with smoke checks and audit/observability review:
   - `/up`
   - dashboard sign-in flow
   - `/observability/errors`

## Failure Domains to Watch

1. Authentication/session flows (`SessionsController`, `Authentication` concern)
2. Core write paths (`Projects::`, `Tasks::`, `TaskComments::` services)
3. DB role routing (`DatabaseRole`) behavior under replica lag assumptions
4. Error event volume growth (`error_events` table retention policy)
