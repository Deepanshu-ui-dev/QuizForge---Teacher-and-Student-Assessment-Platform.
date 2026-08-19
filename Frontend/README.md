# QuizForge — Flutter App

Mobile and desktop frontend for the QuizForge API in `../Backend`.

## First-time setup

```bash
flutter create .    # generates android/ios/web/linux — keeps lib/ and pubspec.yaml
flutter pub get
```

## Run

Start the backend first (see [../README.md](../README.md)), then:

```bash
# Desktop / iOS simulator / web
flutter run --dart-define=API_BASE_URL=http://localhost:5000

# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000

# Physical device (your machine's LAN IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000
```

If you omit `API_BASE_URL`, the app picks a sensible default per platform (localhost or 10.0.2.2).

See `env.example` for a copy-paste reference.

## Features

**Auth & onboarding** — Splash, carousel, register/login, session restore, role-based routing.

**Teacher (ADMIN role)** — Dashboard, quiz list with search/filter, create/edit quiz, question builder, quiz detail with shareable Quiz ID.

**Student (USER role)** — Dashboard, join quiz by ID, instructions, timed quiz with progress, review & submit, result screen.

**Shared** — Profile, light/dark theme, loading/empty/error states.

## Project structure

```
lib/
├── main.dart              # Entry point
├── app/                   # App widget, router, theme tokens
├── core/
│   ├── network/           # Dio client, endpoints, auth interceptor
│   ├── repositories/      # API data access
│   ├── models/            # Quiz, Question, User, Result
│   ├── providers/         # Shared Riverpod providers
│   ├── errors/            # Typed Failure hierarchy
│   └── storage/           # Secure token storage
├── features/
│   ├── auth/              # Login, register
│   ├── onboarding/        # Splash, carousel, auth choice
│   ├── teacher/           # Teacher screens & shell
│   ├── student/           # Student screens & shell
│   └── profile/           # Profile & logout
└── shared/widgets/        # Reusable UI components
```

## Architecture

- **State:** Riverpod (`AsyncNotifier`, family providers)
- **HTTP:** Single Dio instance with JWT interceptor; 401 clears session
- **Routing:** go_router with auth and role guards
- **Errors:** Repositories throw typed `Failure` objects — widgets never see raw `DioException`
- **Roles:** `core/utils/app_role.dart` maps backend `USER`/`ADMIN` to Student/Teacher

## Backend gaps (honest UI behavior)

The app calls real endpoints and shows empty or "not available" states when the backend lacks support:

| Feature | Status |
|---------|--------|
| Attempt history | Backend method not implemented |
| Teacher analytics / per-quiz results | No endpoints yet |
| Self-register as teacher | All signups are `USER` — promote to `ADMIN` in DB |
| Delete quiz | No delete endpoint |
| Draft/publish, join codes | Not on backend — app shares numeric Quiz ID |

## End-to-end test

1. Backend running on port 5000.
2. Register as student, take a quiz.
3. Promote another account to `ADMIN`, log in as teacher, create quiz + questions, share ID with student.
