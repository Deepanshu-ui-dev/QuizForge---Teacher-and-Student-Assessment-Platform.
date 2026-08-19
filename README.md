# QuizForge — Teacher and Student Assessment Platform

A quiz platform with a **Node.js API** and a **Flutter mobile app**. Teachers create quizzes and questions; students join, take timed attempts, and see server-graded results.

## Repository layout

```
QuizForge/
├── Backend/              # Express + Prisma REST API (port 5000)
├── Frontend/             # Flutter app (Teacher / Student roles)
├── docker-compose.yml    # Postgres, Redis, RabbitMQ, API
└── README.md             # You are here
```

| Folder | What it does |
|--------|----------------|
| `Backend/` | Auth (JWT), quizzes, questions, attempts, results. Uses Postgres, Redis, RabbitMQ. |
| `Frontend/` | Flutter UI — onboarding, auth, teacher dashboard, student quiz flow. |

## Quick start

### 1. Backend (Docker — recommended)

```bash
cp Backend/.env.example Backend/.env
# Edit Backend/.env — set POSTGRES_PASSWORD and JWT_SECRET

docker compose up -d
```

API: [http://localhost:5000](http://localhost:5000)  
Health: [http://localhost:5000/health](http://localhost:5000/health)

### 2. Backend (local Node, infra in Docker)

```bash
docker compose up -d postgres redis rabbitmq

cp Backend/.env.local.example Backend/.env.local
# Edit Backend/.env.local — match POSTGRES_PASSWORD from Backend/.env

cd Backend
npm install
npx prisma migrate deploy
npm run dev
```

### 3. Flutter app

```bash
cd Frontend
flutter create .          # first time only — generates platform folders
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:5000
```

Use `http://10.0.2.2:5000` on Android emulator. See [Frontend/README.md](Frontend/README.md) for device-specific URLs.

## Environment variables

| File | When to use |
|------|-------------|
| `Backend/.env.example` | Template for Docker Compose (`cp` → `.env`) |
| `Backend/.env.local.example` | Template for host-side `npm run dev` (`cp` → `.env.local`) |
| `Frontend/env.example` | Reference for `API_BASE_URL` dart-define |

Never commit `.env` or `.env.local` — they are gitignored.

## Tech stack

**Backend:** Node.js, Express, Prisma, PostgreSQL, Redis, RabbitMQ, JWT  
**Frontend:** Flutter, Riverpod, Dio, go_router, flutter_secure_storage

## Testing the full flow

1. Start the backend (Docker or local).
2. Run the Flutter app and register a **Student** account.
3. To try **Teacher** features: set a user's role to `ADMIN` in the database, then log out and back in.
4. As Teacher: create a quiz, add questions, share the Quiz ID.
5. As Student: join by ID, complete the quiz, view the result.

## Documentation

- [Backend/README.md](Backend/README.md) — API setup, env, endpoints overview
- [Frontend/README.md](Frontend/README.md) — Flutter setup, architecture, known limits

## Known limitations

- Registration always creates a `USER` (student) role — teachers require a manual DB role change to `ADMIN`.
- Some result/history endpoints are not fully implemented on the backend; the app shows honest empty/error states instead of fake data.
- Quizzes cannot be deleted from the app (no delete endpoint).
