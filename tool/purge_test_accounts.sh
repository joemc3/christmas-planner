#!/usr/bin/env bash
# Deletes the throwaway accounts that the smoke test and browser repros
# create (smoke+…, planner+…, repro+…, verify+…@example.com) together with
# everything under them: profile, plans, recipients, gifts, meals and items
# all cascade from auth.users. Real accounts never match the pattern.
#
#   tool/purge_test_accounts.sh                 list matches on the local stack
#   tool/purge_test_accounts.sh --delete        delete them on the local stack
#   tool/purge_test_accounts.sh --vps           list matches on the VPS
#   tool/purge_test_accounts.sh --vps --delete  delete them on the VPS
#
# `make tidy` runs the two --delete forms at the end of a session.
set -euo pipefail

PATTERN='^[a-z]+\+[0-9]+@example\.com$'
LOCAL_CONTAINER=supabase_db_christmas-planner
VPS_HOST=joemc3@2524.info
VPS_DIR=/opt/xmas

target=local
action=list
for arg in "$@"; do
  case "$arg" in
    --vps) target=vps ;;
    --delete) action=delete ;;
    *) echo "usage: $0 [--vps] [--delete]" >&2; exit 2 ;;
  esac
done

run_sql() {
  if [[ $target == vps ]]; then
    ssh -o BatchMode=yes "$VPS_HOST" \
      "cd $VPS_DIR && docker compose exec -T db psql -U postgres -d postgres -v ON_ERROR_STOP=1"
  else
    docker exec -i "$LOCAL_CONTAINER" psql -U postgres -d postgres -v ON_ERROR_STOP=1
  fi
}

if [[ $target == local ]] && ! docker ps --format '{{.Names}}' | grep -qx "$LOCAL_CONTAINER"; then
  echo "Local stack is not running; nothing to purge."
  exit 0
fi

if [[ $action == list ]]; then
  run_sql <<SQL
SELECT email, created_at FROM auth.users WHERE email ~ '$PATTERN' ORDER BY created_at;
SQL
else
  run_sql <<SQL
WITH gone AS (
  DELETE FROM auth.users WHERE email ~ '$PATTERN' RETURNING email
)
SELECT count(*) AS deleted_accounts FROM gone;
SELECT count(*) AS accounts_left FROM auth.users;
SQL
fi
