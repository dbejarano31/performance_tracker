#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

for command in docker infisical npx; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$command" >&2
    exit 1
  }
done

: "${INFISICAL_CLIENT_ID:?Set INFISICAL_CLIENT_ID in .env or your shell}"
: "${INFISICAL_CLIENT_SECRET:?Set INFISICAL_CLIENT_SECRET in .env or your shell}"
INFISICAL_PROJECT_ID="${INFISICAL_PROJECT_ID:-6ab689bc-79f9-4331-b5f3-c9959b7d8b2a}"
INFISICAL_ENVIRONMENT="${INFISICAL_ENVIRONMENT:-dev}"
INFISICAL_SECRET_PATH="${INFISICAL_SECRET_PATH:-/}"

TOKEN="$(infisical login \
  --method universal-auth \
  --client-id "$INFISICAL_CLIENT_ID" \
  --client-secret "$INFISICAL_CLIENT_SECRET" \
  --plain \
  --silent)"

GOOGLE_CLIENT_ID="$(infisical secrets get GCP-OAUTH-CLIENT-ID \
  --projectId "$INFISICAL_PROJECT_ID" \
  --env "$INFISICAL_ENVIRONMENT" \
  --path "$INFISICAL_SECRET_PATH" \
  --token "$TOKEN" \
  --plain \
  --silent)"
GOOGLE_CLIENT_SECRET="$(infisical secrets get GCP-OAUTH-CLIENT-SECRET \
  --projectId "$INFISICAL_PROJECT_ID" \
  --env "$INFISICAL_ENVIRONMENT" \
  --path "$INFISICAL_SECRET_PATH" \
  --token "$TOKEN" \
  --plain \
  --silent)"

if [[ -z "$GOOGLE_CLIENT_ID" || -z "$GOOGLE_CLIENT_SECRET" ]]; then
  printf 'Google OAuth secrets were not returned by Infisical.\n' >&2
  exit 1
fi

exec env \
  SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" \
  npx --yes supabase@2.116.0 start --workdir "$ROOT_DIR"
