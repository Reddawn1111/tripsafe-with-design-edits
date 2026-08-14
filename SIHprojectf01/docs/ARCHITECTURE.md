# TRIPSAFE — Architecture (Stage 1)

> **Scope:** Stage 1 selection prototype only  
> **Principle:** Prototype implementation with clean, extensible structure  
> **Last updated:** 2026-08-11

---

## 1. Architecture Goals

| Goal | Description |
|------|-------------|
| Simple | Beginner-friendly; easy to navigate in 5 days |
| Modular | Features isolated by folder and contract |
| Testable | Services accept interfaces; mock implementations swappable |
| Demo-ready | Golden path can be scripted and repeated |
| Stage-2-ready | Repository/service boundaries allow live implementations later |

**Anti-goals for Stage 1:** microservices, dependency injection frameworks, over-abstracted domain layers, premature cloud setup.

---

## 2. High-Level Layer Model

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION (UI)                     │
│  Screens · Widgets/Components · Navigation · Demo UI    │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                  APPLICATION / STATE                     │
│  Screen controllers · View models · App state           │
│  (TEAM DECISION REQUIRED: state management approach)    │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                       SERVICES                           │
│  Business logic · Itinerary gen · Safety · Adaptation   │
│  Defined in SERVICE_CONTRACT.md                          │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                    REPOSITORIES                          │
│  Data access · Mock JSON · Local persistence            │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                  DATA (Models + Assets)                  │
│  Typed models from DATA_CONTRACT.md · mock JSON assets  │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Application Layers — Responsibilities

### 3.1 Presentation (UI)

**Owns:**
- Rendering screens from `NAVIGATION_MAP.md`
- User input capture (forms, buttons, lists)
- Display of models returned by services
- Demo triggers (e.g. “Simulate risk change” for judges)
- Visual feedback (loading, empty states, alerts)

**Must NOT:**
- Embed business rules (safety severity logic, itinerary generation rules)
- Read mock JSON directly (go through repositories/services)
- Hard-code duplicate model shapes that diverge from `DATA_CONTRACT.md`

### 3.2 Application / State

**Owns:**
- Current trip context (active `tripId`, selected destination)
- Screen-level state and navigation arguments
- Orchestration: call services, handle results, update UI

**TEAM DECISION REQUIRED:**
- State management pattern (e.g. Provider, Riverpod, Bloc, setState-only for minimal prototype)
- Global vs inherited trip session scope

### 3.3 Services

**Owns:**
- Business operations defined in `SERVICE_CONTRACT.md`
- Composing repository data into user-meaningful results
- Simulated safety evaluation and trip adaptation logic

**Stage 1 implementations:** `LOCAL`, `MOCK`, or `SIMULATED`  
**Stage 2 replacements:** `REAL` / `API` implementations behind same interfaces

### 3.4 Repositories

**Owns:**
- Loading/saving entities (`Destination`, `Trip`, `Expense`, etc.)
- Mock asset loading from bundled JSON
- Local persistence (TEAM DECISION REQUIRED: in-memory vs file)

**Naming pattern for Stage 2 evolution:**
| Stage 1 | Stage 2 (example) |
|---------|-------------------|
| `LocalDestinationRepository` | `ApiDestinationRepository` |
| `LocalTripRepository` | `CloudTripRepository` |
| `MockSafetyRepository` | `LiveSafetyRepository` |

### 3.5 Models

**Owns:**
- Immutable (preferred) data classes matching `DATA_CONTRACT.md`
- Serialization helpers (`fromJson` / `toJson`) if using JSON assets
- No UI logic

### 3.6 Navigation

**Owns:**
- Route name constants
- Route table / router configuration
- Deep-link arguments (e.g. `tripId`, `alertId`)
- Back-stack expectations documented in `NAVIGATION_MAP.md`

---

## 4. Proposed Folder Structure

> Platform folder names (`lib/`, `src/`) depend on framework choice — **TEAM DECISION REQUIRED**.  
> Structure below is **logical** and should map 1:1 regardless of framework.

```
tripsafe/
├── docs/                          # Project documentation (this repo)
├── assets/
│   └── mock/                      # MOCK DATA — JSON fixtures
│       ├── destinations.json
│       ├── safety_scenarios.json
│       └── demo_trip.json
├── lib/                           # TEAM DECISION REQUIRED: app root
│   ├── main.dart                  # Entry (or equivalent)
│   ├── app/
│   │   ├── app.dart               # App shell, theme
│   │   └── routes.dart            # Route definitions
│   ├── models/                    # DATA_CONTRACT implementations
│   ├── repositories/              # Local/mock data access
│   ├── services/                  # SERVICE_CONTRACT implementations
│   ├── screens/                   # One folder per major screen
│   │   ├── discovery/
│   │   ├── planning/
│   │   ├── itinerary/
│   │   ├── safety/
│   │   ├── risk_alert/
│   │   ├── adapt_trip/
│   │   ├── alternative_destination/
│   │   ├── active_journey/
│   │   ├── timeline/
│   │   ├── memories/
│   │   ├── expenses/
│   │   ├── settlement/
│   │   └── trip_summary/
│   ├── widgets/                   # Shared UI components
│   └── utils/                     # Formatters, constants
└── test/                          # Stage 1: light unit tests optional
```

