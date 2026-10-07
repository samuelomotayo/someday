# Someday

> *Resurrect your abandoned ideas.*

Someday is a Flutter mobile app that helps you revisit old startup ideas and projects you never shipped. Log an idea, describe what you tried and why you stopped, and the AI engine gives you an honest verdict: **Second Chance**, **Sunset Confirmed**, or **Needs More Context**.

Free tier: 3 AI analyses. Upgrade to unlock unlimited.

---

## Table of Contents

- [How It Works](#how-it-works)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [1 — Supabase Setup](#1--supabase-setup)
- [2 — Local Development](#2--local-development)
- [3 — Running the App](#3--running-the-app)
- [4 — Running Tests](#4--running-tests)
- [5 — Deploying the Edge Function](#5--deploying-the-edge-function)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment (TestFlight / Play Store)](#deployment-testflight--play-store)
- [GitHub Secrets Reference](#github-secrets-reference)

---

## How It Works

```
User logs an idea
  → title, description, time period, why they stopped, emotional note
  ↓
Taps "Analyse"
  ↓
Flutter app POSTs to Supabase Edge Function /analyse-idea
  ↓
Edge Function validates JWT + checks server-side usage count
  ↓
Calls Claude (claude-opus-4-7) with a structured prompt
  ↓
Returns one of three verdicts:
  • second_chance      — signals + next steps
  • sunset_confirmed   — reasons to let it go
  • needs_more_context — clarifying questions
  ↓
Verdict displayed on screen, usage count incremented
```

The Anthropic API key **never touches the client**. It lives exclusively as a Supabase Edge Function secret.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.32+ / Dart 3.12+ |
| State management | Riverpod 2 (`riverpod_annotation`) |
| Navigation | go_router 14 |
| Local database | Drift (SQLite) |
| Backend / Auth | Supabase |
| AI engine | Claude via Supabase Edge Function |
| Code generation | build_runner + freezed + drift_dev |
| Testing | flutter_test + mocktail |
| CI/CD | GitHub Actions |
| Deployment | Fastlane (TestFlight + Play Store) |

---

## Project Structure

```
someday/
├── lib/
│   ├── main.dart                        # App entry point + Supabase init
│   ├── core/
│   │   ├── config/app_config.dart       # --dart-define env values
│   │   ├── router/app_router.dart       # go_router config + auth guard
│   │   └── theme/app_theme.dart         # Material theme
│   ├── data/
│   │   ├── local/app_database.dart      # Drift schema (Ideas table)
│   │   └── repositories/
│   │       └── resurrection_repository.dart  # Edge Function HTTP client
│   ├── domain/
│   │   └── entities/
│   │       ├── idea.dart                # Idea domain entity + validation
│   │       └── verdict_type.dart        # VerdictType enum
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/screens/onboarding_screen.dart
│   │   └── ideas/
│   │       ├── data/repositories/usage_repository.dart
│   │       └── presentation/
│   │           ├── providers/           # Riverpod providers (analysis, ideas)
│   │           ├── screens/             # home, new idea, detail, verdict, edit
│   │           └── widgets/             # analyse_button, idea_card
│   └── shared/
│       └── widgets/                     # verdict_badge, voice_input_button
│
├── supabase/
│   └── functions/
│       └── analyse-idea/index.ts        # Deno Edge Function (AI + usage gate)
│
├── test/
│   ├── unit/                            # Entity, state, service, repo tests
│   ├── widget/                          # Widget tests
│   └── helpers/                         # Fake Supabase + mock providers
│
├── integration_test/
│   └── golden_path_test.dart            # End-to-end golden path
│
└── .github/workflows/flutter_ci.yml    # CI: lint → test → build → deploy
```

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Flutter | 3.32+ (stable) | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart | 3.12+ | bundled with Flutter |
| Supabase CLI | latest | `brew install supabase/tap/supabase` |
| Deno | latest | `brew install deno` |
| Xcode | 15+ | Mac App Store (iOS builds) |
| Android Studio | latest | [developer.android.com](https://developer.android.com/studio) |

Verify your Flutter install:

```bash
flutter doctor
```

---

## 1 — Supabase Setup

### 1.1 Create a project

1. Go to [supabase.com](https://supabase.com) and create a new project.
2. Note your **Project URL** and **anon public key** from *Settings → API*.

### 1.2 Run the database migration

The app needs a `user_analysis_usage` table and an RPC for the server-side usage gate.

Run this in the Supabase SQL editor (*Database → SQL Editor*):

```sql
-- Usage tracking table
create table if not exists user_analysis_usage (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  count      int  not null default 0,
  updated_at timestamptz not null default now()
);

-- RPC called by the Edge Function after a successful analysis
create or replace function increment_analysis_usage(p_user_id uuid)
returns void language plpgsql security definer as $$
begin
  insert into user_analysis_usage (user_id, count)
  values (p_user_id, 1)
  on conflict (user_id)
  do update set count = user_analysis_usage.count + 1,
                updated_at = now();
end;
$$;

-- Row-level security
alter table user_analysis_usage enable row level security;

create policy "Users can read own usage"
  on user_analysis_usage for select
  using (auth.uid() = user_id);
```

### 1.3 Enable Auth providers

In *Authentication → Providers*, enable:
- **Email** (enabled by default)
- **Apple** (requires an Apple Developer account)
- **Google** (requires a Google Cloud OAuth client)

### 1.4 Set Edge Function secrets

```bash
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
```

The Supabase service role key and URL are injected automatically at runtime — you don't need to set them manually.

---

## 2 — Local Development

### 2.1 Clone and install

```bash
git clone https://github.com/samuelomotayo/someday.git
cd someday
flutter pub get
```

### 2.2 Generate code

Riverpod providers, Drift queries, and Freezed models are all code-generated. Run this every time you change an annotated file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous watch mode during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 2.3 (Optional) Run Supabase locally

```bash
supabase start          # starts local Postgres + Auth + Edge Runtime
supabase functions serve analyse-idea --env-file .env.local
```

Create `.env.local` in the project root (gitignored):

```
ANTHROPIC_API_KEY=sk-ant-...
```

---

## 3 — Running the App

Credentials are injected at run time via `--dart-define`. **Never hard-code them.**

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

If you omit the flags in debug mode, the app shows a configuration error screen instead of crashing — useful for teammates onboarding quickly.

### Convenience script

Create a `run.sh` in the project root (gitignored):

```bash
#!/bin/bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  "$@"
```

```bash
chmod +x run.sh && ./run.sh
```

### Targeting a specific device

```bash
flutter devices                          # list available devices
./run.sh -d "iPhone 16"                  # iOS Simulator
./run.sh -d emulator-5554               # Android Emulator
```

---

## 4 — Running Tests

### Unit + widget tests

```bash
flutter test \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### With coverage

```bash
flutter test --coverage
# Open the report (macOS):
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration tests (requires a running device or simulator)

```bash
flutter test integration_test/golden_path_test.dart \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### Test structure at a glance

| File | What it covers |
|---|---|
| `test/unit/idea_entity_test.dart` | Idea validation (title/description/emotionalNote length) |
| `test/unit/verdict_type_test.dart` | VerdictType enum: labels, `isAnalysed`, `fromApiString()` |
| `test/unit/analysis_state_test.dart` | AnalysisState sealed class — all 6 sub-states |
| `test/unit/resurrection_repository_test.dart` | HTTP payload, verdict mapping, error handling |
| `test/unit/usage_count_service_test.dart` | Free-tier limit (3), increment, reset, remaining |
| `test/widget/` | analyse_button, idea_card, verdict_badge, verdict_screen |
| `integration_test/golden_path_test.dart` | End-to-end happy path |

---

## 5 — Deploying the Edge Function

### Deploy to production

```bash
supabase functions deploy analyse-idea --project-ref YOUR_PROJECT_REF
```

### Test locally with curl

```bash
curl -X POST http://localhost:54321/functions/v1/analyse-idea \
  -H "Authorization: Bearer YOUR_USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Crowdsourced recipe app",
    "description": "Let communities vote on the best local recipes.",
    "timePeriod": "2021-2022",
    "reasonForStopping": "Could not find a co-founder."
  }'
```

### Expected response shape

```json
{
  "verdict": "second_chance",
  "summary": "The market timing has genuinely improved...",
  "confidence": 0.82,
  "signals": ["TikTok food content exploded", "No dominant player yet"],
  "next_steps": ["Run a survey in a food community", "Build a waitlist landing page"]
}
```

---

## CI/CD Pipeline

The pipeline runs on every push to `main` or `develop` and on all pull requests.

```
push / PR
  ├─ lint          flutter analyze + dart format check
  ├─ test          flutter test --coverage → Codecov upload
  ├─ build-ios     flutter build ios --no-codesign (validation)
  ├─ build-android flutter build appbundle → uploads AAB artifact
  └─ deploy-testflight  (main branch only, via Fastlane)
```

All build steps require `SUPABASE_URL` and `SUPABASE_ANON_KEY` to be set as GitHub repository secrets (see below).

---

## Deployment (TestFlight / Play Store)

Deployments are handled by Fastlane. The `ios beta` lane builds, signs, and ships to TestFlight automatically on every merge to `main`.

### Prerequisites

- Apple Developer account with an App Store Connect API key
- App registered in App Store Connect with bundle ID `com.campusrunz.someday`
- Signing certificates and provisioning profiles in your keychain

### Manual deploy

```bash
# iOS → TestFlight
fastlane ios beta

# Android → internal track (add to Fastfile when ready)
fastlane android internal
```

---

## GitHub Secrets Reference

Add these under *Settings → Secrets and variables → Actions* in the repo:

| Secret | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL (`https://xxx.supabase.co`) |
| `SUPABASE_ANON_KEY` | Supabase anon public key |
| `CODECOV_TOKEN` | Codecov upload token (optional — CI won't fail without it) |
| `APP_STORE_CONNECT_API_KEY` | Contents of your `.p8` key file (base64 or raw) |
| `APP_STORE_CONNECT_KEY_ID` | Key ID from App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect |

> **Note:** The Anthropic API key is set only as a Supabase Edge Function secret (`supabase secrets set ANTHROPIC_API_KEY=...`). It never enters GitHub or the Flutter client.

---

## Contributing

1. Branch from `develop`: `git checkout -b feat/your-feature`
2. Run `dart run build_runner build` after changing annotated files
3. Run `flutter analyze` and `flutter test` before opening a PR
4. PRs targeting `main` trigger the full CI pipeline including a TestFlight deploy
