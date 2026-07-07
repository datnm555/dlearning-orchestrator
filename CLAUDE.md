# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The **dLearning orchestrator**: skills + routing for AI agents, **no product code**. The real
repos live as siblings of this directory:

```
dlearning/
├── dlearning-be/    # .NET 10 API (github.com/datnm555/dlearning-be) — real repo, commit here
├── dlearning-web/   # Vite React TS SPA (github.com/datnm555/dlearning-web) — real repo, commit here
└── orchestrator/    # this repo: skills, routing, full-stack deploy compose
```

**Golden rule:** edit and commit code in the sibling repos, never in copies inside the
orchestrator. Commits are authored as `datnm555 <mydatng@gmail.com>` (set per-repo).

## The one rule

Before answering anything about a dLearning service, **load its skill first** — do not answer
from general knowledge when a skill exists.

| Skill | Load it when… |
|-------|---------------|
| `dlearning-be` | backend / API / auth / JWT / EF / lessons data / resx i18n, or in `dlearning-be/` |
| `dlearning-web` | frontend / React / app shell / pages / i18n JSON / proxy, or in `dlearning-web/` |
| `dlearning-platform` | cross-repo, onboarding, "how it all fits", run-everything |

Full topic→skill and directory→skill tables: `agent_docs/skill-routing.md` (referenced, not
auto-loaded). Skills are the single source of truth; `AGENTS.md` is the multi-tool backbone
(Codex sees the same skills via the `.agents/skills` symlink).

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

## Big picture

- **Flow:** SPA → `/api` (Vite proxy in dev, nginx in Docker) → API → PostgreSQL. No lesson
  data is hardcoded in the FE.
- **Backend** is clean architecture (`SharedKernel → Domain → Application → Infrastructure →
  Web.Api`, compiler-enforced by ArchitectureTests) with one vertical slice per feature:
  `Users` (register/login → JWT, native PBKDF2), `Catalog` (categories/products menu, public),
  and four JWT lesson slices: `Alphabets` (29 letters), `Colors` (11), `Animals` (12),
  `Counting` (1–10). Reference data is seeded via EF `HasData` migrations.
- **i18n split (en/vi, default vi):** the DB stores only language-neutral codes/structure;
  display names come from `.resx` in Web.Api (`IStringLocalizer`, culture from `?lang=` then
  `Accept-Language`). The FE keeps its own JSON catalog for static UI chrome only and passes
  `lang` to the API. Exception: alphabet letter names are inherently Vietnamese and live in
  the DB.
- **Frontend** is clean architecture too (`presentation → application → domain`,
  `infrastructure → domain`, `di/container.ts` composes) inside an **app shell**: left sidebar
  (categories → products from the API), header with language switcher + profile top-right,
  lessons render in the body via nested routes.
- The deploy compose (`deploy/docker-compose.yml`) builds `../../dlearning-be` and
  `../../dlearning-web`; only nginx (:8080) is exposed — the single Docker postgres is
  internal.
