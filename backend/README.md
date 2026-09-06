# STEMWISE Backend (NestJS + MongoDB)

The authoritative calculation engine and REST API for STEMWISE — a STEM education
financial decision simulator. The backend is the **single source of truth** for all
financial calculations (spec §62): the client may compute locally for instant feedback,
but every stored/returned result is (re)derived here from inputs, using decimal-safe math.

## Stack
NestJS 11 · TypeScript · MongoDB + Mongoose · JWT (access + refresh) · Argon2 ·
class-validator · decimal.js · Helmet · Throttler · Swagger.

## Quick start (Docker — recommended)
From the repo root:
```bash
docker compose up -d --build          # starts mongo + api
DATABASE_URL="mongodb://localhost:27017/stemwise" npm --prefix backend run seed
curl http://localhost:3000/api/v1/health
```
API: `http://localhost:3000/api/v1` · Swagger: `http://localhost:3000/api/docs`
Optional DB browser: `docker compose --profile tools up -d mongo-express` (localhost:8081).

Stop: `docker compose down` (add `-v` to also drop the data volume).

## Quick start (local Node)
```bash
cd backend
cp .env.example .env                   # then edit secrets
npm install
npm run start:dev                      # needs a MongoDB reachable at DATABASE_URL
```

## Tests
```bash
npm test           # 19 unit tests — the calculation engine (incl. spec §89 critical case)
npm run test:e2e   # 14 e2e tests — full app on in-memory Mongo (calc, auth, IDOR/ownership)
```
No Docker or system MongoDB needed for tests; e2e uses `mongodb-memory-server`.

## Calculation engine
Pure, deterministic, decimal-safe (`src/calculations/engine/`):
- `calculation-engine.ts` — cost, funding, loan amortization, career/take-home, debt burden, score, full model, what-if.
- `calculation.config.ts` — configurable planning assumptions (take-home rate, score weights, debt-burden thresholds). These are STEMWISE planning assumptions, not universal rules.
- `recommendation-engine.ts` — ranked, explainable recommendations; never guarantees outcomes.

## API (base `/api/v1`)
| Area | Endpoints |
|------|-----------|
| Health | `GET /health` |
| Auth | `POST /auth/{register,login,refresh,logout,forgot-password}` |
| Profile | `GET/PATCH /profile` (auth) |
| Calculations | `POST /calculations/{cost,funding,loan,career,score,full,what-if}`, `GET /calculations/assumptions` |
| Universities | `GET /universities`, `GET /universities/:id`, `GET /universities/:id/programs` |
| Careers | `GET /careers`, `GET /careers/:slug` |
| Saved plans | `POST/GET /saved-plans`, `GET/PATCH/DELETE /saved-plans/:id` (auth, owner-scoped) |
| Scenarios | `POST/GET /scenarios`, `GET/DELETE /scenarios/:id` (auth, owner-scoped) |
| Notifications | `GET /notifications`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all` (auth) |

All responses use the standard envelope: `{ success, data, message }` (or `{ success, data, meta }` for lists, `{ success:false, statusCode, message, code, errors }` for errors).

## Security
JWT access/refresh (refresh-token hash stored with Argon2, never the token). Argon2
password hashing; `passwordHash` is never returned. RBAC guard for admin. Global
validation with whitelist (blocks mass assignment). Helmet, CORS allowlist, rate limiting.
Every user-owned query is scoped by `userId` — a user can never read another's plans,
scenarios, profile, or notifications (RULE 13 / no IDOR), covered by e2e tests.

## Notes
- Seed data is clearly labeled `"Demo data"` (spec §82) and must not be treated as authoritative.
- Never commit real secrets; `.env` is gitignored.
