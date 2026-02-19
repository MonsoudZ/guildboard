# Shell-First Rails Workflow

Use this command set as your default loop.

## Setup

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
```

## Daily Loop

```bash
# pick one ticket and write tests first
bin/rails test test/models
bin/rails test test/controllers

# run one focused file while coding
bin/rails test test/controllers/tasks_controller_test.rb

# full gate before push
bin/check

# deploy preflight gate
bin/preflight
```

## Common Generators

```bash
bin/rails generate model FeatureName field:type
bin/rails generate migration AddFieldToModel field:type
bin/rails generate controller Namespace::Things index show new create
```

## Useful Diagnostics

```bash
bin/rails routes
bin/rails db:migrate:status
bin/rails runner "puts User.count"
bin/rails stats
bin/rails runner "DueTaskDigestJob.perform_now"
rake api_tokens:issue EMAIL=alice@guildboard.local NAME=dev
```

## Design Discipline

```bash
# when ticket changes core behavior, add ADR entry
$EDITOR docs/ADRS.md
```

## Release Prep

```bash
# migration safety + smoke tests
bin/preflight
```
