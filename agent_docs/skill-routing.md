# Skill Routing — dLearning

Three ways a skill is triggered: **(a)** topic/keyword, **(b)** working directory,
**(c)** typing `/<skill-name>`. Always load the matching skill BEFORE answering.

## (a) Topic → Skill

| User says… | Use skill | Examples |
|------------|-----------|----------|
| login, register, JWT, auth, PBKDF2, token | `dlearning-be` | "why does login return 401", "add a claim to the JWT" |
| categories, products, catalog, menu API, isAvailable | `dlearning-be` | "add a category", "flip a product available" |
| alphabet/colors/animals/counting API, seed data, lesson endpoint | `dlearning-be` | "add a 12th color", "reseed the alphabet" |
| resx, localization, IStringLocalizer, ?lang=, en/vi names | `dlearning-be` | "why does the API return the resx key", "add a language" |
| EF migration, DbContext, Npgsql, Postgres schema | `dlearning-be` | "add a migration", "why is the connection string lazy" |
| CQRS, vertical slice, handler, Result pattern, NetArchTest | `dlearning-be` | "add a new command", "architecture test failing" |
| React, page, component, router, AuthProvider, TokenStorage | `dlearning-web` | "style the login page", "guard a route" |
| app shell, sidebar, menu bar, header, profile chip, layout | `dlearning-web` | "move the profile", "collapse the sidebar" |
| i18n JSON, useI18n, LanguageSwitcher, language persist | `dlearning-web` | "add a UI label", "default to English" |
| vite proxy, HttpClient, ApiError, use case, /api | `dlearning-web` | "why is /api 404", "add a getProfile use case" |
| lesson screens, cards, detail modal, design fidelity | `dlearning-web` | "make the cards bigger", "match the design" |
| whole system, how repos fit, run everything, end-to-end, onboarding, docker deploy | `dlearning-platform` | "spin up the full stack", "what talks to what" |

## (b) Working Directory → Skill

| Working directory | Use skill | Notes |
|-------------------|-----------|-------|
| `dlearning-be/` | `dlearning-be` | .NET 10 API |
| `dlearning-be/src/**`, `dlearning-be/tests/**` | `dlearning-be` | |
| `dlearning-web/` | `dlearning-web` | Vite React TS SPA |
| `dlearning-web/src/**` | `dlearning-web` | |
| (repo root / multiple repos / no repo) | `dlearning-platform` | bird's-eye map |

## (c) Manual

Type `/dlearning-be`, `/dlearning-web`, or `/dlearning-platform` to force-load a skill
regardless of the tables above.
