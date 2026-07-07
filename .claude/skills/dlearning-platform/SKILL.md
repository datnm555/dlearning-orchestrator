---
name: dlearning-platform
description: Use this skill for a system-wide, bird's-eye view of the dLearning
  platform — how the React frontend, the .NET API, and PostgreSQL fit together, which
  repo owns what, ports, run order, and which per-service skill to load next. Triggers
  include "dlearning platform", "dlearning system", "whole system", "architecture
  overview", "how do the repos fit together", "run everything", "end to end",
  "which skill", "docker deploy", or any cross-repo / onboarding question about
  dLearning.
---

# dLearning Platform Skill (system map)

dLearning lets preschool students learn the Vietnamese alphabet (A→Z, 29 letters).
Two repos, one product. This skill is the **map**; per-service detail lives in the
service skills.

## System Architecture

```
┌─────────────────────────┐     /api (Vite proxy,        ┌─────────────────────────┐     Npgsql      ┌──────────────┐
│  dlearning-web (SPA)     │     strips /api prefix)      │  dlearning-be (.NET 10)  │  ───────────►   │ PostgreSQL 17 │
│  Vite + React + TS       │  ─────────────────────────► │  Clean Arch + CQRS       │                 │ (docker)      │
│  http://localhost:5173   │     Bearer JWT on /alphabet  │  http://localhost:5113   │                 │ :5432 db=dlearning │
└─────────────────────────┘                              └─────────────────────────┘                 └──────────────┘
        presentation/application/domain/                  SharedKernel→Domain→Application→
        infrastructure/di                                 Infrastructure→Web.Api
```

## Repositories

| Repo | Skill | Stack | Responsibility |
|------|-------|-------|----------------|
| `dlearning-be` | `dlearning-be` | .NET 10, EF Core 10, PostgreSQL | Auth (register/login → JWT) + alphabet data API |
| `dlearning-web` | `dlearning-web` | Vite, React 19, TypeScript | Login/Register screens + alphabet learning UI |

Dev remotes: `github.com/datnm555/dlearning-be`, `github.com/datnm555/dlearning-web`.

## Features

1. **Auth** — register + login by email OR username, PBKDF2-hashed passwords, JWT returned to the SPA.
2. **Catalog menu** — 5 education-level categories (Mầm non → Đại học) with products under Preschool; public endpoints; drives the app-shell sidebar and home cards.
3. **Four preschool lessons** (all JWT, all API→DB, en/vi via `?lang=`): **Alphabet** (29 Vietnamese letters), **Colors** (11 swatches + example objects), **Animals** (12 with sounds: "meo meo"/"meow"), **Counting** (1–10 with emoji quantities). Each renders as a card grid + detail modal in the shell body.
4. **i18n** — default `vi`, switchable to `en` in the header; data names localize via backend `.resx`, FE JSON covers UI chrome only.

## Ports & Infrastructure

| Component | Port | Notes |
|-----------|------|-------|
| Frontend dev server | 5173 | Vite; proxies `/api` → `:5113` |
| Backend API | 5113 | `http` launch profile; Development auto-migrates + seeds |
| PostgreSQL | 5432 | `docker compose up -d` in `dlearning-be/`; db `dlearning`, `postgres/postgres` |

## Auth / Data Flow

1. SPA POSTs `/api/users/login` → proxy → `POST :5113/users/login` → API verifies PBKDF2 hash → returns `{token, user}`.
2. SPA stores the session (`TokenStorage`) and sends `Authorization: Bearer <token>` on `/api/alphabet`.
3. API validates the JWT; returns the 29 letters. A missing/invalid token → `401` → SPA clears session → `/login`.

## Run Everything (end-to-end)

```bash
# Production-style: everything in Docker (single postgres, only :8080 exposed)
cd orchestrator/deploy && docker compose up --build -d   # → http://localhost:8080

# Local dev (hot reload)
cd dlearning-be && docker compose up -d && dotnet run --project src/Web.Api   # API :5113
cd dlearning-web && npm install && npm run dev                                # SPA :5173
# → log in with demo@dlearning.vn / Demo@123
```

## Skill Navigation

- Working in `dlearning-be/`, or on the API / auth / EF / JWT / alphabet data → load **`dlearning-be`**.
- Working in `dlearning-web/`, or on React / pages / components / auth context / proxy → load **`dlearning-web`**.
- Cross-repo, onboarding, "how does it all fit", or run-everything → stay in **`dlearning-platform`**.

## Conventions Shared Across Repos

- Vietnamese-facing UI copy and error messages.
- The 29-letter set is the standard Bộ GD&ĐT preschool alphabet (a ă â b c d đ e ê g h i k l m n o ô ơ p q r s t u ư v x y) — no f/j/w/z.
- Design language: Sora + Plus Jakarta Sans, purple gradient `#4F46E5 → #6D28D9 → #7C3AED`.
