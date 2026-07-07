---
name: dlearning-be
description: Use this skill when working with the dLearning backend (dlearning-be/).
  Covers building, running and testing the .NET 10 Clean Architecture + DDD + CQRS +
  Vertical Slice API, the Users slice (register/login, PBKDF2 hashing, JWT), the
  Catalog slice (categories/products menu), the lesson slices (Alphabets 29 letters,
  Colors, Animals, Counting 1-10), resx en/vi localization, EF Core 10 + PostgreSQL,
  and the NetArchTest dependency rule. Triggers include "dlearning backend",
  "dlearning-be", "dlearning API", "login API", "register", "JWT", "alphabet API",
  "categories", "products", "colors API", "animals API", "counting", "resx",
  "localization", "vertical slice", "EF migration", "PBKDF2", or working in the
  dlearning-be/ directory.
---

# dLearning Backend Skill

The dLearning REST API: authentication (register/login → JWT), the category/product
menu, and four preschool lessons (alphabet, colors, animals, counting) served in
en/vi. .NET 10, Clean Architecture + DDD + CQRS + Vertical Slice, PostgreSQL.

## Overview

| Property | Value |
|----------|-------|
| Location | `dlearning-be/` (reference clone; dev repo `github.com/datnm555/dlearning-be`) |
| Framework | .NET 10, EF Core 10 + Npgsql |
| Solution | `DLearning.slnx` |
| Entry point | `src/Web.Api` |
| HTTP port | `5113` (profile `http` in `launchSettings.json`) |
| Database | PostgreSQL 17 via `docker-compose.yml` (db `dlearning`, user/pass `postgres/postgres`, port `5432`) |
| Auth | JWT bearer (HS256); PBKDF2-HMAC-SHA256 password hashing (native BCL) |

## Quick Commands

```bash
# From dlearning-be/
docker compose up -d                         # start PostgreSQL
dotnet run --project src/Web.Api             # run API (Development auto-migrates + seeds)
dotnet build DLearning.slnx                  # build all
dotnet test                                  # all: Architecture + Unit + Integration (Integration needs Docker)
dotnet test tests/ArchitectureTests/         # dependency-rule + handler-convention tests
dotnet test tests/Application.UnitTests/     # handler unit tests

# EF migrations — run with a NON-Development env so the app's dev auto-migrate is skipped:
dotnet tool restore
ASPNETCORE_ENVIRONMENT=Production dotnet ef migrations add <Name> --project src/Infrastructure --startup-project src/Web.Api -o Database/Migrations
ASPNETCORE_ENVIRONMENT=Production dotnet ef database update       --project src/Infrastructure --startup-project src/Web.Api
```

Demo account (seeded in the migration): `demo@dlearning.vn` / username `demo` / password `Demo@123`.

## Endpoints

| Method | Route | Auth | Purpose |
|--------|-------|------|---------|
| POST | `/users/register` | anon | `{email,username,displayName,password}` → `200 {id}` / `400` validation / `409` duplicate |
| POST | `/users/login` | anon | `{identifier,password}` (identifier = email OR username) → `200 LoginResponse{token,userId,email,username,displayName}` / `401` |
| GET | `/categories?lang=` | anon | 5 education levels `{code,name,iconKey,displayOrder}` — `name` localized from resx |
| GET | `/categories/{code}/products?lang=` | anon | products of a category `{code,name,iconKey,displayOrder,isAvailable}`; unknown code → `[]` |
| GET | `/alphabet` | **JWT** | 29 letters (names/sounds are Vietnamese, stored in DB) |
| GET | `/colors?lang=` | **JWT** | 11 colors `{code,name,hexValue,exampleWord,exampleEmoji,displayOrder}` |
| GET | `/animals?lang=` | **JWT** | 12 animals `{code,name,emoji,sound,displayOrder}` |
| GET | `/counting?lang=` | **JWT** | numbers 1–10 `{value,word,emoji}` |

**Localization:** cultures `en`/`vi`, default `vi`; culture from `?lang=` then `Accept-Language`
(request localization in `Program.cs`). Display strings live in
`src/Web.Api/Resources/SharedResource.{en,vi}.resx` keyed `Category.<code>`, `Product.<code>`,
`Color.<code>`, `ColorExample.<code>`, `Animal.<code>`, `AnimalSound.<code>`, `Number.<value>`;
endpoints resolve them via `IStringLocalizer<SharedResource>`. The DB stores only
language-neutral structure.

## Solution Structure (dependency rule: inward only)

```
SharedKernel → Domain → Application → Infrastructure → Web.Api
```

