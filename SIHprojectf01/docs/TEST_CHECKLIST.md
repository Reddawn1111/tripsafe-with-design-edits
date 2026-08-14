# TRIPSAFE — Test Checklist (Stage 1)

> **Scope:** Functional prototype testing for SIH selection demo  
> **Not in scope:** Production QA, load testing, security audit (Stage 2)  
> **Last updated:** 2026-08-11

---

## Testing Types

| Type | Stage 1 | Stage 2 |
|------|---------|---------|
| Manual functional testing | **Primary** | Continues |
| Golden path demo rehearsal | **Required** | Updated for live data |
| Unit tests (services) | Optional | Required |
| Widget/UI automation | Optional | Required |
| E2E automation | No | Yes |
| Security testing | No | Yes |
| Performance / load | No | Yes |
| Penetration testing | No | If required |

---

## 1. Foundation Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| F-01 | App launches without crash | Home screen visible | Member 6 |
| F-02 | Mock data loads | Destinations list non-empty | Member 6 |
| F-03 | Demo reset clears state | Fresh trip can be created after reset | Member 6 |
| F-04 | No network required | Airplane mode: core flows work | Member 6 |

---

## 2. Navigation Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| N-01 | Forward navigation | Each golden-path screen reachable | Member 6 |
| N-02 | Back navigation | Back returns to expected screen per NAVIGATION_MAP | Member 6 |
| N-03 | Route arguments | tripId / alertId / destinationId passed correctly | Member 6 |
| N-04 | Journey hub sub-routes | Timeline, Expenses, Memories return to hub | Member 6 |

---

## 3. Discovery Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| D-01 | Featured destinations | List displays with name, region, image/placeholder | Member 6 |
| D-02 | Search | Query filters destinations | Member 6 |
| D-03 | Destination detail | Shows description, tags, verified flag, safety baseline | Member 6 |
| D-04 | Plan CTA | Navigates to Planning with correct destinationId | Member 6 |

---

## 4. Planner Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| P-01 | Form validation | End date >= start date; travelerCount >= 1 | Member 6 |
| P-02 | Trip creation | Trip saved with status `planned` | Member 6 |
| P-03 | Preferences persisted | Budget, tags, dates appear on trip | Member 6 |
| P-04 | Generate action | Creates itinerary and navigates forward | Member 6 |

---

## 5. Itinerary Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| I-01 | Days rendered | Correct day count from date range | Member 6 |
| I-02 | Items per day | At least one activity per day | Member 6 |
| I-03 | Categories/costs | Optional fields display when present | Member 6 |
| I-04 | Version increment | After adaptation, version > 1 | Member 6 |

---

## 6. Safety Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| S-01 | Initial safety check | SafetyCondition returned with score + riskLevel | Member 6 |
| S-02 | Factors displayed | At least one SafetyFactor shown | Member 6 |
| S-03 | Simulated risk change | Demo scenario updates condition | Member 6 |
| S-04 | Content quality | Alert copy realistic (Member 3 review) | Member 3 |

---

## 7. Risk Alert Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| R-01 | Alert creation | RiskAlert appears after scenario | Member 6 |
| R-02 | Severity visible | previous vs current riskLevel clear | Member 6 |
| R-03 | Recommended action | Shows `adapt_trip` for hero scenario | Member 6 |
| R-04 | Acknowledge | isAcknowledged updates | Member 6 |

---

## 8. Dynamic Adaptation Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| A-01 | Propose alternatives | >= 1 AlternativeDestinationOption | Member 6 |
| A-02 | Alternative quality | reason + safetyScore visible | Member 6 |
| A-03 | Apply alternative | Trip.primaryDestinationId updates | Member 6 |
| A-04 | Trip status | status becomes `adapted` | Member 6 |
| A-05 | Timeline event | adaptation recorded in timeline | Member 6 |
| A-06 | Updated itinerary | New destination reflected in plan | Member 6 |

---

## 9. Journey Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| J-01 | Activate trip | status `active` after safety check | Member 6 |
| J-02 | Current day | Correct day highlighted | Member 6 |
| J-03 | Mark complete | ItineraryItem.isCompleted toggles | Member 6 |
| J-04 | Continue after adapt | Journey hub shows updated plan | Member 6 |

---

## 10. Memories Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| M-01 | Add memory | Memory appears in list | Member 6 |
| M-02 | Trip association | memory.tripId correct | Member 6 |
| M-03 | Timeline integration | memory_added event (if implemented) | Member 6 |

---

## 11. Expense Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| E-01 | Add expense | Expense saved with amountInr > 0 | Member 6 |
| E-02 | List expenses | All trip expenses visible | Member 6 |
| E-03 | Total spent | getTotalSpent matches sum | Member 6 |
| E-04 | Split among | splitAmong affects settlement | Member 6 |

---

## 12. Settlement Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| ST-01 | Compute settlement | SettlementSummary generated | Member 6 |
| ST-02 | Balances | perPersonShare and balances coherent | Member 6 |
| ST-03 | Empty expenses | Graceful empty state | Member 6 |

---

## 13. Summary Testing

| # | Test | Pass criteria | Owner |
|---|------|---------------|-------|
| TS-01 | Generate summary | TripSummary with highlights | Member 6 |
| TS-02 | Adaptation count | Reflects number of adaptations | Member 6 |
| TS-03 | Complete trip | status `completed`; return home works | Member 6 |

---

## 14. Full Golden-Path Testing (Primary Demo Scenario)

**Scenario name:** `Golden Path — Shimla Landslide Adaptation` (or team-defined equivalent)

**Preconditions:**
- Demo scenario `scenario_landslide_shimla` (or equivalent) loaded
- App in fresh/demo reset state

**Steps:**

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | Open app | Home screen |
| 2 | Discover → select **Shimla** (or primary demo destination) | Destination detail |
| 3 | Plan trip (3 days, 3 travelers, sample budget) | Trip created |
| 4 | Generate itinerary | Day-by-day plan shown |
| 5 | Run safety check | Low/moderate risk displayed |
| 6 | Start journey | Active journey hub |
| 7 | Trigger demo risk scenario | Risk alert: high/critical |
| 8 | Tap Adapt Trip | Adapt flow begins |
| 9 | View alternatives | >= 1 safer alternative |
| 10 | Select alternative (e.g. **Manali** or mock equivalent) | Confirmation |
| 11 | View updated itinerary | New plan for alternative |
| 12 | Continue journey | Hub shows adapted trip |
| 13 | Add sample expense | Expense listed |
| 14 | View settlement | Balances shown |
| 15 | Add memory | Memory listed |
| 16 | View timeline | Adaptation + events visible |
| 17 | Complete trip → summary | TripSummary with adaptation noted |
| 18 | Return home | Ready for next demo |

**Pass criteria:** All 18 steps complete without crash or manual data fix within **10 minutes**.

**Owners:** Member 6 (execute), Member 5 (narration), Coder 1 (technical sign-off)

---

## 15. Future Production QA (Stage 2 — Not Run Now)

- Authentication flows
- API failure / retry behavior
- Data sync conflict resolution
- OWASP mobile security checks
- Performance benchmarks
- CI/CD pipeline gates
- Staging vs production parity

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA | Member 6 | | |
| Tech Lead | Coder 1 | | |
| Presentation | Member 5 | | |
