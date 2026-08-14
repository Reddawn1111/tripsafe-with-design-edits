# TRIPSAFE — Navigation Map (Stage 1)

> **Scope:** Stage 1 selection prototype  
> **Rule:** Route names and screen names are locked after approval.  
> **Last updated:** 2026-08-11

---

## Route Naming Convention

- Route constants: `SCREAMING_SNAKE` in code; paths use `kebab-case`
- Pattern: `/feature` or `/feature/:id`

---

## 1. Entry Points

| Entry | Route | Screen | Description |
|-------|-------|--------|-------------|
| App launch | `/` | **HomeScreen** | Landing; featured destinations; CTA to Discover or continue active trip |
| Deep link (optional Stage 1) | `/trip/:tripId` | **ActiveJourneyScreen** | Resume active trip if exists |

**Back navigation:** From Home, system back exits app (mobile) or shows confirm dialog.

---

## 2. Primary Golden Path

```
HomeScreen
    ↓  [Browse destinations]
DiscoveryScreen
    ↓  [Select destination]
DestinationDetailScreen
    ↓  [Plan Trip]
PlanningScreen
    ↓  [Generate Itinerary]
ItineraryScreen
    ↓  [Run Safety Check]
SafetyCheckScreen
    ↓  [Start Journey / Continue]
ActiveJourneyScreen
    ↓  [Demo: Simulate Risk Change]  ← SIMULATED branch entry
RiskAlertScreen
    ↓  [Adapt Trip]
AdaptTripScreen
    ↓  [View Alternatives]
AlternativeDestinationScreen
    ↓  [Select alternative + Confirm]
UpdatedItineraryScreen
    ↓  [Continue Journey]
ActiveJourneyScreen
    ↓  [Complete Trip]
TripSummaryScreen
```

---

## 3. Screen Catalog

### 3.1 HomeScreen
| Property | Value |
|----------|-------|
| Route | `/` |
| Purpose | App entry; hero branding; quick actions |
| Navigates to | `DiscoveryScreen`, `ActiveJourneyScreen` (if active trip) |
| Back | Exit app |

### 3.2 DiscoveryScreen
| Property | Value |
|----------|-------|
| Route | `/discover` |
| Purpose | Browse/search destinations |
| Service | `DestinationDiscoveryService` |
| Navigates to | `DestinationDetailScreen` |
| Back | `HomeScreen` |

### 3.3 DestinationDetailScreen
| Property | Value |
|----------|-------|
| Route | `/discover/:destinationId` |
| Purpose | Destination info, verified badge, safety baseline, pricing hint |
| Navigates to | `PlanningScreen` |
| Back | `DiscoveryScreen` |

### 3.4 PlanningScreen
| Property | Value |
|----------|-------|
| Route | `/plan/:destinationId` |
| Purpose | Collect `TripPreferences`; create trip |
| Service | `TripPlanningService` |
| Navigates to | `ItineraryScreen` (after generate) |
| Back | `DestinationDetailScreen` |

### 3.5 ItineraryScreen
| Property | Value |
|----------|-------|
| Route | `/itinerary/:tripId` |
| Purpose | Display generated day-by-day plan |
| Service | `ItineraryGenerationService` |
| Navigates to | `SafetyCheckScreen` |
| Back | `PlanningScreen` (confirm discard if trip saved) |

### 3.6 SafetyCheckScreen
| Property | Value |
|----------|-------|
| Route | `/safety/:tripId` |
| Purpose | Initial safety evaluation before journey |
| Service | `SafetyService` |
| Navigates to | `ActiveJourneyScreen` |
| Back | `ItineraryScreen` |

### 3.7 ActiveJourneyScreen
| Property | Value |
|----------|-------|
| Route | `/journey/:tripId` |
| Purpose | Current day progress; hub for timeline, expenses, memories |
| Service | `JourneyService` |
| Navigates to | `TimelineScreen`, `ExpensesScreen`, `MemoriesScreen`, `RiskAlertScreen` (when alert fires), `TripSummaryScreen` (on complete) |
| Back | `HomeScreen` (trip stays active) |
| Demo | Hidden/dev **Demo Menu** → trigger `DemoScenarioService.runScenario` |

### 3.8 RiskAlertScreen
| Property | Value |
|----------|-------|
| Route | `/alert/:tripId/:alertId` |
| Purpose | Show risk alert; recommend adaptation |
| Service | `RiskAlertService` |
| Navigates to | `AdaptTripScreen` (primary), `ActiveJourneyScreen` (dismiss/monitor — if allowed) |
| Back | `ActiveJourneyScreen` |
| Modal option | May be presented as full-screen modal over journey |

### 3.9 AdaptTripScreen
| Property | Value |
|----------|-------|
| Route | `/adapt/:tripId/:alertId` |
| Purpose | Explain adaptation; confirm user wants to replan |
| Service | `TripAdaptationService` |
| Navigates to | `AlternativeDestinationScreen` |
| Back | `RiskAlertScreen` |

### 3.10 AlternativeDestinationScreen
| Property | Value |
|----------|-------|
| Route | `/alternatives/:tripId/:alertId` |
| Purpose | List ranked alternative destinations |
| Service | `TripAdaptationService.proposeAlternatives` |
| Navigates to | `UpdatedItineraryScreen` (on select + confirm) |
| Back | `AdaptTripScreen` |

