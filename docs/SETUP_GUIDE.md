# Product Manager Portfolio — Full Setup Guide

**Project:** product_manager_portfolio  
**Platform:** Flutter (iOS + Android)  
**GitHub:** https://github.com/samuelomotayo/product_manager_portfolio  
**Firebase Project:** campusrunz-773a2  
**SonarQube:** https://sonarcloud.io/project/overview?id=samuelomotayo_product_manager_portfolio  

---

## Table of Contents

1. [Development Environment](#1-development-environment)
2. [Flutter Project](#2-flutter-project)
3. [MCP Connections](#3-mcp-connections)
4. [Claude Agents](#4-claude-agents)
5. [Agent Pipeline](#5-agent-pipeline)
6. [Firebase Setup](#6-firebase-setup)
7. [App Store Connect (iOS)](#7-app-store-connect-ios)
8. [Fastlane](#8-fastlane)
9. [CI/CD — GitHub Actions](#9-cicd--github-actions)
10. [SonarQube Cloud](#10-sonarqube-cloud)
11. [Codecov](#11-codecov)
12. [GitHub Secrets Reference](#12-github-secrets-reference)
13. [Stored Credentials & Key Files](#13-stored-credentials--key-files)
14. [Pending Setup](#14-pending-setup)

---

## 1. Development Environment

All tools installed on macOS (Apple Silicon) via Homebrew unless noted.

| Tool | Version | Install Command |
|------|---------|----------------|
| Flutter SDK | 3.44.1 (stable) | `brew install --cask flutter` |
| Dart | 3.12.1 | Bundled with Flutter |
| Xcode | 26.5 | Mac App Store |
| Android Studio | 2026.1.1.8 | `brew install --cask android-studio` |
| Git | 2.50.1 | `brew install git` |
| Node.js | 22.11.0 | Pre-installed |
| CocoaPods | 1.16.2 | `brew install cocoapods` |
| Fastlane | 2.236.1 | `brew install fastlane` |
| GitHub CLI | 2.94.0 | `brew install gh` |
| Docker Desktop | 29.0.0 | Pre-installed |
| npm (Claude Code) | — | `npm install -g @anthropic-ai/claude-code` |

### Post-install steps completed
- Xcode license accepted: `sudo xcodebuild -license accept`
- Android SDK command-line tools installed via Android Studio
- Android SDK licences accepted: `flutter doctor --android-licenses`
- iOS Simulator runtime downloaded via Xcode → Settings → Components
- CocoaPods initialised
- `flutter doctor` — all green, no issues

---

## 2. Flutter Project

### Location
```
~/Desktop/Source1/product_manager_portfolio/
```

### Created with
```bash
flutter create product_manager_portfolio
```

### Project structure
```
product_manager_portfolio/
├── CLAUDE.md                        ← agent pipeline reference (auto-read by all agents)
├── sonar-project.properties         ← SonarQube Cloud config
├── pubspec.yaml
├── docs/
│   └── SETUP_GUIDE.md               ← this file
├── .claude/
│   └── agents/                      ← 15 project-level Claude agents
├── .github/
│   └── workflows/
│       └── flutter_ci.yml           ← CI/CD pipeline
├── fastlane/
│   ├── Appfile                      ← App Store Connect config
│   └── Fastfile                     ← iOS and Android lanes
├── lib/
│   └── main.dart
├── ios/
├── android/
└── test/
```

### GitHub repository
- **URL:** https://github.com/samuelomotayo/product_manager_portfolio
- **Visibility:** Private
- **Default branch:** `main`
- **Initialised:** `git init` → initial commit → `gh repo create --private --push`

---

## 3. MCP Connections

All MCP servers configured in `~/.claude.json`. Run `claude mcp list` to verify status.

### claude.ai Managed MCPs (authenticated via `/mcp`)

| MCP | Purpose | Status |
|-----|---------|--------|
| GitHub | Repo, PRs, issues, CI | ✅ Connected |
| Figma | Design assets & components | ✅ Connected |
| Atlassian Rovo | Jira + Confluence | ✅ Connected |
| Amplitude | Product analytics | ✅ Connected |
| Canva | Brand & marketing assets | ✅ Connected |
| Lucid | Diagrams & flow charts | ✅ Connected |
| Google Drive | Document storage | ✅ Connected |
| Gmail | Email-based requirements | ✅ Connected |
| Zoom | Meeting recordings | ✅ Connected |
| Google Calendar | Scheduling | ✅ Connected |
| Read AI | Meeting transcripts | ✅ Connected |
| Slack | Team communication | ✅ Connected |
| Postman | API collections | ✅ Connected |

### Self-configured MCPs

| MCP | Command | Key Env Vars |
|-----|---------|-------------|
| **GitHub** | `npx -y @modelcontextprotocol/server-github` | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **Firebase** | `npx -y @gannonh/firebase-mcp` | `SERVICE_ACCOUNT_KEY_PATH`, `FIREBASE_STORAGE_BUCKET` |
| **Codecov** | `npx -y codecov-mcp-server` | `CODECOV_API_KEY`, `GIT_URL` |
| **SonarQube** | `docker run mcp/sonarqube` | `SONARQUBE_URL`, `SONARQUBE_TOKEN`, `SONARQUBE_ORG`, `SONARQUBE_PROJECT_KEY` |

#### To re-add self-configured MCPs from scratch

```bash
# GitHub
claude mcp add github \
  --env GITHUB_PERSONAL_ACCESS_TOKEN=<token> \
  -- npx -y @modelcontextprotocol/server-github

# Firebase
claude mcp add firebase \
  --env SERVICE_ACCOUNT_KEY_PATH=~/.firebase/service-account.json \
  --env FIREBASE_STORAGE_BUCKET=campusrunz-773a2.firebasestorage.app \
  -- npx -y @gannonh/firebase-mcp

# Codecov
claude mcp add codecov \
  --env CODECOV_API_KEY=<token> \
  --env GIT_URL=https://github.com/samuelomotayo/product_manager_portfolio \
  -- npx -y codecov-mcp-server

# SonarQube
claude mcp add sonarqube \
  --env SONARQUBE_URL=https://sonarcloud.io \
  --env SONARQUBE_TOKEN=<token> \
  --env SONARQUBE_ORG=samuelomotayo \
  --env SONARQUBE_PROJECT_KEY=samuelomotayo_product_manager_portfolio \
  --env SONARQUBE_TOOLSETS=cag,projects,analysis \
  -- docker run -i --rm --pull=always \
  -e SONARQUBE_URL -e SONARQUBE_TOKEN -e SONARQUBE_ORG \
  -e SONARQUBE_PROJECT_KEY -e SONARQUBE_TOOLSETS \
  -v "$(pwd):/app/mcp-workspace:rw" mcp/sonarqube
```

> **Note:** Fastlane MCP has no published npm/PyPI package. Fastlane is invoked directly via CLI.

---

## 4. Claude Agents

### Project-level agents — `.claude/agents/`

| Agent | Model | Memory | Role |
|-------|-------|--------|------|
| `flutter-orchestrator` | Sonnet | Project | Coordinates all agents, enforces pipeline |
| `brand-identity-architect` | Sonnet | Project | Brand colours, typography, design tokens |
| `cto-advisor` | Sonnet | Project | Tech strategy, architecture decisions |
| `figma-design-agent` | Sonnet | Project | Figma assets, components, token sync |
| `flutter-api-architect` | Sonnet | Project | REST/API layer, data models, repositories |
| `flutter-logic-architect` | Sonnet | Project | State management, business logic |
| `flutter-mobile-architect` | Sonnet | Project | Native iOS/Android platform layer |
| `flutter-ui-builder` | Sonnet | Project | Widgets, screens, components |
| `mobile-perf-engineer` | Sonnet | None | Performance profiling & optimisation |
| `premium-product-designer` | Sonnet | Project | Visual design & product polish |
| `product-counsel` | Sonnet | Project | Product decisions, prioritisation |
| `product-spec-architect` | Sonnet | Project | PRDs, specs, acceptance criteria |
| `test-architect` | Sonnet | Project | Test strategy, unit/widget/integration tests |
| `ux-flow-architect` | Sonnet | Project | User flows, navigation, journeys |
| `code-maintainability-guardian` | Sonnet | None | Code quality, architecture audit |

### User-level agent — `~/.claude/agents/`

| Agent | Model | Memory | Role |
|-------|-------|--------|------|
| `system-analyst` | Sonnet | User | Requirements intake and analysis |

### MCP assignments per agent

| Agent | MCPs |
|-------|------|
| flutter-orchestrator | GitHub, Atlassian Rovo, Zoom, Slack |
| brand-identity-architect | GitHub, Canva, Google Drive |
| cto-advisor | GitHub, Atlassian Rovo, Slack |
| figma-design-agent | GitHub, Figma, Canva |
| flutter-api-architect | GitHub, Postman |
| flutter-logic-architect | GitHub |
| flutter-mobile-architect | GitHub, Fastlane (CLI), Firebase |
| flutter-ui-builder | GitHub, Figma |
| mobile-perf-engineer | GitHub, Amplitude |
| premium-product-designer | GitHub, Figma, Canva, Lucid |
| product-counsel | GitHub, Atlassian Rovo, Amplitude, Slack |
| product-spec-architect | GitHub, Atlassian Rovo, Lucid, Google Drive |
| test-architect | GitHub, Atlassian Rovo, Codecov |
| ux-flow-architect | GitHub, Atlassian Rovo, Amplitude, Lucid |
| code-maintainability-guardian | GitHub, SonarQube |
| system-analyst | Gmail, Google Calendar, Zoom, Google Drive, Read AI, Slack |

---

## 5. Agent Pipeline

Every task follows this sequence. Defined in `CLAUDE.md` at the project root.

```
User Prompt
  └─► system-analyst
        Requirements intake, clarification, structured handoff
  └─► Strategy Layer  (parallel)
        ├─ cto-advisor
        ├─ product-counsel
        ├─ brand-identity-architect
        └─ product-spec-architect
  └─► flutter-orchestrator
        Receives strategy outputs, coordinates all layers below
  └─► Design Layer  (parallel)
        ├─ premium-product-designer
        ├─ ux-flow-architect
        └─ figma-design-agent
  └─► Architecture Layer  (parallel)
        ├─ flutter-api-architect
        ├─ flutter-logic-architect
        └─ flutter-mobile-architect
  └─► Implementation Layer  (parallel)
        ├─ flutter-ui-builder
        └─ mobile-perf-engineer
  └─► Quality Layer  (parallel)
        ├─ test-architect
        └─ code-maintainability-guardian
  └─► CI/CD Gate
        GitHub Actions — lint, test, SonarQube, build
        Fastlane       — signing and packaging
  └─► Simulator Testing
        iOS Simulator + Android Emulator
  └─► Release Build
        IPA (iOS) + AAB (Android)
  └─► Store Submission
        App Store (Fastlane deliver) + Google Play (Fastlane supply)
```

---

## 6. Firebase Setup

### Project details
| Field | Value |
|-------|-------|
| Project name | Campusrunz |
| Project ID | `campusrunz-773a2` |
| Project number | 412437528737 |
| Storage bucket | `campusrunz-773a2.firebasestorage.app` |

### Service account key
- **Stored at:** `~/.firebase/service-account.json`
- **Permissions:** `600` (owner read/write only)
- **Original filename:** `campusrunz-773a2-firebase-adminsdk-fbsvc-eaa1a49285.json`

### To set up Firebase from scratch
1. Go to **firebase.google.com** → Create project
2. Project settings → Service accounts → Generate new private key
3. Move key: `mv ~/Downloads/<key>.json ~/.firebase/service-account.json`
4. Set permissions: `chmod 600 ~/.firebase/service-account.json`
5. Enable Firebase Storage: Build → Storage → Get started
6. Add Firebase MCP (see Section 3)

---

## 7. App Store Connect (iOS)

### API Key details
| Field | Value |
|-------|-------|
| Key ID | `FBM7945283` |
| Issuer ID | `69a6de97-1dae-47e3-e053-5b8c7c11a4d1` |
| Key file | `~/.fastlane/keys/AuthKey_FBM7945283.p8` |
| Permissions | `600` (owner read/write only) |

### To generate an App Store Connect API key
1. Go to **appstoreconnect.apple.com** → Users and Access → Integrations → App Store Connect API
2. Click **"+"** → Name: `fastlane`, Role: `App Manager`
3. Download the `.p8` file — **can only be downloaded once**
4. Move to: `~/.fastlane/keys/AuthKey_<KEY_ID>.p8`
5. Set permissions: `chmod 600 ~/.fastlane/keys/AuthKey_<KEY_ID>.p8`

---

## 8. Fastlane

### Installation
```bash
brew install fastlane
```

### Project config files
| File | Purpose |
|------|---------|
| `fastlane/Appfile` | App identifier, Apple ID, team IDs |
| `fastlane/Fastfile` | iOS and Android lane definitions |

### Available lanes

**iOS**
```bash
fastlane ios certificates    # Sync certs and profiles (read-only)
fastlane ios test            # Run tests on iOS simulator
fastlane ios beta            # Build + upload to TestFlight
fastlane ios release         # Submit to App Store for review
```

**Android**
```bash
fastlane android beta        # Build AAB + upload to Play Store internal track
fastlane android release     # Promote internal build to production
```

### App Store Connect API key (used by Fastlane)
Configured in `Fastfile` using:
- `key_id`: `FBM7945283`
- `issuer_id`: `69a6de97-1dae-47e3-e053-5b8c7c11a4d1`
- `key_filepath`: `~/.fastlane/keys/AuthKey_FBM7945283.p8`

### Android setup (pending)
- Requires Google Play service account JSON key
- Set env var: `GOOGLE_PLAY_JSON_KEY_PATH=<path-to-json>`
- See: play.google.com/console → Setup → API access

---

## 9. CI/CD — GitHub Actions

### Workflow file
`.github/workflows/flutter_ci.yml`

### Trigger
- Push to `main` or `develop`
- Pull requests targeting `main` or `develop`

### Jobs and sequence

```
lint  →  test  →  sonarqube
                  build-ios      →  deploy-testflight (main only)
                  build-android
```

| Job | Runner | Depends on | Purpose |
|-----|--------|-----------|---------|
| `lint` | ubuntu-latest | — | `dart format` + `flutter analyze` |
| `test` | ubuntu-latest | lint | `flutter test --coverage` + Codecov upload |
| `sonarqube` | ubuntu-latest | test | SonarQube Cloud scan |
| `build-ios` | macos-latest | test | `flutter build ios --no-codesign` |
| `build-android` | ubuntu-latest | test | `flutter build appbundle --release` |
| `deploy-testflight` | macos-latest | build-ios + build-android | `fastlane ios beta` (main branch only) |

---

## 10. SonarQube Cloud

### Project details
| Field | Value |
|-------|-------|
| Host | `https://sonarcloud.io` |
| Organisation | `samuelomotayo` |
| Project key | `samuelomotayo_product_manager_portfolio` |
| Config file | `sonar-project.properties` |

### To set up SonarQube Cloud from scratch
1. Go to **sonarcloud.io** → Log in with GitHub
2. **"+"** → Analyze new project → Select repo → Free plan → Set up
3. My Account → Security → Generate token → Copy
4. Add `SONAR_TOKEN` to GitHub secrets
5. Add `sonar-project.properties` to project root
6. Add SonarQube scan step to CI workflow
7. Add SonarQube MCP (requires Docker Desktop running):
```bash
claude mcp add sonarqube \
  --env SONARQUBE_URL=https://sonarcloud.io \
  --env SONARQUBE_TOKEN=<token> \
  --env SONARQUBE_ORG=samuelomotayo \
  --env SONARQUBE_PROJECT_KEY=samuelomotayo_product_manager_portfolio \
  --env SONARQUBE_TOOLSETS=cag,projects,analysis \
  -- docker run -i --rm --pull=always \
  -e SONARQUBE_URL -e SONARQUBE_TOKEN -e SONARQUBE_ORG \
  -e SONARQUBE_PROJECT_KEY -e SONARQUBE_TOOLSETS \
  -v "$(pwd):/app/mcp-workspace:rw" mcp/sonarqube
```

> **Note:** Docker Desktop must be running for the SonarQube MCP to connect.

---

## 11. Codecov

### Account details
| Field | Value |
|-------|-------|
| Platform | codecov.io |
| Repository | `samuelomotayo/product_manager_portfolio` |
| Login | GitHub OAuth |

### To set up Codecov from scratch
1. Go to **codecov.io** → Sign in with GitHub
2. Select the repository
3. My Account → Settings → API Tokens → Generate Token
4. Add `CODECOV_TOKEN` to GitHub secrets
5. Add `codecov/codecov-action@v4` step to CI test job
6. Add Codecov MCP:
```bash
claude mcp add codecov \
  --env CODECOV_API_KEY=<token> \
  --env GIT_URL=https://github.com/samuelomotayo/product_manager_portfolio \
  -- npx -y codecov-mcp-server
```

---

## 12. GitHub Secrets Reference

All stored in `github.com/samuelomotayo/product_manager_portfolio/settings/secrets/actions`.

| Secret | Used by | Purpose |
|--------|---------|---------|
| `CODECOV_TOKEN` | CI test job | Codecov coverage upload |
| `SONAR_TOKEN` | CI sonarqube job | SonarQube Cloud scan |
| `APP_STORE_CONNECT_KEY_ID` | deploy-testflight job | App Store Connect auth |
| `APP_STORE_CONNECT_ISSUER_ID` | deploy-testflight job | App Store Connect auth |
| `APP_STORE_CONNECT_API_KEY` | deploy-testflight job | `.p8` key file contents |

---

## 13. Stored Credentials & Key Files

| File | Purpose | Permissions |
|------|---------|------------|
| `~/.firebase/service-account.json` | Firebase Admin SDK | `600` |
| `~/.fastlane/keys/AuthKey_FBM7945283.p8` | App Store Connect API | `600` |
| `~/.claude.json` | MCP server config (tokens included) | Default |

> **Important:** None of these files are committed to the repository. Keep them backed up securely (e.g. 1Password or encrypted cloud storage).

---

## 14. Pending Setup

| Item | What's needed |
|------|--------------|
| **Android Play Store** | Google Play service account JSON key — see play.google.com/console → Setup → API access |
| **Fastlane match** | Certificate storage repo (private GitHub repo) for iOS code signing |
| **App identifiers** | Confirm bundle ID (`com.campusrunz.productmanagerportfolio`) in Apple Developer portal and Android manifest |
| **Fastlane Appfile** | Fill in `itc_team_id` and `team_id` after first Fastlane run |
| **App Store listing** | Create app record in App Store Connect before first TestFlight upload |
| **Play Store listing** | Create app in Google Play Console before first upload |
