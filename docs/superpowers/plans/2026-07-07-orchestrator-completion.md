# dLearning Orchestrator Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Version-control the orchestrator, add the §11 GitHub Copilot compatibility layer, sync the docs, verify skill routing, and push to the user's GitHub remote.

**Architecture:** The orchestrator already exists (skills, routing, Makefile, docs). This plan adds only the missing pieces from `HOW-TO-BUILD-AN-ORCHESTRATOR-en.md`: a git history, a 4-file `.github/` layer of *thin pointers* to `.claude/skills/`, doc-tree updates, and a static routing check with trigger patches. Spec: `docs/superpowers/specs/2026-07-07-orchestrator-completion-design.md`.

**Tech Stack:** git, zsh, Markdown. No product code, no build system, no test framework — verification is via shell commands with expected output.

## Global Constraints

- Working directory for every command: `/Users/dat.nguyenmanh/Desktop/dat/my-git/dlearning/dlearning-orchestrator`.
- Commits are authored as `datnm555 <mydatng@gmail.com>` (per-repo git config, set in Task 1).
- Every commit message ends with the trailer line: `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- The user's GitHub token (a `ghp_…` string provided in-session) must NEVER appear in any file in the repo — only in `.git/config` (which git does not commit). This plan intentionally redacts it.
- `.github/` files are thin pointers — never copy skill content into them.
- Never force-push.

---

### Task 1: Git init, identity, .gitignore, initial commit

**Files:**
- Modify: `.gitignore`
- Create: `.git/` (via `git init`)

**Interfaces:**
- Produces: a git repo on branch `main` with one commit containing the current orchestrator (later tasks commit on top of it).

- [ ] **Step 1: Initialize the repo and set identity**

```bash
cd /Users/dat.nguyenmanh/Desktop/dat/my-git/dlearning/dlearning-orchestrator
git init -b main
git config user.name "datnm555"
git config user.email "mydatng@gmail.com"
git config user.name && git config user.email
```

Expected: `Initialized empty Git repository …`, then `datnm555` and `mydatng@gmail.com`.

- [ ] **Step 2: Extend .gitignore**

Append two entries so the final file reads exactly:

```gitignore
# Reference clones (pulled via `make clone-all`) — real code lives in their own repos
/dlearning-be/
/dlearning-web/

