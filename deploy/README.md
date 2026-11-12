# dLearning full-stack deploy (local)

Builds `dlearning-api` + `dlearning-web` (sibling repos) and Postgres 18 into one stack.

```bash
cd dlearning-orchestrator/deploy
echo "DLEARNING_ENCRYPTION_KEY=$(openssl rand -base64 32)" > .env   # once per machine (gitignored)
docker compose up -d --build     # -> http://localhost:8090   (DLEARNING_WEB_PORT to change)
docker compose down              # stop (add -v to wipe the DB volume)
```

- Only the web port is published. nginx serves the SPA and proxies `/api` and `/images` to the `api` service.
- The API runs `ASPNETCORE_ENVIRONMENT=Demo`: applies EF migrations on start and seeds the demo account
  **sam / 1**. Demo signs JWTs with a key generated at start, so a container restart logs everyone out.
- Postgres data lives in the `dlearning_pg18` volume. The old `dlearning_pgdata` volume (Postgres 17,
  dlearning-be era) is not used any more; delete it with `docker volume rm dlearning_pgdata` when no longer needed.
- Requires `dlearning-api/` and `dlearning-web/` cloned next to `dlearning-orchestrator/`.
- Mobile (`kid-learning-mobile`): `flutter run --dart-define=API_BASE_URL=http://localhost:8090`
  (Android emulator: `http://10.0.2.2:8090`).
