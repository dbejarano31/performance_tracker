# Performance Tracker

A privacy-first performance tracker for a small, invite-only user base.

## Current baseline

This branch establishes the versioned local foundation:

- Supabase configuration and database infrastructure-as-code
- Google OAuth provider configuration with credentials resolved from Infisical at runtime
- invite allow-list and owner-isolated user profiles enforced with Row Level Security
- pgTAP database tests and a CI workflow
- a minimal TypeScript/Vite application shell and auth callback routing utility

It does **not** yet implement the end-user product experience, provider connections, health-data ingestion, or browser sign-in UI.

## Repository source of truth

- `supabase/config.toml` — local service/auth configuration, with no credential values
- `supabase/migrations/` — database schema, functions, grants, and RLS policies
- `supabase/tests/database/` — database acceptance tests
- `scripts/start-local.sh` — starts the full local stack with runtime secrets from Infisical
- `scripts/test-db.sh` — tests a database-only local stack without OAuth secrets

See [local development documentation](docs/local-development.md) for setup, checks, local reset, and deployment rules. The [browser authentication test plan](docs/browser-authentication-test-plan.md) defines tomorrow's live OAuth acceptance session.

## Quick start

```bash
cp .env.example .env
# Set only INFISICAL_CLIENT_ID and INFISICAL_CLIENT_SECRET in .env
./scripts/start-local.sh
npm ci
npm run dev
```

## Verify

```bash
npm test
npm run typecheck
npm run build
./scripts/test-db.sh
```
