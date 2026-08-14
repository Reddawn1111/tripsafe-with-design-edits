# TRIPSAFE — Feature Status

> **Last updated:** 2026-08-11  
> **Initial state:** Coding has not begun — all features **NOT STARTED**

---

## Status Legend

| Status | Meaning |
|--------|---------|
| NOT STARTED | No implementation yet |
| IN PROGRESS | Active development |
| REVIEW | PR open / awaiting Coder 1 review |
| DONE | Merged to main, checklist passed |
| BLOCKED | Waiting on decision or dependency |
| POSTPONED | Stage 2 or descoped |

---

## Feature Tracking Table

| Feature | Stage | Owner | Priority | Status | Dependencies | Notes |
|---------|-------|-------|----------|--------|--------------|-------|
| Project documentation | 1 | Member 6 | P0 | IN PROGRESS | — | Phase 0 docs |
| App scaffold / repo setup | 1 | Coder 1 | P0 | NOT STARTED | T-001 framework decision | No code yet |
| Home screen | 1 | Coder 2 | P1 | NOT STARTED | App scaffold | Route `/` |
| Discovery — browse/search | 1 | Coder 2 | P1 | NOT STARTED | Destination mock data (M4), DestinationDiscoveryService | |
| Destination detail | 1 | Coder 2 | P1 | NOT STARTED | Discovery | Verified badge, safety baseline |
| Trip planning form | 1 | Coder 2 | P1 | NOT STARTED | TripPlanningService | TripPreferences |
| Itinerary generation | 1 | Coder 2 | P1 | NOT STARTED | T-005 generation method | Template/rule default |
| Itinerary display | 1 | Coder 2 | P1 | NOT STARTED | Itinerary generation | |
| Safety check screen | 1 | Coder 2 | P1 | NOT STARTED | SafetyService, Member 3 content | |
| Active journey hub | 1 | Coder 2 | P1 | NOT STARTED | JourneyService | Central navigation hub |
| Demo scenario trigger | 1 | Coder 2 | P1 | NOT STARTED | DemoScenarioService, Member 3 scenarios | Hidden/dev menu |
| Risk alert screen | 1 | Coder 2 | P0 | NOT STARTED | RiskAlertService | **Hero path** |
| Adapt trip flow | 1 | Coder 2 | P0 | NOT STARTED | TripAdaptationService | **Hero path** |
| Alternative destination picker | 1 | Coder 2 | P0 | NOT STARTED | Mock alternatives (M4) | **Hero path** |
| Updated itinerary after adaptation | 1 | Coder 2 | P0 | NOT STARTED | ItineraryGenerationService.regenerate | **Hero path** |
| Timeline | 1 | Coder 2 | P2 | NOT STARTED | TimelineService | |
| Expenses — add/list | 1 | Coder 2 | P2 | NOT STARTED | ExpenseService | |
| Settlement summary | 1 | Coder 2 | P2 | NOT STARTED | SettlementService | |
| Memories — add/list | 1 | Coder 2 | P2 | NOT STARTED | T-006 media decision | |
| Trip summary | 1 | Coder 2 | P2 | NOT STARTED | TripSummaryService | |
| Mock destination catalog | 1 | Member 4 | P1 | NOT STARTED | DATA_CONTRACT approved | JSON assets |
| Safety demo scenarios | 1 | Member 3 | P1 | NOT STARTED | DemoScenario model | At least 1 golden scenario |
| UI design system | 1 | Member 5 | P1 | NOT STARTED | T-011 brand | |
| Golden path QA | 1 | Member 6 | P0 | NOT STARTED | All P0/P1 features | Before demo |
| Presentation / demo script | 1 | Member 5 + M6 | P1 | NOT STARTED | Golden path QA | |
| Authentication | 2 | — | — | POSTPONED | Backend | Stage 2 |
| Backend API | 2 | — | — | POSTPONED | — | Stage 2 |
| Cloud database | 2 | — | — | POSTPONED | Backend | Stage 2 |
| Live safety APIs | 2 | — | — | POSTPONED | Backend | Stage 2 |
| Multilingual AI chatbot | 2 | — | — | POSTPONED | Backend, Auth | SIH25137 pitch |
| Real booking / payments | 2 | — | — | POSTPONED | — | Stage 2 |
| Production deployment | 2 | — | — | POSTPONED | Full Stage 2 stack | Stage 2 |

---

## Priority Guide (Stage 1)

| Priority | Meaning |
|----------|---------|
| P0 | Must work for golden demo |
| P1 | Core prototype — required for coherent app |
| P2 | Supporting features — include if time allows |
| P3 | Nice-to-have — cut if behind schedule |

---

## Sprint Alignment (Suggested 5-Day)

| Day | Focus |
|-----|-------|
| Day 1 | T-001–T-004 decisions, scaffold, mock data, Discovery + Planning |
| Day 2 | Itinerary gen + Safety check + Journey hub |
| Day 3 | **Hero path:** Risk alert → Adapt → Alternatives → Updated itinerary |
| Day 4 | Expenses, memories, timeline, summary, polish |
| Day 5 | QA golden path, demo rehearsal, bug fixes, freeze |

---

## Update Protocol

1. Owner updates status when work begins/ends  
2. Member 6 validates against TEST_CHECKLIST  
3. Coder 1 confirms DONE after merge to main
