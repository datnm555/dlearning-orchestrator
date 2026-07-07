# dLearning full-stack deploy

Builds the two sibling repos and Postgres into one stack.

```bash
cd dlearning-orchestrator/deploy
docker compose up --build        # → http://localhost:8080
docker compose down              # stop (add -v to wipe the DB volume)
```

- Web (nginx) on `:8080`, proxying `/api` → backend `:8080` (in-network).
- Backend runs `ASPNETCORE_ENVIRONMENT=Development`, so it auto-applies EF migrations
  and seeds the demo user, alphabet, categories and products on first start.
- Requires `dlearning-be/` and `dlearning-web/` present as siblings of `orchestrator/`.
