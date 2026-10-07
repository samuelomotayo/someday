# product_manager_portfolio — Claude Agent Instructions

## Project
A Flutter mobile application targeting iOS and Android, built and delivered by a coordinated team of specialised Claude agents.

---

## Agent Pipeline

Every task follows this sequence. No layer may begin until the layer above it has completed and handed off.

```
User Prompt
  └─► system-analyst
        Requirements intake, clarification, and structured handoff
  └─► Strategy Layer  (run in parallel)
        ├─ cto-advisor           — tech strategy and architecture decisions
        ├─ product-counsel       — feature validation and prioritisation
        ├─ brand-identity-architect — brand tokens and design system foundations
        └─ product-spec-architect — PRD, user stories, acceptance criteria
  └─► flutter-orchestrator
        Receives strategy outputs, coordinates all layers below
  └─► Design Layer  (run in parallel)
        ├─ premium-product-designer — visual design and design system
        ├─ ux-flow-architect        — user flows, navigation, and journeys
        └─ figma-design-agent       — Figma assets, components, and token sync
  └─► Architecture Layer  (run in parallel)
        ├─ flutter-api-architect    — REST/API layer, data models, repositories
        ├─ flutter-logic-architect  — state management and business logic
        └─ flutter-mobile-architect — native iOS/Android platform layer
  └─► Implementation Layer  (run in parallel)
        ├─ flutter-ui-builder       — widgets, screens, and components
        └─ mobile-perf-engineer     — performance profiling and optimisation
  └─► Quality Layer  (run in parallel)
        ├─ test-architect           — unit, widget, and integration tests
        └─ code-maintainability-guardian — code quality and architecture audit
  └─► CI/CD Gate
        GitHub Actions — lint, test, build validation
        Fastlane       — automated build signing and packaging
  └─► Simulator Testing
        iOS Simulator  — Xcode iOS simulator validation
        Android Emulator — Android Studio emulator validation
  └─► Release Build
        IPA  — iOS archive for App Store
        AAB  — Android App Bundle for Google Play
  └─► Store Submission
        App Store  — via Fastlane deliver
        Google Play — via Fastlane supply
```

---

## Layer Rules

- **No layer skips**: Every layer must complete before the next begins. The flutter-orchestrator enforces this.
- **Parallel within layers**: Agents within the same layer run concurrently unless they have explicit dependencies on each other.
- **Handoff artefacts**: Each layer must produce a concrete output (spec, design, code, test, build) before handing off.
- **Blockers escalate**: If any agent cannot proceed, it reports to flutter-orchestrator immediately — it does not wait silently.
- **Memory continuity**: All agents with project memory read it at session start and write their outputs at session end.

---

## Key Directories

```
product_manager_portfolio/
├── CLAUDE.md                  ← this file — read by all agents
├── .claude/agents/            ← project-level agent definitions
├── lib/
│   ├── core/theme/            ← brand tokens (brand-identity-architect)
│   ├── data/                  ← API, models, repositories (flutter-api-architect)
│   ├── domain/                ← use cases, entities (flutter-logic-architect)
│   ├── features/              ← feature modules (flutter-ui-builder)
│   └── shared/widgets/        ← reusable components (flutter-ui-builder)
├── test/                      ← all tests (test-architect)
├── ios/                       ← iOS native layer (flutter-mobile-architect)
└── android/                   ← Android native layer (flutter-mobile-architect)
```

---

## MCP Usage by Layer

| Layer | MCPs Available |
|-------|---------------|
| Intake | Gmail, Google Calendar, Zoom, Google Drive, Read AI, Slack |
| Strategy | GitHub, Atlassian Rovo, Amplitude, Canva, Google Drive, Slack |
| Design | GitHub, Figma, Canva, Lucid, Amplitude |
| Architecture | GitHub, Postman, Fastlane, Firebase |
| Implementation | GitHub, Figma, Amplitude |
| Quality | GitHub, SonarQube, Codecov, Atlassian Rovo |
| CI/CD → Release | GitHub, Fastlane, Firebase |

---

## Stack Decisions (update as decided)

| Concern | Decision | Decided By |
|---------|----------|------------|
| State management | TBD | cto-advisor |
| Navigation | TBD | cto-advisor |
| Networking | TBD | cto-advisor |
| Local storage | TBD | cto-advisor |
| DI framework | TBD | cto-advisor |
