# QuizForge — Backend API

REST API for authentication, quizzes, questions, and quiz attempts. Built with Express, Prisma, and PostgreSQL.

## Setup

### Option A — everything in Docker

```bash
cp .env.example .env
# Set POSTGRES_PASSWORD and JWT_SECRET in .env

docker compose up -d
```

The API listens on **port 5000**.

### Option B — Node on host, databases in Docker

```bash
# From repo root
docker compose up -d postgres redis rabbitmq

cp .env.local.example .env.local
# Set DATABASE_URL password to match POSTGRES_PASSWORD in .env

npm install
npx prisma migrate deploy
npm run dev
```

When running inside Docker, the server uses `.env`. When running on your machine, it loads `.env.local` on top (hostnames point to `localhost` ports).

## Environment

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `JWT_SECRET` | Yes | Secret for signing access tokens |
| `REDIS_URL` | No* | Redis URL for caching |
| `RABBITMQ_URL` | No* | RabbitMQ URL for events |
| `PORT` | No | Default `5000` |
| `JWT_EXPIRES_IN` | No | Default `1d` |
| `POSTGRES_PASSWORD` | Docker | Used by docker-compose postgres service |

\*Required at startup — the server connects to Redis and RabbitMQ on boot.

See `.env.example` (Docker) and `.env.local.example` (local dev).

## Scripts

```bash
npm run dev      # nodemon, hot reload
npm start        # production start
npx prisma studio   # DB browser
npx prisma migrate dev   # create/apply migrations (dev)
```

## Project structure

```
src/
├── app.js                 # Express app, middleware, route mounting
├── server.js              # Boot: Redis, RabbitMQ, listen
├── config/                # prisma, redis, rabbitmq, env validation
├── middleware/            # auth, roles, validation, errors
├── modules/
│   ├── auth/              # register, login, JWT
│   ├── quiz/              # CRUD quizzes
│   ├── question/          # CRUD questions per quiz
│   └── result/            # submit attempts, scores
├── events/                # RabbitMQ publisher & consumer
├── errors/                # Typed HTTP errors
└── validations/           # Zod schemas
```

## API routes

| Prefix | Purpose |
|--------|---------|
| `GET /health` | Health check |
| `/api/auth` | Register, login |
| `/api/quizzes` | List, create, update quizzes |
| `/api/questions` | Add/list/delete questions |
| `/api` | Submit attempts, results |

All protected routes expect `Authorization: Bearer <token>`.

## Roles

| Backend role | App meaning |
|--------------|-------------|
| `USER` | Student |
| `ADMIN` | Teacher |

New registrations get `USER`. Promote to `ADMIN` in the database to enable teacher features.

```sql
UPDATE "User" SET role = 'ADMIN' WHERE email = 'teacher@example.com';
```

## Services (Docker)

| Service | Host port | Purpose |
|---------|-----------|---------|
| backend | 5000 | API |
| postgres | 5433 | Database |
| redis | 6380 | Cache |
| rabbitmq | 5672, 15672 | Message queue (+ management UI) |
