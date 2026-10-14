# Christmas Planner

Flutter web app on Supabase for planning a family Christmas inside a budget. Read these before changing anything:

- `docs/PRD.md`: what the product is. Version 1.1 returns to the original brief; `docs/original/` holds that brief verbatim.
- `docs/superpowers/specs/`: technical design. `docs/superpowers/plans/`: the plan being executed.
- `docs/design/`: the brief we give Claude Design, what it returns, and the reconciliation decisions.
- `README.md`: how to run it.

## Working rules

- The product is the PRD, built to production quality, structured so that the features listed in PRD section 8 can be added as modules later. Those additions are the product owner's call; do not build toward them speculatively. Do not describe the current scope as an MVP or a prototype.
- Design happens in Claude Design, fed from `docs/design/brief/`. What comes back goes in `docs/design/output/`, is reconciled screen by screen in `docs/design/decisions.md`, and only then implemented. Never adopt a design blindly; never change a **verbatim** sentence in the brief.
- Run `make check` before every push. It is exactly what CI runs. CI is a backstop, not where failures should first appear. `make smoke` drives the real app in a browser; run it for any change that touches a screen.

## Git

- `main` is protected: both CI jobs must pass and the branch must be up to date. Nobody commits to it directly.
- At session start, check the branch. If it is `main`, create `<type>/<topic>` (`feat/`, `fix/`, `docs/`, `chore/`) before changing anything.
- A pull request is a unit of review, not a unit of work. Batch everything written in one sitting into one PR: a spec and its plan together, several stages when they fit, one implementation PR for one or more stages. Split only when a piece must land early for a reason you can name. Never split by artifact type.
- Push the branch and open the PR when the work is verified; the owner merges with a merge commit and deletes the branch. Do not merge or force-push.
- Process skills (brainstorming, planning, subagent execution) are tools, not defaults. Use one when its structure earns its cost and say so.

## Toolchain

- Flutter is pinned per project with FVM in `.fvmrc`. Use `fvm flutter` and `fvm dart`, never the global SDK. CI reads the same file. To move to a newer Flutter: `fvm use <version>`, commit `.fvmrc` and `pubspec.lock`.
- Local Supabase runs on ports 56320–56329 (`supabase/config.toml`) so it can sit beside other projects' stacks. `make db` starts it; `.env.example` has the local keys.
- The Obsidian vault at `~/Vault/Projects/Christmas Planner/` holds status and the session log. Run `/handoff` when wrapping up and `/vault-save` when a snag is worth keeping for other projects.
