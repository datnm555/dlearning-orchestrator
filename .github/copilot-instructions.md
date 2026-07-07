# GitHub Copilot — dLearning Orchestrator (global rules)

This repo is the **dLearning orchestrator**: skills + routing for AI coding agents,
**no product code**. The real repos live as siblings of this directory:

- `../dlearning-be/` — .NET 10 API (github.com/datnm555/dlearning-be) — real repo, commit there
- `../dlearning-web/` — Vite React TS SPA (github.com/datnm555/dlearning-web) — real repo, commit there

Reference clones may also exist inside this repo (`dlearning-be/`, `dlearning-web/`,
via `make clone-all`) — they are read-only; never commit in them.

**Golden rule:** edit and commit code in the real repos, never in copies inside the
orchestrator. Commits are authored as `datnm555 <mydatng@gmail.com>` (set per-repo).

## The one rule

Before answering anything about a dLearning service, **open and follow that service's
skill** — do not answer from general knowledge when a skill exists. Skills in
`.claude/skills/` are the single source of truth.

| Skill (open this file) | Use it when… |
|------------------------|--------------|
| `.claude/skills/dlearning-be/SKILL.md` | backend / API / auth / JWT / EF / lessons data / resx i18n, or in `dlearning-be/` |
| `.claude/skills/dlearning-web/SKILL.md` | frontend / React / app shell / pages / i18n JSON / proxy, or in `dlearning-web/` |
| `.claude/skills/dlearning-platform/SKILL.md` | cross-repo, onboarding, "how it all fits", run-everything |

Full topic→skill and directory→skill tables: `agent_docs/skill-routing.md`.

## Common commands

```bash
# Full stack in Docker (postgres + API + nginx SPA) → http://localhost:8080
cd deploy && docker compose up --build -d          # backend auto-migrates + seeds on start
docker compose down                                # stop (add -v to wipe the DB volume)

# Local dev (run from the sibling repos)
cd ../dlearning-be  && docker compose up -d && dotnet run --project src/Web.Api   # API :5113 + scratch postgres :5432
cd ../dlearning-web && npm run dev                                                # SPA :5173, proxies /api → :5113

# Tests
cd ../dlearning-be  && dotnet test                 # Architecture + Unit + Integration (Integration needs Docker)
cd ../dlearning-web && npm test && npm run build   # Vitest + type-check/build
```

Demo login: `demo@dlearning.vn` (or `demo`) / `Demo@123`.
