# TRIPSAFE — Service Contract

> **Status:** Draft for team approval  
> **Rule:** Public function signatures are **locked after approval**.  
> **Last updated:** 2026-08-11

---

## Implementation Type Legend (Stage 1)

| Label | Meaning |
|-------|---------|
| **LOCAL** | On-device logic/storage, no network |
| **MOCK** | Returns bundled/static fixture data |
| **SIMULATED** | Runtime-generated behavior mimicking real systems |
| **REAL** | Live external integration — **Stage 2 only** unless noted |

---

## 1. DestinationDiscoveryService

**Purpose:** Browse and search destinations for the Discovery flow.

**Stage 1 implementation:** MOCK + LOCAL  
**Stage 2 replacement:** API-backed destination catalog

**Dependencies:** `DestinationRepository`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `getFeaturedDestinations` | none | `List<Destination>` | Home/Discovery highlights |
| `searchDestinations` | `query: String` | `List<Destination>` | Text search over name/tags/region |
| `getDestinationById` | `destinationId: String` | `Destination?` | Detail lookup |
| `getDestinationsByTags` | `tags: List<String>` | `List<Destination>` | Filter by interest tags |

---

## 2. TripPlanningService

**Purpose:** Create and manage trip records from user preferences.

**Stage 1 implementation:** LOCAL  
**Stage 2 replacement:** Cloud-synced trip service

**Dependencies:** `TripRepository`, `DestinationRepository`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `createTrip` | `destinationId: String`, `preferences: TripPreferences` | `Trip` | Creates trip in `"planned"` status |
| `getTrip` | `tripId: String` | `Trip?` | |
| `getActiveTrip` | none | `Trip?` | Current session trip (Stage 1: single active) |
| `activateTrip` | `tripId: String` | `Trip` | Sets status to `"active"` |
| `completeTrip` | `tripId: String` | `Trip` | Sets status to `"completed"` |
| `updatePreferences` | `tripId: String`, `preferences: TripPreferences` | `Trip` | Edit before generation |

---

## 3. ItineraryGenerationService

**Purpose:** Generate and regenerate day-by-day itineraries.

**Stage 1 implementation:** SIMULATED (template/rule-based)  
**Stage 2 replacement:** Backend AI / LLM itinerary engine

**Dependencies:** `TripRepository`, `ItineraryRepository`, `DestinationRepository`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `generateItinerary` | `tripId: String` | `Itinerary` | Initial plan from trip preferences |
| `regenerateItinerary` | `tripId: String`, `destinationId: String` | `Itinerary` | After adaptation; increments version |
| `getItinerary` | `itineraryId: String` | `Itinerary?` | |
| `getItineraryForTrip` | `tripId: String` | `Itinerary?` | Current itinerary |
| `markItemCompleted` | `tripId: String`, `itemId: String`, `completed: bool` | `Itinerary` | Journey progress |

---

## 4. SafetyService

**Purpose:** Evaluate and track safety conditions; simulate risk changes for demo.

**Stage 1 implementation:** SIMULATED  
**Stage 2 replacement:** `LiveSafetyService` with weather/advisory APIs

**Dependencies:** `SafetyRepository`, `TripRepository`, `DestinationRepository`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `evaluateSafety` | `tripId: String` | `SafetyCondition` | Initial safety check |
| `getLatestCondition` | `tripId: String` | `SafetyCondition?` | |
| `simulateRiskChange` | `tripId: String`, `scenarioId: String` | `SafetyCondition` | **Demo:** apply scenario from mock data |
| `getSafetyHistory` | `tripId: String` | `List<SafetyCondition>` | Optional timeline support |

---

## 5. RiskAlertService

**Purpose:** Create and manage user-facing risk alerts.

**Stage 1 implementation:** SIMULATED  
**Stage 2 replacement:** Push + live alert pipeline

**Dependencies:** `RiskAlertRepository`, `SafetyService`, `TimelineService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `createAlertFromCondition` | `tripId: String`, `condition: SafetyCondition` | `RiskAlert` | When risk threshold crossed |
| `getActiveAlerts` | `tripId: String` | `List<RiskAlert>` | Unresolved alerts |
| `getAlertById` | `alertId: String` | `RiskAlert?` | |
| `acknowledgeAlert` | `alertId: String` | `RiskAlert` | User seen alert |
| `resolveAlert` | `alertId: String` | `RiskAlert` | After adaptation or dismiss |

---

## 6. TripAdaptationService

**Purpose:** Propose and apply alternative destinations when risk requires adaptation.

**Stage 1 implementation:** MOCK + SIMULATED  
**Stage 2 replacement:** ML/ranking service with live availability

**Dependencies:** `DestinationRepository`, `TripRepository`, `ItineraryGenerationService`, `TimelineService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `proposeAlternatives` | `tripId: String`, `alertId: String` | `List<AlternativeDestinationOption>` | Ranked alternatives |
| `applyAlternative` | `tripId: String`, `destinationId: String`, `alertId: String` | `Trip` | Updates primary destination, status `"adapted"` |
| `getAdaptationHistory` | `tripId: String` | `List<TimelineEvent>` | Adaptation audit trail |

---

## 7. JourneyService

**Purpose:** Active journey state — current day, progress, continue flow.

**Stage 1 implementation:** LOCAL  
**Stage 2 replacement:** Same interface; may sync with backend

