# dLearning Orchestrator

Central "operating brain" for AI coding agents working on **dLearning** — a Vietnamese
alphabet learning app for preschoolers. This repo holds **skills + routing, not product
code**. Each service is packaged as one skill the agent loads just in time.

> Built with the pattern in `HOW-TO-BUILD-AN-ORCHESTRATOR.md`: one skill per service, a
> thin `CLAUDE.md`, a routing layer, and a platform "map" skill. Multi-tool via `AGENTS.md`.

## What's here

```
orchestrator/
├── CLAUDE.md                  # thin global rules for Claude Code (loaded every session)
├── AGENTS.md                  # shared backbone for Codex / Copilot / Cursor / …
├── .agents/skills → .claude/skills   # symlink so Codex sees the same skill source
├── agent_docs/skill-routing.md       # full topic→skill and directory→skill tables
├── Makefile                   # clone-all / pull-all / status / branches / list / clean
├── .claude/skills/
│   ├── dlearning-be/SKILL.md          # backend service skill
│   ├── dlearning-web/SKILL.md         # frontend service skill
│   └── dlearning-platform/SKILL.md    # bird's-eye system map
└── dlearning-be/ dlearning-web/       # reference clones (via `make clone-all`) — read-only
```

## First 5 minutes

```bash
make clone-all     # pull the two real repos in as read-only reference siblings
make branches      # sanity check
```

Then just work: the agent loads `dlearning-be` when you touch the API, `dlearning-web`
for the SPA, and `dlearning-platform` for the big picture. Force one with
`/dlearning-be`, `/dlearning-web`, or `/dlearning-platform`.

## The two services

| Skill | Repo | Stack | Runs on |
|-------|------|-------|---------|
| `dlearning-be` | `dlearning-be` | .NET 10, EF Core, PostgreSQL | API `:5113`, DB `:5432` |
| `dlearning-web` | `dlearning-web` | Vite, React 19, TypeScript | dev `:5173` (proxies `/api` → `:5113`) |

## Golden rule

Edit code in the **real repo** and commit there. The clones inside this orchestrator are
reference only. Skills in `.claude/skills/` are the single source of truth; other tools
read `AGENTS.md` + the same skills.
