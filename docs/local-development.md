# Local development

## Repository-managed infrastructure

The following files are the source of truth and must be reviewed and committed with application changes:

- `supabase/config.toml`: local Supabase and Google OAuth configuration. It references runtime environment variables; it contains no secret values.
- `supabase/migrations/`: ordered database infrastructure-as-code. Tables, functions, grants, RLS policies, and schema changes belong here.
- `supabase/tests/database/`: pgTAP acceptance tests for database behavior and access isolation.
- `scripts/start-local.sh`: retrieves the Google OAuth credentials at runtime from Infisical and starts the complete local Supabase stack.
- `scripts/test-db.sh`: starts a database-only stack and runs all versioned database tests without requiring Google credentials.

Docker containers, volumes, generated Supabase files, `node_modules`, build output, and `.env` files are local runtime state and are intentionally not committed.

## One-time setup

1. Install Docker, Node.js, and the Infisical CLI.
2. Copy the non-secret contract:

   ```bash
   cp .env.example .env
   ```

3. Set `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` in `.env`. Do not add Google client values to this file.
4. Confirm the Infisical machine identity can read these secrets in the `dev` environment at `/`:
   - `GCP-OAUTH-CLIENT-ID`
   - `GCP-OAUTH-CLIENT-SECRET`
5. Configure the Google OAuth client with:
   - Authorized JavaScript origin: `http://localhost:5173`
   - Authorized redirect URI: `http://127.0.0.1:54321/auth/v1/callback`

## Start the complete local stack

```bash
./scripts/start-local.sh
npm ci
npx playwright install chromium
npm run dev
```

The script keeps Google OAuth values in process environment only. It does not write them to the repository, `.env`, or application source.

## Run checks

```bash
npm test
npm run typecheck
npm run build
npm run test:e2e
./scripts/test-db.sh
```

`test-db.sh` is intentionally independent of Google OAuth. It validates migrations and RLS on a fresh database-only Supabase stack.

## Reset local database state

For a clean local database, stop the stack and remove its data volume:

```bash
npx --yes supabase@2.116.0 stop --workdir . --no-backup
./scripts/start-local.sh
```

This affects only local development data. Migrations recreate the database schema.

## Deployment rule

Never create schema or RLS resources manually in Supabase Studio as the canonical deployment path. Create an ordered migration, add or update pgTAP coverage, and deploy the migration through the target environment's Supabase workflow.
