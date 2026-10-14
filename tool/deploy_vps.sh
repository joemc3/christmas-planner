#!/usr/bin/env bash
# Deploys the app and its Supabase stack to the VPS. See deploy/vps/README.md.
#
#   tool/deploy_vps.sh            build, sync, compose up
#   tool/deploy_vps.sh --init     also generate /opt/xmas/.env (refuses if it exists)
#
# Needs: ssh access as joemc3@2524.info, fvm, rsync, python3.
set -euo pipefail

HOST=joemc3@2524.info
REMOTE=/opt/xmas
cd "$(dirname "$0")/.."

if [[ "${1:-}" == "--init" ]]; then
  if ssh "$HOST" "test -f $REMOTE/.env"; then
    echo "$REMOTE/.env already exists on the VPS; not overwriting." >&2
    exit 1
  fi
  python3 - <<'EOF' | ssh "$HOST" "umask 077 && cat > $REMOTE/.env"
import json, time, base64, hmac, hashlib, secrets, re
def b64(b): return base64.urlsafe_b64encode(b).rstrip(b'=').decode()
def jwt(payload, secret):
    h = b64(json.dumps({"alg": "HS256", "typ": "JWT"}, separators=(',', ':')).encode())
    p = b64(json.dumps(payload, separators=(',', ':')).encode())
    return f"{h}.{p}." + b64(hmac.new(secret.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest())
now = int(time.time()); exp = now + 10 * 365 * 24 * 3600
secret = secrets.token_urlsafe(48)
values = {
    'POSTGRES_PASSWORD': secrets.token_hex(24),
    'JWT_SECRET': secret,
    'ANON_KEY': jwt({"iss": "supabase", "ref": "xmas", "role": "anon", "iat": now, "exp": exp}, secret),
    'SERVICE_ROLE_KEY': jwt({"iss": "supabase", "ref": "xmas", "role": "service_role", "iat": now, "exp": exp}, secret),
    'SECRET_KEY_BASE': secrets.token_hex(32),
    'REALTIME_DB_ENC_KEY': secrets.token_hex(8),
}
template = open('deploy/vps/.env.example').read()
out = []
for line in template.splitlines():
    m = re.match(r'^([A-Z_]+)=$', line)
    out.append(f"{m.group(1)}={values[m.group(1)]}" if m and m.group(1) in values else line)
print("\n".join(out))
EOF
  echo "Wrote $REMOTE/.env"
fi

echo "Reading API URL and anon key from the VPS .env"
API_URL=$(ssh "$HOST" "grep '^API_EXTERNAL_URL=' $REMOTE/.env | cut -d= -f2-")
ANON_KEY=$(ssh "$HOST" "grep '^ANON_KEY=' $REMOTE/.env | cut -d= -f2-")
[[ -n "$API_URL" && -n "$ANON_KEY" ]] || { echo "Missing API_EXTERNAL_URL or ANON_KEY in $REMOTE/.env" >&2; exit 1; }

echo "Building the web bundle for $API_URL"
fvm flutter build web --release --no-web-resources-cdn \
  --dart-define=SUPABASE_URL="$API_URL" \
  --dart-define=SUPABASE_ANON_KEY="$ANON_KEY"

echo "Syncing the stack definition and the bundle"
rsync -az --delete --exclude .env --exclude site --exclude 'volumes/db/data' deploy/vps/ "$HOST:$REMOTE/"
rsync -az nginx.conf "$HOST:$REMOTE/nginx.conf"
rsync -az --delete build/web/ "$HOST:$REMOTE/site/"

echo "Starting the stack"
ssh "$HOST" "cd $REMOTE && docker compose up -d --remove-orphans && docker compose restart app && docker compose ps"
echo "Done. Apply new migrations with: supabase db push --db-url through an SSH tunnel (README step 3)."