- `src/SharedKernel/` — primitives only: `Result`, `Error`/`ErrorType` (incl. `Unauthorized`→401), `Entity`, `AggregateRoot`, `ValueObject`, `IDateTimeProvider`. Zero framework refs.
- `src/Domain/` — one folder per feature: `Users/User` (aggregate + errors + event), and reference entities `Alphabets/AlphabetLetter`, `Catalog/{Category,Product}`, `Colors/Color`, `Animals/Animal`, `Counting/CountingNumber` (init-only props, no behavior, seeded).
- `src/Application/` — CQRS handlers (`internal sealed`), ports: `Abstractions/Authentication/{IPasswordHasher,ITokenProvider}`, `Abstractions/Data/IApplicationDbContext` (DbSets for every entity). Slices: `Users/` (Register/Login commands), `Catalog/` (GetCategories, GetProductsByCategory), `Alphabets|Colors|Animals|Counting/` (one Get query each, ordered, DTO in `Data/`).
- `src/Infrastructure/` — EF `ApplicationDbContext`, `Database/Migrations/`, `Database/MigrationExtensions.ApplyMigrations`, `Authentication/{Pbkdf2PasswordHasher,JwtTokenProvider}`, per-feature `IEntityTypeConfiguration` with static-GUID `HasData` seeds (demo user, 29 letters, 5 categories, 4 products, 11 colors, 12 animals, 10 numbers).
- `src/Web.Api/` — minimal-API endpoints auto-discovered via `IEndpoint` (`Endpoints/<Feature>/`), JWT auth + CORS + request-localization wiring in `Program.cs`, `SharedResource` marker at project root namespace, `Middleware/ResultExtensions.ToHttpResult`.
- `tests/` — `ArchitectureTests` (NetArchTest), `Application.UnitTests` (xUnit + Shouldly + NSubstitute + MockQueryable), `Api.IntegrationTests` (Testcontainers Postgres + `WebApplicationFactory<Program>`).

## Key Rules & Gotchas

- **Central Package Management** — every NuGet version lives in `Directory.Packages.props`; NEVER add `Version=` to a `<PackageReference>`.
- **`TreatWarningsAsErrors` + `AnalysisMode=All` + `EnforceCodeStyleInBuild`** — analyzer/style violations fail the build. File-scoped namespaces, braces always, `I`-prefixed interfaces.
- **Dependency rule is compiler-enforced** by `tests/ArchitectureTests/Layers/LayerTests.cs`. Application may reference `Microsoft.EntityFrameworkCore` but NOT `Microsoft.AspNetCore`/`Microsoft.Extensions.Hosting`; Infrastructure must not reference `Microsoft.AspNetCore.*`. **This is why password hashing is native PBKDF2 (`Rfc2898DeriveBytes`) and NOT `Microsoft.AspNetCore.Identity.PasswordHasher`** — that type's namespace would fail the arch test. JWT token *creation* uses `System.IdentityModel.Tokens.Jwt` (fine); JWT bearer *validation* lives only in Web.Api.
- **Handlers must be `internal sealed`** and implement `ICommand(Handler)`/`IQuery(Handler)` (enforced by ArchitectureTests). Feature folders **plural**, aggregate **singular**.
- **Result pattern** — use cases return `Result`/`Result<T>`; `Error.Type` maps to HTTP in `Web.Api/Middleware/ResultExtensions.cs`. Endpoints end with `result.ToHttpResult(...)`.
- **EF migrations are generated code** — exempted from analyzers via `.editorconfig` `[**/Migrations/*.cs] generated_code = true` (+ IDE0161/CA1861 off). Migrations live in `src/Infrastructure/Database/Migrations/` (use `-o Database/Migrations`).
- **`ToLowerInvariant()` normalizes emails/usernames** — CA1308 is deliberately suppressed in `.editorconfig` (lowercasing is correct for case-insensitive identifiers).
- **Connection string is read LAZILY** inside the `AddDbContext` options factory (`sp.GetRequiredService<IConfiguration>()`), NOT eagerly at registration. This is load-bearing: it lets `WebApplicationFactory` override the connection string so integration tests hit their Testcontainer, not the dev DB. Do not revert to an eager read.
- **Login is intentionally vague on failure** — wrong identifier and wrong password both return `Users.InvalidCredentials` (401), never revealing whether the account exists.
- **Dev auto-migrate**: `Program.cs` runs `app.Services.ApplyMigrations()` only in `Development`. Run `dotnet ef` commands with `ASPNETCORE_ENVIRONMENT=Production` so that block is skipped at design time.
- **`SharedResource` marker MUST stay in the `Web.Api` root namespace** (file `src/Web.Api/SharedResource.cs`). With `ResourcesPath = "Resources"`, putting it in the `Web.Api.Resources` namespace doubles the base name and `IStringLocalizer` silently returns the KEY instead of the translation.
- **Shipping a new lesson slice**: flip its product's `IsAvailable` to `true` in `Catalog/ProductConfiguration`'s seed — EF emits an `UpdateData` in the next migration (its scary "may result in loss of data" warning is expected). Also update the catalog integration test's available-count assertion.

## How to Test

- Unit test handlers with mocked `IApplicationDbContext` (build the mock `DbSet` into a **local variable first**, then `.Returns(it)` — MockQueryable calls `.Returns` internally).
- Integration tests seed comes from the migration (demo user + 29 letters exist in every fresh container).
- Run one test: `dotnet test --filter "FullyQualifiedName~LoginCommandHandlerTests"`.

## Related Skills

- `dlearning-web` — the React frontend that consumes these endpoints via a `/api` proxy.
- `dlearning-platform` — system-wide map (frontend ↔ API ↔ Postgres, ports, run order).

## Reference Files

- `dlearning-be/docs/superpowers/specs/2026-07-02-dlearning-login-alphabet-design.md` — design spec.
- `dlearning-be/docs/superpowers/plans/2026-07-02-dlearning-login-alphabet.md` — full task-by-task implementation plan (canonical build narrative).
