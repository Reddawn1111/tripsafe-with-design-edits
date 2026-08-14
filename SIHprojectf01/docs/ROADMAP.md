# TRIPSAFE — Development Roadmap

> **Two-stage strategy** — Stage 1 must not build Stage 2 infrastructure unless explicitly approved  
> **Last updated:** 2026-08-11

---

## Overview

```
┌─────────────────────────────────────┐     ┌─────────────────────────────────────┐
│         STAGE 1 (5 DAYS)            │     │      STAGE 2 (POST-SELECTION)      │
│   SIH Selection Prototype           │ ──► │   SIH Finale Production App          │
│   Mock / Local / Simulated          │     │   Live / Cloud / Authenticated       │
└─────────────────────────────────────┘     └─────────────────────────────────────┘
```

---

## STAGE 1 — 5-Day SIH Selection Prototype

### Objectives

1. Demonstrate TRIPSAFE core concept reliably to judges
2. Execute full **golden path**: Discover → Plan → Itinerary → Safety → Risk → Adapt → Alternative → Updated Itinerary → Continue
3. Deliver polished UI suitable for presentation
4. Establish clean codebase structure for Stage 2 evolution

### Timeline (Suggested)

| Day | Objectives | Deliverables |
|-----|------------|--------------|
| **Day 1** | Decisions + foundation | Framework chosen; repo scaffold; mock destinations; Discovery + Planning screens |
| **Day 2** | Core planning flow | Itinerary generation/display; Safety check; Journey hub skeleton |
| **Day 3** | Hero feature | Risk alert; Adapt trip; Alternative destination; Updated itinerary |
| **Day 4** | Supporting features | Timeline, expenses, settlement, memories, trip summary; UI polish |
| **Day 5** | Demo hardening | Golden path QA; bug fixes; demo rehearsal; documentation freeze |

### Scope IN

- 16 Stage 1 screens (see NAVIGATION_MAP.md)
- 13 Stage 1 services (see SERVICE_CONTRACT.md)
- Mock JSON assets for destinations and demo scenarios
- Simulated safety and risk adaptation
- Local expense/memory/timeline storage
- Demo scenario trigger for judges
- Manual testing per TEST_CHECKLIST.md

### Scope OUT

- Backend server, cloud DB, auth, payments, booking
- Live third-party APIs
- Push notifications
- Multilingual AI chatbot (unless emergency scope promotion)
- Production deployment
- Automated E2E suite (optional only)

### Infrastructure (Stage 1)

| Component | Implementation |
|-----------|----------------|
| Application | **TEAM DECISION REQUIRED** — single client app |
| Data storage | Local / in-memory / on-device file |
| Safety intelligence | MockSafetyService + DemoScenarioService |
| Itinerary engine | Template/rule-based (default) |
| Configuration | Bundled assets |
| CI | **TEAM DECISION REQUIRED** — optional minimal |

### Data (Stage 1)

| Data type | Source |
|-----------|--------|
| Destinations | MOCK JSON |
| Activities/templates | MOCK JSON |
| Safety scenarios | MOCK JSON |
| User trip preferences | REAL (user input) |
| Expenses | REAL (user input) |
| Memories (text) | REAL |
| Safety conditions/alerts | SIMULATED |
| Alternative rankings | SIMULATED from mock catalog |

### Testing (Stage 1)

- Manual functional testing (primary)
- Golden path demo rehearsal (required)
- Optional unit tests for adaptation/safety logic
- Member 6 sign-off before presentation

### Success Criteria

- [ ] Golden path completes in demo without crash
- [ ] Hero adaptation narrative clear to non-technical judge
- [ ] UI visually cohesive (Member 5 approval)
- [ ] All P0 features DONE in FEATURE_STATUS.md
- [ ] Coder 1 integration sign-off

---

## STAGE 2 — Post-Selection / SIH Finale

### Objectives

1. Evolve prototype into **production-oriented, deployable** application
2. Replace mock/simulated layers with live services where appropriate
3. Add user accounts, persistence, security, and operational quality
4. Expand feature set toward full SIH25137 vision (including chatbot if required)

