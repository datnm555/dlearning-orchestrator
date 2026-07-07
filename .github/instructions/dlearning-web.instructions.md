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