# Personal / OS noise
.claude/settings.local.json
.DS_Store
.superpowers/
```

- [ ] **Step 3: Stage everything and verify what's staged**

```bash
git add -A
git status --short
```

Expected: all `A ` lines. MUST include `CLAUDE.md`, `AGENTS.md`, `.agents/skills` (symlink), `.claude/skills/*/SKILL.md` (3 files), `agent_docs/skill-routing.md`, `Makefile`, `README.md`, `deploy/*`, both `HOW-TO-BUILD-AN-ORCHESTRATOR*.md`, `docs/superpowers/specs/2026-07-07-orchestrator-completion-design.md`, `docs/superpowers/plans/2026-07-07-orchestrator-completion.md`, `.gitignore`, `.mcp.json`. MUST NOT include `.claude/settings.local.json`, `dlearning-be/`, `dlearning-web/`.

- [ ] **Step 4: Verify no secret is staged**

```bash
git grep -E "ghp_[A-Za-z0-9]{30,}" --cached || echo "CLEAN"
```

Expected: `CLEAN` (the redacted `ghp_…` mentions in the docs do not match the full-token pattern).

- [ ] **Step 5: Commit**

```bash
git commit -m "chore: initial orchestrator import (skills, routing, docs, deploy)

Skills (dlearning-be, dlearning-web, dlearning-platform), routing tables,
Makefile, AGENTS.md backbone, deploy compose, and the orchestrator guide.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git log --oneline --format='%h %an <%ae> %s'
```

Expected: one commit line showing author `datnm555 <mydatng@gmail.com>`.

---

### Task 2: Copilot layer — `.github/` (4 files, thin pointers)

**Files:**
- Create: `.github/copilot-instructions.md`
- Create: `.github/instructions/platform-routing.instructions.md`
- Create: `.github/instructions/dlearning-be.instructions.md`
- Create: `.github/instructions/dlearning-web.instructions.md`

**Interfaces:**
- Consumes: the three existing skills at `.claude/skills/<svc>/SKILL.md` (pointed to, never copied).
- Produces: the four files above; Task 3 commits them together with the doc sync.

Note: this task has no commit step by design — the spec defines commit 2 as "Copilot layer + doc sync", which lands at the end of Task 3.

- [ ] **Step 1: Create `.github/copilot-instructions.md`** with exactly:

````markdown
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
````

- [ ] **Step 2: Create `.github/instructions/platform-routing.instructions.md`** with exactly:

```markdown
---
applyTo: "**"
---
# dLearning skill routing (condensed)

Load the matching skill BEFORE answering; full tables live in
`agent_docs/skill-routing.md`. System map: `.claude/skills/dlearning-platform/SKILL.md`.

| Topic | Open |
|-------|------|
| auth / JWT / PBKDF2, catalog menu, lesson APIs (alphabet, colors, animals, counting), resx i18n, EF Core / PostgreSQL, CQRS / vertical slice | `.claude/skills/dlearning-be/SKILL.md` |
| React pages / components, app shell (sidebar, header), i18n JSON / LanguageSwitcher, vite proxy / HttpClient, AuthProvider / TokenStorage | `.claude/skills/dlearning-web/SKILL.md` |
| whole system, how the repos fit, run everything, docker deploy, onboarding | `.claude/skills/dlearning-platform/SKILL.md` |

| Directory | Open |
|-----------|------|
| `dlearning-be/**` | `.claude/skills/dlearning-be/SKILL.md` |
| `dlearning-web/**` | `.claude/skills/dlearning-web/SKILL.md` |
| repo root / cross-repo | `.claude/skills/dlearning-platform/SKILL.md` |
```

- [ ] **Step 3: Create `.github/instructions/dlearning-be.instructions.md`** with exactly:

```markdown
---
applyTo: "dlearning-be/**"
---
# Working in: `dlearning-be/` — dLearning backend (.NET 10, PostgreSQL)

**Authoritative instructions:** open and follow `.claude/skills/dlearning-be/SKILL.md`.
That skill is the single source of truth; this file is a thin pointer.

**Summary:**
- Build/test: `dotnet build` · `dotnet test` (Integration tests need Docker). Run:
  `docker compose up -d && dotnet run --project src/Web.Api` → API on :5113.
- Clean Architecture, compiler-enforced: `SharedKernel → Domain → Application →
  Infrastructure → Web.Api`; one vertical slice per feature (CQRS handlers + Result pattern).
- i18n: the DB stores language-neutral codes only; display names come from `.resx` in
  Web.Api (`?lang=` then `Accept-Language`). Exception: alphabet letter names live in the DB.
- Commit in the real repo (`github.com/datnm555/dlearning-be`), never in a reference clone.
```

- [ ] **Step 4: Create `.github/instructions/dlearning-web.instructions.md`** with exactly:

```markdown
---
applyTo: "dlearning-web/**"
---
# Working in: `dlearning-web/` — dLearning frontend (Vite + React 19 + TypeScript)

**Authoritative instructions:** open and follow `.claude/skills/dlearning-web/SKILL.md`.
That skill is the single source of truth; this file is a thin pointer.

**Summary:**
- Dev: `npm run dev` → SPA on :5173, proxies `/api` → `:5113`. Test: `npm test && npm run build`
  (Vitest + type-check).
- Clean-architecture layers: `presentation → application → domain`; `infrastructure → domain`;
  `di/container.ts` composes. App shell = left sidebar (API-driven menu) + header + body Outlet.
- i18n JSON covers static UI chrome only (en/vi, default vi); all lesson data comes from the
  API with the `lang` param — never hardcode lesson data in the FE.
- Commit in the real repo (`github.com/datnm555/dlearning-web`), never in a reference clone.
```

- [ ] **Step 5: Verify the layer**

```bash
ls .github .github/instructions
head -3 .github/instructions/*.instructions.md
```

Expected: `copilot-instructions.md` + `instructions/` with 3 files; each instructions file starts with `---` / `applyTo: …` / `---`.

---

### Task 3: Doc sync (README, CLAUDE.md, AGENTS.md) + commit 2

**Files:**
- Modify: `README.md:15-17`
- Modify: `CLAUDE.md:31-33`
- Modify: `AGENTS.md:9-10`

**Interfaces:**
- Consumes: the `.github/` files from Task 2 (must exist before the commit step).
- Produces: commit 2 ("Copilot layer + doc sync") that Task 5 pushes.

- [ ] **Step 1: README.md — add `.github/` to the tree.** Replace:

```
├── AGENTS.md                  # shared backbone for Codex / Copilot / Cursor / …
├── .agents/skills → .claude/skills   # symlink so Codex sees the same skill source
```

with:

```
├── AGENTS.md                  # shared backbone for Codex / Copilot / Cursor / …
├── .agents/skills → .claude/skills   # symlink so Codex sees the same skill source
├── .github/                   # Copilot layer: copilot-instructions.md + instructions/* (thin pointers)
```

- [ ] **Step 2: CLAUDE.md — extend the multi-tool sentence.** Replace:

```
Full topic→skill and directory→skill tables: `agent_docs/skill-routing.md` (referenced, not
auto-loaded). Skills are the single source of truth; `AGENTS.md` is the multi-tool backbone
(Codex sees the same skills via the `.agents/skills` symlink).
```

with:

```
Full topic→skill and directory→skill tables: `agent_docs/skill-routing.md` (referenced, not
auto-loaded). Skills are the single source of truth; `AGENTS.md` is the multi-tool backbone
(Codex sees the same skills via the `.agents/skills` symlink; Copilot reads
`.github/copilot-instructions.md` + `.github/instructions/*` — thin pointers to the skills).
```

- [ ] **Step 3: AGENTS.md — add the Copilot bullet.** Replace:

```
- **Skills**: `.claude/skills/<service>/SKILL.md` (also exposed at `.agents/skills/` via symlink for Codex).
- **Routing**: `agent_docs/skill-routing.md` (topic→skill and directory→skill).
```

with:

```
- **Skills**: `.claude/skills/<service>/SKILL.md` (also exposed at `.agents/skills/` via symlink for Codex).
- **Routing**: `agent_docs/skill-routing.md` (topic→skill and directory→skill).
- **Copilot layer**: `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md` — thin pointers to the skills above, never content copies.
```

- [ ] **Step 4: Verify and commit**

```bash
grep -n "\.github" README.md CLAUDE.md AGENTS.md
git add .github README.md CLAUDE.md AGENTS.md
git commit -m "feat: add GitHub Copilot compatibility layer (thin pointers)

copilot-instructions.md (global rules), platform-routing (applyTo \"**\"),
and per-service instruction pointers to .claude/skills/. Docs synced.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git log --oneline
```

Expected: `grep` shows ≥1 hit per file; `git log` shows 2 commits.

---

### Task 4: Static routing verification + trigger patches

**Files:**
- Modify: `.claude/skills/dlearning-web/SKILL.md:10-12` (frontmatter description)
- Modify: `.claude/skills/dlearning-platform/SKILL.md:6-8` (frontmatter description)

**Interfaces:**
- Consumes: `agent_docs/skill-routing.md` rows; skill frontmatter descriptions.
- Produces: a HIT/MISS match table (reported to the user) and commit 3 with trigger patches.

- [ ] **Step 1: Run the routing check (write the table down for the final report)**

```bash
cd /Users/dat.nguyenmanh/Desktop/dat/my-git/dlearning/dlearning-orchestrator
check() {
  local skill=$1; shift
  local fm; fm=$(awk '/^---$/{n++; next} n==1' ".claude/skills/$skill/SKILL.md")
  for p in "$@"; do
    if printf '%s' "$fm" | grep -qi -- "$p"; then printf 'HIT  %-20s %s\n' "$skill" "$p"
    else printf 'MISS %-20s %s\n' "$skill" "$p"; fi
  done
}
check dlearning-be login register JWT PBKDF2 categories products catalog "alphabet API" colors animals counting resx localization "EF migration" PostgreSQL CQRS "vertical slice" NetArchTest
check dlearning-web React "app shell" sidebar menu "login page" "alphabet page" "colors page" "animals page" "counting page" LanguageSwitcher useI18n AuthProvider TokenStorage "vite proxy" HttpClient lesson cards "detail modal"
check dlearning-platform "whole system" "run everything" "end to end" onboarding "how do the repos fit" "docker deploy"
```

Expected: all HIT except `MISS dlearning-web cards`, `MISS dlearning-web detail modal`, `MISS dlearning-platform docker deploy`. (If actual output differs, patch whatever actually missed using the same pattern as Steps 2–3.)

- [ ] **Step 2: Patch `dlearning-web` description.** In `.claude/skills/dlearning-web/SKILL.md`, replace:

```
  "LanguageSwitcher", "useI18n", "AuthProvider", "TokenStorage", "vite proxy", or
  working in the dlearning-web/ directory.
```

with:

```
  "LanguageSwitcher", "useI18n", "AuthProvider", "TokenStorage", "vite proxy",
  "lesson cards", "detail modal", "design fidelity", or working in the
  dlearning-web/ directory.
```

- [ ] **Step 3: Patch `dlearning-platform` description.** In `.claude/skills/dlearning-platform/SKILL.md`, replace:

```
  overview", "how do the repos fit together", "run everything", "end to end",
  "which skill", or any cross-repo / onboarding question about dLearning.
```

with:

```
  overview", "how do the repos fit together", "run everything", "end to end",
  "which skill", "docker deploy", or any cross-repo / onboarding question about
  dLearning.
```

- [ ] **Step 4: Re-run the check from Step 1**

Expected: every line `HIT` (zero `MISS`).

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/dlearning-web/SKILL.md .claude/skills/dlearning-platform/SKILL.md
git commit -m "fix(skills): add missing routing triggers found by static check

lesson cards / detail modal / design fidelity -> dlearning-web,
docker deploy -> dlearning-platform.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

Expected: commit 3 created. (If Step 1 unexpectedly showed zero misses, skip Steps 2–5.)

---

### Task 5: Remote, push, final verification

**Files:**
- Modify: `.git/config` (remote only — never committed)

**Interfaces:**
- Consumes: the user-provided remote URL `https://ghp_<REDACTED>@github.com/datnm555/dlearning-orchestrator.git` (full value is in session context — do NOT write it into any repo file).

- [ ] **Step 1: Add the remote and fetch**

```bash
git remote add origin "https://ghp_<REDACTED>@github.com/datnm555/dlearning-orchestrator.git"  # use the real URL from session context
git fetch origin
git ls-remote --heads origin
```

Expected: fetch succeeds. If `ls-remote` prints a `refs/heads/main` line, the remote has commits → run `git rebase origin/main` (resolve trivially if GitHub added a README; keep ours on conflict in README.md is NOT automatic — inspect and merge both contents by hand). If it prints nothing, the remote is empty → continue.

- [ ] **Step 2: Push**

```bash
git push -u origin main
git status
```

Expected: `main -> main` push succeeds (no `--force`); status shows `Your branch is up to date with 'origin/main'` and a clean tree.

- [ ] **Step 3: Final acceptance checks (mirror the spec)**

```bash
git log --oneline | wc -l                              # expect >= 2
git grep -E "ghp_[A-Za-z0-9]{30,}" HEAD || echo CLEAN  # expect CLEAN
ls .github/instructions | wc -l                        # expect 3
grep -c "applyTo" .github/instructions/*.instructions.md  # expect 1 per file
```

Expected: all four checks pass. Report the routing match table from Task 4 plus 5 manual dynamic-test prompts to the user: "why does login return 401" (→ dlearning-be), "collapse the sidebar" (→ dlearning-web), "make the lesson cards bigger" (→ dlearning-web), "spin up the full stack" (→ dlearning-platform), "add a 12th color" (→ dlearning-be).
