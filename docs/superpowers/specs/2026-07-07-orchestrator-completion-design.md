# dLearning Orchestrator Completion — Design

**Date:** 2026-07-07
**Status:** Approved
**Guide:** `HOW-TO-BUILD-AN-ORCHESTRATOR-en.md` (§6 step-by-step, §11 multi-tool layer)

## Context

The orchestrator already implements most of the guide: thin `CLAUDE.md`, `AGENTS.md`
backbone, `.agents/skills → .claude/skills` symlink, three skills with trigger-rich
descriptions (`dlearning-be`, `dlearning-web`, `dlearning-platform`),
`agent_docs/skill-routing.md`, an idempotent `Makefile`, onboarding `README.md`, and
the `deploy/` compose.

Three gaps remain against the guide:

1. The orchestrator is **not a git repository** (§6 step 1).
2. The **GitHub Copilot compatibility layer** (`.github/`) is missing (§11).
3. Routing has never been **tested** against real prompts (§6 step 8).

## Goals

- Version-control the orchestrator and push it to the user's existing remote
  `https://github.com/datnm555/dlearning-orchestrator.git`.
- Add the §11 Copilot layer as thin pointers to the existing skills (no content copies).
- Verify keyword routing statically and fix any misses.

## Non-goals (explicitly out of scope, per user decision)

- Slash commands (`.claude/commands/`) and Copilot `prompts/*.prompt.md`.
- Hooks (doc-sync judge, context injection) and `settings.json` hook config.
- `vault/` offline knowledge base.
- `references/` splits inside skills (all three skills are ~115 lines — under the
  threshold where progressive disclosure pays off).

## Design

### 1. Git setup

- `git init -b main` at the orchestrator root.
- Per-repo identity, consistent with the sibling repos:
  `git config user.name "datnm555"`, `git config user.email "mydatng@gmail.com"`.
- Extend `.gitignore` with `.claude/settings.local.json` and `.DS_Store`
  (personal / OS noise; reference clones are already ignored).
- Add `origin` using the remote URL the user provided (credentials live only in
  `.git/config`, which git never commits; the user will rotate the token afterwards).
- `git fetch origin` first: if the remote already has commits (e.g. GitHub-initialized
  README), rebase our commits on top of `origin/main` before pushing; if empty, push
  directly. Never force-push.
- Two commits, then `git push -u origin main`:
  1. **Initial commit** — the orchestrator as it exists today (skills, routing,
     Makefile, docs, deploy, this spec).
  2. **Copilot layer + doc sync** — everything in sections 2–3.

### 2. Copilot layer (`.github/`) — four files, all thin pointers

| File | Frontmatter | Content |
|------|-------------|---------|
| `copilot-instructions.md` | none | `CLAUDE.md` trimmed of Claude-specific mechanics: what the repo is, golden rule (edit/commit in the real sibling repos), the one rule (open `.claude/skills/<svc>/SKILL.md` before answering a service topic), common commands, demo login. |
| `instructions/platform-routing.instructions.md` | `applyTo: "**"` | Condensed topic→skill and directory→skill map; points to `agent_docs/skill-routing.md` (full table) and `.claude/skills/dlearning-platform/SKILL.md` (system map). |
| `instructions/dlearning-be.instructions.md` | `applyTo: "dlearning-be/**"` | One line naming the authoritative source (`.claude/skills/dlearning-be/SKILL.md`) + 3–5 summary lines: build/run/test commands, clean-architecture dependency rule, resx i18n rule, "DB stores codes, resx stores names". |
| `instructions/dlearning-web.instructions.md` | `applyTo: "dlearning-web/**"` | Same pattern: authoritative source (`.claude/skills/dlearning-web/SKILL.md`) + summary: dev/test commands, layer rule (presentation → application → domain; infrastructure → domain), i18n JSON scope, /api proxy. |

Rules carried over from §11: instruction files are pointers, never skill copies; they
never need regenerating when a skill changes; `applyTo` globs mirror the "Working
Directory" column of `skill-routing.md` (they match the reference clones inside the
orchestrator, which is where Copilot would open the code from this workspace).

### 3. Doc sync

- `README.md`: add `.github/` to the "What's here" tree.
- `CLAUDE.md` + `AGENTS.md`: extend the multi-tool sentence to mention the Copilot
  layer alongside the Codex symlink.

### 4. Routing test (static, §6 step 8)

For every row in `agent_docs/skill-routing.md` (a) Topic→Skill table: check that the
row's trigger phrases appear (verbatim or as a clear stem) in the target skill's
frontmatter `description` — that is the text agents actually match on. Produce a
match table (row → skill → hit/miss). Any miss → patch the skill `description`
(source of truth) rather than the routing table.

Dynamic testing (fresh agent sessions per prompt) remains a manual follow-up; the
report will list 5 sample prompts to try by hand.

## Acceptance criteria

- `git log` shows ≥2 commits on `main`; `git push -u origin main` succeeds; no token
  or secret appears in any committed file.
- `.github/` contains exactly the four files above; each instruction file has a valid
  `applyTo` and names its authoritative SKILL.md.
- README/CLAUDE.md/AGENTS.md mention the Copilot layer.
- Routing match table produced; zero unresolved misses.