---

## 5. Shared Components (UI)

Reusable widgets planned for Stage 1:

| Component | Used by |
|-----------|---------|
| `DestinationCard` | Discovery, Alternative Destination |
| `ItineraryDayView` | Itinerary, Updated Itinerary, Active Journey |
| `SafetyBadge` | Destination detail, Safety, Risk Alert |
| `RiskAlertBanner` | Risk Alert, Active Journey |
| `ExpenseListTile` | Expenses, Settlement |
| `MemoryCard` | Memories, Trip Summary |
| `PrimaryButton` / `SecondaryButton` | All flows |
| `DemoScenarioButton` | Hidden or dev-only demo trigger for risk simulation |

---

## 6. Data Flow — Golden Path Example

```
User taps "Plan Trip"
    → PlanningScreen collects TripPreferences
    → TripPlanningService.createTrip(preferences)
        → LocalTripRepository.save(trip)
    → ItineraryGenerationService.generate(tripId)
        → reads Destination + rules/templates
        → LocalTripRepository.saveItinerary(...)
    → Navigate to ItineraryScreen

[Demo: simulate risk]
    → SafetyService.evaluate(tripId)
    → SafetyService.simulateRiskChange(tripId, scenarioId)  [SIMULATED]
    → RiskAlertService.createAlert(...)
    → Navigate to RiskAlertScreen

User taps "Adapt Trip"
    → TripAdaptationService.proposeAlternatives(tripId, alertId)
    → User selects alternative
    → TripAdaptationService.applyAlternative(tripId, destinationId)
    → ItineraryGenerationService.regenerate(tripId)
    → Navigate to Updated Itinerary → Active Journey
```

---

## 7. Stage 1 vs Stage 2 Architecture Evolution

| Concern | Stage 1 | Stage 2 |
|---------|---------|---------|
| Data storage | Local/mock | Cloud DB |
| Auth | None / placeholder traveler name | Real accounts |
| Safety | MockSafetyService + scripted scenarios | LiveSafetyService + APIs |
| Itinerary AI | Template/rule-based | LLM or backend AI |
| Notifications | In-app only | Push / realtime |
| Config | Bundled assets | Remote config |
| Error handling | User-friendly messages | Retries, logging, monitoring |

**Rule:** Stage 1 code should call **services**, not “future API URLs” directly in UI.

---

## 8. Dependency Rules

```
screens  →  services  →  repositories  →  models/assets
   ↓           ↓
 widgets     utils

FORBIDDEN:
- repositories → screens
- models → services
- screens → repositories (bypass services)
- circular imports between feature folders
```

Cross-feature changes require **Coder 1 (Tech Lead)** approval per `OWNERSHIP.md`.

---

## 9. Demo Mode Architecture

For reliable SIH selection demos:

| Element | Purpose |
|---------|---------|
| `demo_scenarios.json` | Predefined risk-change scripts |
| `DemoController` or equivalent | Trigger scenario from dev/demo menu |
| Default seed data | Known destinations that look good in presentation |
| Reset function | Clear local state between demo runs |

Owner: **Member 6 (QA + Demo)** with implementation by **Coder 2**.

---

## 10. Testing Architecture (Stage 1)

| Level | Scope |
|-------|-------|
| Manual | Primary — see `TEST_CHECKLIST.md` |
| Unit (optional) | Service logic with mock repositories |
| Widget (optional) | Critical screens if time permits |
| E2E automation | **POSTPONED TO STAGE 2** unless team approves |

---

## 11. Open Architecture Decisions

| Topic | Status |
|-------|--------|
| Frontend framework | **TEAM DECISION REQUIRED** |
| State management | **TEAM DECISION REQUIRED** |
| Local persistence | **TEAM DECISION REQUIRED** |
| Single app vs mobile+web | **TEAM DECISION REQUIRED** (SIH category allows both; Stage 1 likely one platform) |
| Image/media storage for memories | **TEAM DECISION REQUIRED** |

Log resolutions in `DECISION_LOG.md` and `LOCKED_DECISIONS.md`.
