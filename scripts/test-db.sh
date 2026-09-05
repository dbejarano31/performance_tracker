#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for command in docker npx; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$command" >&2
    exit 1
  }
done

# Database tests deliberately exclude Auth and all HTTP services. They do not
# need live OAuth credentials, and migrations remain the sole schema source.
EXCLUDED_SERVICES="gotrue,realtime,storage-api,imgproxy,kong,mailpit,postgrest,postgres-meta,studio,edge-runtime,logflare,vector,supavisor"

SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID="test-client-id" \
SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET="test-client-secret" \
  npx --yes supabase@2.116.0 start \
    --workdir "$ROOT_DIR" \
    --exclude "$EXCLUDED_SERVICES"

DB_CONTAINER="$(docker ps -q \
  --filter label=com.supabase.cli.project=performance_tracker \
  --filter name=supabase_db_)"

if [[ -z "$DB_CONTAINER" ]]; then
  printf 'Could not identify the local Supabase database container.\n' >&2
  exit 1
fi

shopt -s nullglob
TEST_FILES=("$ROOT_DIR"/supabase/tests/database/*.test.sql)
if (( ${#TEST_FILES[@]} == 0 )); then
  printf 'No database tests found in %s.\n' "$ROOT_DIR/supabase/tests/database" >&2
  exit 1
fi

for test_file in "${TEST_FILES[@]}"; do
  printf '\nRunning %s\n' "${test_file#"$ROOT_DIR"/}"
  OUTPUT="$(docker exec -i "$DB_CONTAINER" \
    psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres < "$test_file")"
  printf '%s\n' "$OUTPUT"

  if grep -Eq '(^|[[:space:]])not ok[[:space:]]' <<<"$OUTPUT"; then
    printf 'pgTAP assertion failure in %s\n' "$test_file" >&2
    exit 1
  fi
done
