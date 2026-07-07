---
name: dlearning-web
description: Use this skill when working with the dLearning frontend / FE
  (dlearning-web/). Covers the Vite + React 19 + TypeScript app with clean-architecture
  layering (domain / application / infrastructure / presentation / di), the app shell
  (left SidebarMenu + AppHeader with profile + body Outlet), i18n (LanguageProvider,
  en/vi JSON, LanguageSwitcher), the login/register screens, the four lesson pages
  (alphabet, colors, animals, counting), auth (AuthProvider/RequireAuth/TokenStorage),
  the HttpClient + /api proxy, and Vitest tests. Triggers include "dlearning frontend",
  "dlearning fe", "dlearning-web", "React app", "app shell", "sidebar", "menu",
  "login page", "alphabet page", "colors page", "animals page", "counting page",
  "LanguageSwitcher", "useI18n", "AuthProvider", "TokenStorage", "vite proxy", or
  working in the dlearning-web/ directory.
---

# dLearning Frontend (Web) Skill

The dLearning single-page app: login/register screens per the design file, then an
app shell (left sidebar menu + header with profile top-right) whose body renders the
four preschool lessons — all data loaded from the API (nothing hardcoded). Vite +
React + TypeScript, clean-architecture layering, en/vi language switching.

## Overview

| Property | Value |
|----------|-------|
| Location | `dlearning-web/` (reference clone; dev repo `github.com/datnm555/dlearning-web`) |
| Framework | Vite 8, React 19, TypeScript 6 |
| Entry point | `src/main.tsx` |
| Dev port | `5173` |
| API access | Vite proxy `/api` → `http://localhost:5113` (strips `/api` prefix) |
| Tests | Vitest (jsdom) |
| Design source | `dLearning Login.dc.html` — fonts Sora + Plus Jakarta Sans, gradient `#4F46E5 → #6D28D9 → #7C3AED` |

## Quick Commands

```bash
# From dlearning-web/
npm install
npm run dev        # http://localhost:5173 (needs the backend on :5113 for real data)
npm run build      # tsc -b && vite build (type-check + production build)
npm test           # vitest run
npm run lint       # oxlint
```

## Clean Architecture Layers

```
presentation → application → domain        (domain/application never import React)
infrastructure → domain
di/ = composition root (the only place infrastructure is wired to application)
```

```
src/
├── domain/
│   ├── models/         User, AuthSession, AlphabetLetter, Category, Product, Color, Animal, CountingNumber
│   └── repositories/   Auth/Alphabet/Catalog/Color/Animal/Counting Repository ports (+ shared `Lang` type)
├── application/
│   └── usecases/       login, register, getAlphabet, getCategories, getProducts, getColors,
│                       getAnimals, getCounting  (factory fns: make<X>(repo), each with a Vitest test)
├── infrastructure/
│   ├── http/           HttpClient.ts (Bearer + 401→onUnauthorized; get(path, query?) builds ?lang=), ApiError.ts
│   ├── storage/        TokenStorage.ts (remember → localStorage, else sessionStorage)
│   └── repositories/   Api<X>Repository per port
├── di/container.ts     new HttpClient(baseUrl:'/api') → repos → use cases (singleton `container`)
├── i18n/               en.json, vi.json — STATIC UI CHROME ONLY (labels, titles); data names come from the API
├── presentation/
│   ├── auth/           AuthContext, AuthProvider, useAuth, RequireAuth
│   ├── i18n/           LanguageContext, LanguageProvider, useI18n (lang persisted at localStorage 'dlearning.lang', default vi)
│   ├── layout/         AppLayout (header + sidebar + <Outlet/>), AppHeader (logo | switcher + profile + logout),
│   │                   SidebarMenu (categories→products from API, expand/fetch, active = route)
│   ├── router.tsx      /login, /register standalone; '/' = RequireAuth+AppLayout with children:
│   │                   index (HomePage), alphabet, colors, animals, counting; * → /
│   ├── components/     BrandPane, TextField, PrimaryButton, LanguageSwitcher, ProductCard,
│   │                   LetterCard/Detail, ColorCard/Detail, AnimalCard/Detail, NumberCard/Detail
│   └── pages/          LoginPage, RegisterPage, HomePage (greeting + hero + lesson cards),
│                       AlphabetPage, ColorsPage, AnimalsPage, CountingPage (body-only, no own header)
├── styles/             global.css (fonts, keyframes, .auth-shell), tokens.ts (brandGradient, letterCovers)
└── main.tsx            LanguageProvider > AuthProvider > RouterProvider
```

APIs consumed: `/users/login|register`, `/categories`, `/categories/{code}/products`,
`/alphabet`, `/colors`, `/animals`, `/counting` (lesson endpoints need the JWT; `lang`
passed as a query param from `useI18n()`).

## Auth Flow & Error Handling

- Login/Register success → `container` use case returns `AuthSession {token,user}` → `useAuth().setSession(session, remember)` persists via `TokenStorage` → navigate `/` (home menu inside the shell).
- `RequireAuth` redirects to `/login` when there's no session.
- Any `401` from the API → `HttpClient` calls `onUnauthorized` → clears session → back to `/login`.
- Register auto-logs-in (calls register then login with the email).
- API errors surface as a red banner; message comes from the backend's `{description}`/ProblemDetails `{detail,title}`, with a Vietnamese fallback.

## Key Rules & Gotchas

- **`erasableSyntaxOnly` is ON** (tsconfig). Do NOT use constructor parameter properties (`constructor(private readonly x)`); declare the field explicitly and assign in the body. This applies to `HttpClient`, `ApiError`, `ApiAuthRepository`, `ApiAlphabetRepository`.
- **Dependency direction is the whole point** — `presentation` imports use cases from `application`; only `di/container.ts` knows the concrete `infrastructure` adapters. Keep `domain`/`application` free of React and of `fetch`/`localStorage`.
- **Use cases are factory functions** `makeLogin(repo)`, `makeRegister(repo)`, `makeGetAlphabet(repo)` returning the callable — easy to unit-test with a fake repository.
- **Backend field casing**: API returns camelCase (`token`, `userId`, `upperCase`, `displayOrder`, …); the DTO interfaces match exactly.
- **Design fidelity** lives in `styles/tokens.ts` + inline styles that mirror `dLearning Login.dc.html`. Letter-card colours rotate through `letterCovers` by index.
- The Google/Facebook buttons on the login screen are **UI-only** (no handler) by design.
- **Lesson pages are body-only** — the shell (`AppLayout`) owns the header, sidebar, language switcher and logout. Do not add per-page headers.
- **Adding a new lesson**: model + port + use case (+test) + `Api<X>Repository` + container wiring + body page + a child route under `/`. `HomePage.openProduct` and the sidebar navigate to `/{product.code}` automatically once the backend marks the product available — name the route after the product code.

## How to Test

- Unit-test use cases with a `vi.fn()`-backed fake repository (`*.test.ts` colocated in `usecases/`).
- `TokenStorage.test.ts` runs under jsdom and asserts local vs session storage by `remember`.
- Run: `npm test`.

## Related Skills

- `dlearning-be` — the .NET API this app calls (endpoints `/users/register`, `/users/login`, `/alphabet`).
- `dlearning-platform` — system-wide map, ports, and end-to-end run order.
