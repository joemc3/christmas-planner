# Deploying to the VPS

The app and a trimmed self-hosted Supabase run on 2524.info behind Pangolin,
following the vault's VPS conventions: containers on the `pangolin` network,
no published host ports, one folder per project under `/opt/`.

```
/opt/xmas/
  docker-compose.yml      this folder, synced by tool/deploy_vps.sh
  nginx.conf              serves the Flutter bundle, SPA fallback, CSP
  volumes/api/kong.template.yml
  volumes/db/*.sql        Supabase init scripts (official, unchanged)
  volumes/db/data/        Postgres data, created on first start
  site/                   the built web bundle (rsynced, not in git)
  .env                    secrets, generated once, never in git
```

Hosts: `https://xmas.2524.info` (the app) and `https://xmas-api.2524.info`
(the API). Both resolve through the wildcard record already in place.

## First deployment

1. Generate `.env` from `.env.example`: a Postgres password, a JWT secret,
   and the anon and service-role JWTs signed with it (HS256, `role` claim,
   ten-year expiry). Keep it at `/opt/xmas/.env`, mode 600.
2. `tool/deploy_vps.sh` builds the web bundle with the API URL and anon key
   from the VPS's `.env`, syncs this folder and the bundle, and runs
   `docker compose up -d`.
3. Migrations: the database listens on `127.0.0.1:54322` on the VPS only.
   Tunnel it and push with the Supabase CLI:
   ```
   ssh -N -L 54399:127.0.0.1:54322 joemc3@2524.info &
   supabase db push --db-url "postgresql://postgres:<POSTGRES_PASSWORD>@127.0.0.1:54399/postgres?sslmode=disable"
   ```
   Auth must be up before the first push (it creates `auth.users`, which the
   schema references), so the script starts the stack first.
4. Pangolin: two resources on the local site. `xmas-api.2524.info` →
   `http://xmas-api:8000`, authentication off (browsers cannot complete
   SSO for API calls; the API requires the anon key and a user token, and
   row security guards the data). `xmas.2524.info` → `http://xmas-app:80`,
   with a pin code if the audience should be limited.

## Later deployments

`tool/deploy_vps.sh` again. New migrations: step 3 again.

## What is not set up

- Email. Sign-up works with confirmation off. Password reset needs SMTP
  (`SMTP_*` in `.env`); until then the reset email is not sent.
- Backups. Add a nightly `pg_dump` per the vault's maintenance note when the
  data matters.

## Moving to a hosted Supabase project later

`supabase link`, `supabase db push`, `pg_dump` the data across, rebuild with
the new URL and anon key, and point `tool/deploy_vps.sh` at it. The app does
not know the difference.