### Priorities (Ordered — subject to PDF reconciliation)

| Priority | Area | Direction |
|----------|------|-----------|
| 1 | Backend + API | REST/GraphQL server; replaces local repositories |
| 2 | Database | Persistent trip, user, expense storage |
| 3 | Authentication | User registration/login; secure sessions |
| 4 | Live travel data | Real destinations, accommodations, pricing APIs |
| 5 | Live safety data | Weather, disaster feeds, government advisories |
| 6 | Real-time updates | Push notifications for risk alerts |
| 7 | AI features | Itinerary generation LLM; multilingual chatbot |
| 8 | Testing | Automated unit, integration, E2E |
| 9 | DevOps | CI/CD, staging, production deployment |
| 10 | Operations | Monitoring, logging, error tracking, performance |

### Infrastructure Differences

| Concern | Stage 1 | Stage 2 |
|---------|---------|---------|
| Client | Standalone app | Client + API consumers |
| Storage | Local/mock | Cloud database |
| Auth | None | JWT/OAuth or equivalent |
| Safety | Simulated | LiveSafetyService + feeds |
| Destinations | JSON file | ApiDestinationRepository |
| Trips | LocalTripRepository | CloudTripRepository |
| Media | Placeholder | Cloud object storage |
| Notifications | In-app | FCM/APNs or equivalent |
| Secrets | N/A | Secure vault / env management |

### Safety Data Evolution

```
Stage 1:  DemoScenario → SafetyService.simulateRiskChange()
              ↓
Stage 2:  Weather API + Advisory API → LiveSafetyService.evaluateSafety()
              ↓
          RiskAlertService → PushNotificationService
```

Member 3 research role continues — shifts from scenario writing to data source evaluation.

### Testing Evolution

| Stage | Approach |
|-------|----------|
| Stage 1 | Manual + golden path |
| Stage 2 early | Unit tests for all services; API contract tests |
| Stage 2 late | E2E; staging environment; regression suite |

### Deployment Evolution

| Stage | Target |
|-------|--------|
| Stage 1 | Local device/emulator demo |
| Stage 2 | Staging build → production app store / hosted web |

**TEAM DECISION REQUIRED:** Cloud provider, hosting, app store accounts.

---

## Migration Strategy (Stage 1 → Stage 2)

Principle: **Replace implementations, not interfaces.**

| Stage 1 | Stage 2 action |
|---------|----------------|
| `MockSafetyService` | Implement `LiveSafetyService` same interface |
| `LocalDestinationRepository` | Implement `ApiDestinationRepository` |
| `LocalTripRepository` | Implement `CloudTripRepository` |
| In-memory state | Migration script or first-login import (TBD) |
| DemoScenarioService | Remove or dev-only |

Do not rewrite UI flows unless PDF/requirements change.

---

## Risk Register

| Risk | Mitigation |
|------|------------|
| PDF missing | Add TRIPSAFE_ORIGINAL_PLAN.pdf; reconcile docs (D-P05) |
| Framework undecided Day 1 | Coder 1 calls decision in first 4 hours |
| Hero path not done by Day 3 | Cut P2 features; focus P0 |
| Mock data inconsistent | Member 4 validation checklist |
| Stage 2 scope creep in Stage 1 | LOCKED_DECISIONS enforcement |

---

## Approval Gates

| Gate | When | Approver |
|------|------|----------|
| G0 — Docs approved | Before coding | Coder 1 + team |
| G1 — Scaffold merged | End Day 1 | Coder 1 |
| G2 — Hero path working | End Day 3 | Coder 1 + Member 6 |
| G3 — Demo ready | End Day 5 | Full team |
| G4 — Stage 2 kickoff | After selection | Coder 1 + team |

---

## Related Documents

- `PROJECT_BIBLE.md` — Product definition
- `ARCHITECTURE.md` — Technical structure
- `FEATURE_STATUS.md` — Live progress
- `LOCKED_DECISIONS.md` — Scope boundaries