**Dependencies:** `TripRepository`, `ItineraryGenerationService`, `TimelineService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `getJourneyOverview` | `tripId: String` | `JourneyOverview` | **TEAM DECISION REQUIRED:** shape — likely `{ trip, itinerary, currentDayIndex, nextItem }` |
| `getCurrentDay` | `tripId: String` | `ItineraryDay?` | |
| `continueJourney` | `tripId: String` | `Trip` | Validates post-adaptation active state |

> **Note:** `JourneyOverview` composite type is **TEAM DECISION REQUIRED** for formal DATA_CONTRACT entry if promoted from inline return.

---

## 8. TimelineService

**Purpose:** Append and retrieve chronological trip events.

**Stage 1 implementation:** LOCAL  
**Stage 2 replacement:** Cloud event log

**Dependencies:** `TimelineRepository`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `addEvent` | `event: TimelineEvent` | `TimelineEvent` | |
| `getEventsForTrip` | `tripId: String` | `List<TimelineEvent>` | Sorted ascending by timestamp |
| `recordSystemEvent` | `tripId: String`, `eventType: String`, `title: String`, `description: String?`, `relatedEntityId: String?` | `TimelineEvent` | Convenience wrapper |

---

## 9. ExpenseService

**Purpose:** Track trip expenses.

**Stage 1 implementation:** LOCAL (REAL user data)  
**Stage 2 replacement:** Synced expense API

**Dependencies:** `ExpenseRepository`, `TimelineService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `addExpense` | `expense: Expense` | `Expense` | |
| `updateExpense` | `expense: Expense` | `Expense` | |
| `deleteExpense` | `expenseId: String` | `void` | |
| `getExpensesForTrip` | `tripId: String` | `List<Expense>` | |
| `getTotalSpent` | `tripId: String` | `int` | Sum in INR |

---

## 10. SettlementService

**Purpose:** Compute group expense balances.

**Stage 1 implementation:** LOCAL (computed)  
**Stage 2 replacement:** Same logic or server-side settlement

**Dependencies:** `ExpenseService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `computeSettlement` | `tripId: String` | `SettlementSummary` | Equal split among `splitAmong` |
| `getSuggestedSettlements` | `tripId: String` | `List<SettlementTransfer>` | **TEAM DECISION REQUIRED:** optional simplified `{ from, to, amountInr }` list |

---

## 11. MemoryService

**Purpose:** Capture and list trip memories.

**Stage 1 implementation:** LOCAL  
**Stage 2 replacement:** Cloud media storage + metadata API

**Dependencies:** `MemoryRepository`, `TimelineService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `addMemory` | `memory: Memory` | `Memory` | |
| `getMemoriesForTrip` | `tripId: String` | `List<Memory>` | |
| `deleteMemory` | `memoryId: String` | `void` | |

---

## 12. TripSummaryService

**Purpose:** Generate end-of-trip recap.

**Stage 1 implementation:** LOCAL (computed)  
**Stage 2 replacement:** Report API / analytics

**Dependencies:** `TripRepository`, `ExpenseService`, `MemoryService`, `ItineraryGenerationService`, `TimelineService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `generateSummary` | `tripId: String` | `TripSummary` | |
| `getSummary` | `tripId: String` | `TripSummary?` | Cached if already generated |

---

## 13. DemoScenarioService

**Purpose:** Load and trigger demo scripts for SIH presentation.

**Stage 1 implementation:** MOCK  
**Stage 2 replacement:** Remove or gate behind dev tools

**Dependencies:** `DemoScenarioRepository`, `SafetyService`, `RiskAlertService`

### Public functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `listScenarios` | none | `List<DemoScenario>` | |
| `runScenario` | `tripId: String`, `scenarioId: String` | `RiskAlert` | Executes simulate + alert pipeline |

---

## Repository Interfaces (Data Layer)

Repositories are not UI-facing but are part of the service dependency graph.

| Repository | Stage 1 | Stage 2 (example) |
|------------|---------|-------------------|
| `DestinationRepository` | LOCAL/MOCK | `ApiDestinationRepository` |
| `TripRepository` | LOCAL | `CloudTripRepository` |
| `ItineraryRepository` | LOCAL | `CloudItineraryRepository` |
| `SafetyRepository` | MOCK/SIMULATED | `LiveSafetyRepository` |
| `RiskAlertRepository` | LOCAL | `CloudRiskAlertRepository` |
| `ExpenseRepository` | LOCAL | `CloudExpenseRepository` |
| `MemoryRepository` | LOCAL | `CloudMemoryRepository` |
| `TimelineRepository` | LOCAL | `CloudTimelineRepository` |
| `DemoScenarioRepository` | MOCK | N/A |

### Standard repository operations (pattern)

Each repository should expose at minimum:

| Function | Parameters | Returns |
|----------|------------|---------|
| `getById` | `id: String` | Entity or null |
| `getAll` | none | `List<Entity>` |
| `save` | `entity: Entity` | `Entity` |
| `delete` | `id: String` | `void` |

Exact per-entity queries (e.g. `getByTripId`) are allowed without separate contract duplication.

---

## Services Explicitly POSTPONED TO STAGE 2

| Service | Reason |
|---------|--------|
| `AuthService` | No authentication in Stage 1 |
| `ChatbotService` | Multilingual AI chatbot from SIH25137 pitch |
| `BookingService` | No real bookings in Stage 1 |
| `PaymentService` | No payments in Stage 1 |
| `NotificationService` | No push infra in Stage 1 |
| `LiveWeatherService` | Replaced by `SafetyService` mock/sim in Stage 1 |

---

## Approval & Change Control

| Action | Approver |
|--------|----------|
| Approve service contract | Coder 1 (Tech Lead) |
| Add function | Coder 1 — must update FEATURE_STATUS + tests |
| Change signature | Coder 1 + affected feature owner |
