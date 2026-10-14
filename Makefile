# Local gate: everything CI runs, runnable here before a push.
#
#   make check     format + analyze + test + migrations lint (what CI runs)
#   make db        start the local Supabase stack (ports 56321-56329)
#   make run       flutter run -d chrome against the local stack
#   make smoke     release web build + Playwright smoke test + screenshots
#   make db-reset  wipe and re-apply migrations
#   make db-stop   stop the local stack
#
# Supabase ports are moved off the CLI defaults (543xx) so this stack can run
# beside other local Supabase projects on the same machine.
#
# Flutter comes from FVM (.fvmrc pins the version; `fvm install` fetches it).
# Override with FLUTTER=flutter DART=dart to use a global SDK.

FLUTTER ?= fvm flutter
DART ?= fvm dart

SUPABASE_URL ?= http://127.0.0.1:56321
SUPABASE_ANON_KEY ?= eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
DEFINES = --dart-define=SUPABASE_URL=$(SUPABASE_URL) --dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)
SMOKE_PORT ?= 8099
OUT_DIR ?= docs/screenshots

.PHONY: check format analyze test lint-db build db db-stop db-reset run smoke

check: format analyze test lint-db
	@echo "✓ local gate passed (flutter $$($(FLUTTER) --version 2>/dev/null | head -1 | awk '{print $$2}'))"

format:
	$(DART) format --output=none --set-exit-if-changed lib test

analyze:
	$(FLUTTER) analyze --fatal-infos

test:
	$(FLUTTER) test

# Same check as the CI "migrations" job. Needs the stack running (make db).
lint-db:
	supabase db lint --level error

build:
	$(FLUTTER) build web --release --no-web-resources-cdn $(DEFINES)

db:
	supabase start

db-stop:
	supabase stop

db-reset:
	supabase db reset

run:
	$(FLUTTER) run -d chrome $(DEFINES)

tool/e2e/node_modules:
	cd tool/e2e && npm install

# Serves build/web on $(SMOKE_PORT), runs the Playwright smoke test, then
# stops the server. Screenshots land in $(OUT_DIR).
smoke: build tool/e2e/node_modules
	@cd build/web && python3 -m http.server $(SMOKE_PORT) >/dev/null 2>&1 & echo $$! > .smoke-server.pid; \
	sleep 1; \
	cd tool/e2e && APP_URL=http://127.0.0.1:$(SMOKE_PORT) OUT_DIR=$(abspath $(OUT_DIR)) node smoke.mjs; status=$$?; \
	kill $$(cat ../../.smoke-server.pid) 2>/dev/null; rm -f ../../.smoke-server.pid; exit $$status
