# AGENTS.md — dLearning Orchestrator (shared backbone for all AI agents)

This repo is the **dLearning orchestrator**: skills + routing for AI coding agents,
**no product code**. It is tool-agnostic — Claude Code, Codex, Copilot, Cursor and
similar agents all read from the same source.

## Single source of truth

- **Skills**: `.claude/skills/<service>/SKILL.md` (also exposed at `.agents/skills/` via symlink for Codex).
- **Routing**: `agent_docs/skill-routing.md` (topic→skill and directory→skill).
- **Copilot layer**: `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md` — thin pointers to the skills above, never content copies.
- Keep workflow/pattern changes in the **skill body** so every tool stays in sync — do
  not fork content per tool; each tool only adds a thin adapter (frontmatter / call syntax).

## The contract

- When any doc references `/<skill-name>`, **load that skill before answering or acting**.
- Do not answer a topic that has a skill using general knowledge — load the skill first.
- Real code lives in the sibling repos (`dlearning-be/`, `dlearning-web/`). Commit/PR in
  the **real repo**, never in a reference clone inside this orchestrator.
- In **this** orchestrator repo, agents are pre-authorized to commit and push to `main`
  directly, or to branch and open a PR. Never force-push; secret-scan staged changes
  before committing (`.mcp.json` holds a personal PAT and stays gitignored).

## Skills

| Skill | Scope |
|-------|-------|
| `dlearning-be` | .NET 10 backend API: auth (register/login/JWT, PBKDF2), catalog menu, four lesson slices (alphabet, colors, animals, counting), EF Core + PostgreSQL |
| `dlearning-web` | Vite + React + TS frontend: login/register, app shell, four lesson pages, i18n, clean-architecture layers |
| `dlearning-platform` | system-wide map: how the SPA, API and DB fit; ports; run order; skill navigation |

## Run the stack

```bash
cd ../dlearning-be && docker compose up -d && dotnet run --project src/Web.Api   # API :5113 + Postgres :5432
cd ../dlearning-web && npm install && npm run dev                                 # SPA :5173 (proxies /api → :5113)
```
