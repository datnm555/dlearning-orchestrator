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