### 3.11 UpdatedItineraryScreen
| Property | Value |
|----------|-------|
| Route | `/itinerary/:tripId/updated` |
| Purpose | Show regenerated itinerary after adaptation |
| Service | `ItineraryGenerationService` |
| Navigates to | `ActiveJourneyScreen` |
| Back | Disabled or confirm — adaptation should not be silently undone |

### 3.12 TimelineScreen
| Property | Value |
|----------|-------|
| Route | `/timeline/:tripId` |
| Purpose | Chronological trip events |
| Service | `TimelineService` |
| Back | `ActiveJourneyScreen` |

### 3.13 ExpensesScreen
| Property | Value |
|----------|-------|
| Route | `/expenses/:tripId` |
| Purpose | List/add/edit expenses |
| Service | `ExpenseService` |
| Navigates to | `SettlementScreen` |
| Back | `ActiveJourneyScreen` |

### 3.14 SettlementScreen
| Property | Value |
|----------|-------|
| Route | `/settlement/:tripId` |
| Purpose | Group balance summary |
| Service | `SettlementService` |
| Back | `ExpensesScreen` |

### 3.15 MemoriesScreen
| Property | Value |
|----------|-------|
| Route | `/memories/:tripId` |
| Purpose | List/add memories |
| Service | `MemoryService` |
| Back | `ActiveJourneyScreen` |

### 3.16 TripSummaryScreen
| Property | Value |
|----------|-------|
| Route | `/summary/:tripId` |
| Purpose | End-of-trip recap |
| Service | `TripSummaryService` |
| Navigates to | `HomeScreen` (new trip) |
| Back | `HomeScreen` (trip marked completed) |

---

## 4. Important Branches

### 4.1 Safety / Risk Flow (Hero)
```
SafetyCheckScreen → ActiveJourneyScreen
                         ↓ (risk change)
                   RiskAlertScreen → AdaptTripScreen
                         → AlternativeDestinationScreen
                         → UpdatedItineraryScreen → ActiveJourneyScreen
```

### 4.2 Adaptation / Replanning
- Branch entry: `recommendedAction == "adapt_trip"` on `RiskAlert`
- Exit: updated itinerary + trip status `"adapted"`
- Timeline records adaptation events

### 4.3 Expenses Branch
```
ActiveJourneyScreen → ExpensesScreen → SettlementScreen
```

### 4.4 Memories Branch
```
ActiveJourneyScreen → MemoriesScreen
```

### 4.5 Summary Branch
```
ActiveJourneyScreen → [Complete Trip] → TripSummaryScreen → HomeScreen
```

---

## 5. Navigation Stack Expectations

| Flow | Stack behavior |
|------|----------------|
| Golden path forward | Push new route; prior screens remain in stack until hub |
| Active Journey hub | Central stack anchor during trip; sub-screens pop back to hub |
| Post-adaptation | `UpdatedItineraryScreen` → replace or clear stack to `ActiveJourneyScreen` (**TEAM DECISION REQUIRED:** exact stack policy) |
| Trip complete | Clear trip stack; land on `TripSummaryScreen` then `HomeScreen` |
| Demo reset | Return to `HomeScreen`; clear local trip state |

---

## 6. Route Constants Reference

| Constant | Path |
|----------|------|
| `ROUTE_HOME` | `/` |
| `ROUTE_DISCOVER` | `/discover` |
| `ROUTE_DESTINATION_DETAIL` | `/discover/:destinationId` |
| `ROUTE_PLAN` | `/plan/:destinationId` |
| `ROUTE_ITINERARY` | `/itinerary/:tripId` |
| `ROUTE_SAFETY` | `/safety/:tripId` |
| `ROUTE_JOURNEY` | `/journey/:tripId` |
| `ROUTE_ALERT` | `/alert/:tripId/:alertId` |
| `ROUTE_ADAPT` | `/adapt/:tripId/:alertId` |
| `ROUTE_ALTERNATIVES` | `/alternatives/:tripId/:alertId` |
| `ROUTE_ITINERARY_UPDATED` | `/itinerary/:tripId/updated` |
| `ROUTE_TIMELINE` | `/timeline/:tripId` |
| `ROUTE_EXPENSES` | `/expenses/:tripId` |
| `ROUTE_SETTLEMENT` | `/settlement/:tripId` |
| `ROUTE_MEMORIES` | `/memories/:tripId` |
| `ROUTE_SUMMARY` | `/summary/:tripId` |

---

## 7. Screens NOT in Stage 1 Scope

| Screen | Status |
|--------|--------|
| LoginScreen | **POSTPONED TO STAGE 2** |
| ChatbotScreen | **POSTPONED TO STAGE 2** |
| BookingScreen | **POSTPONED TO STAGE 2** |
| PaymentScreen | **POSTPONED TO STAGE 2** |
| SettingsScreen | **TEAM DECISION REQUIRED** (minimal settings optional) |

---

## 8. Owner

| Area | Owner |
|------|-------|
| Navigation implementation | Coder 2 |
| Route approval | Coder 1 |
| UX flow review | Member 5 |
