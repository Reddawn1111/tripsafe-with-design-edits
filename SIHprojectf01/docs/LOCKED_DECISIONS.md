# TRIPSAFE — Locked Decisions

> **Last updated:** 2026-08-11  
> **Legend:** Only decisions with team/project authority are listed as LOCKED.

---

## LOCKED

| ID | Decision | Reason | Status |
|----|----------|--------|--------|
| L-001 | **Project name: TRIPSAFE** | Established team and SIH25137 identity | LOCKED |
| L-002 | **Two-stage development strategy** | Stage 1 = 5-day selection prototype; Stage 2 = post-selection production evolution | LOCKED |
| L-003 | **Stage 1 timeline: 5 days** | SIH selection deadline | LOCKED |
| L-004 | **Stage 1 goal: demonstrable prototype, not production** | Working demo > infrastructure | LOCKED |
| L-005 | **Hero feature: Dynamic Safety Adaptation** | Primary judge-facing differentiator | LOCKED |
| L-006 | **Stage 1 data: local / mock / simulated only** | No time for infra; avoids demo failures | LOCKED |
| L-007 | **No production backend in Stage 1** | Explicit non-goal | LOCKED |
| L-008 | **No database in Stage 1** | Explicit non-goal | LOCKED |
| L-009 | **No authentication in Stage 1** | Explicit non-goal | LOCKED |
| L-010 | **No real payments or booking in Stage 1** | Explicit non-goal | LOCKED |
| L-011 | **Service/repository swap pattern for Stage 2** | e.g. MockSafetyService → LiveSafetyService | LOCKED |
| L-012 | **Contract-driven models and services** | DATA_CONTRACT + SERVICE_CONTRACT are shared truth | LOCKED |
| L-013 | **GitHub repo is single source of truth** | Team workflow | LOCKED |
| L-014 | **Coder 1 owns main branch merges** | See OWNERSHIP.md | LOCKED |
| L-015 | **SIH25137 — Travel & Tourism, Software** | Problem statement category | LOCKED |
| L-016 | **Golden path demo flow** | Discover → Plan → Itinerary → Safety → Risk → Adapt → Alternative → Updated Itinerary → Continue | LOCKED |
| L-017 | **Architecture principle: minimum clean structure** | Extensible but not over-engineered | LOCKED |

---

## TEAM DECISION REQUIRED

| ID | Topic | Notes | Blocking |
|----|-------|-------|----------|
| T-001 | **Frontend framework** | Flutter, React Native, web-only, etc. | Day 1 — blocks repo scaffold |
| T-002 | **State management approach** | Provider, Riverpod, Bloc, minimal setState | Day 1 |
| T-003 | **Local persistence** | In-memory only vs shared_preferences vs file | Day 1–2 |
| T-004 | **Target platform for Stage 1** | Android only, iOS, web, or cross-platform | Day 1 |
| T-005 | **Itinerary generation method** | Template/rules vs LLM API for Stage 1 | Day 2 |
| T-006 | **Memory media support** | Text-only vs image picker vs placeholder images | Day 3 |
| T-007 | **Navigation stack policy post-adaptation** | Replace stack vs push | Day 2 |
| T-008 | **JourneyOverview composite model** | Add to DATA_CONTRACT or inline | Day 2 |
| T-009 | **SettlementTransfer model** | Simplified debt graph or summary only | Day 3 |
| T-010 | **Minimal settings screen** | Include dev demo menu placement | Day 1 |
| T-011 | **Brand assets** | Logo, color palette final values | Day 1–2 |
| T-012 | **Add TRIPSAFE_ORIGINAL_PLAN.pdf to repo** | Primary source missing — reconcile docs after add | Immediate |

---

## POSTPONED TO STAGE 2

| ID | Item | Reason |
|----|------|--------|
| P-001 | Production backend server | Stage 1 scope |
| P-002 | Cloud database | Stage 1 scope |
| P-003 | User authentication / accounts | Stage 1 scope |
| P-004 | Live travel / accommodation APIs | Stage 1 scope |
| P-005 | Live safety / weather / environmental APIs | Stage 1 uses MockSafetyService |
| P-006 | Real-time push notifications | Stage 1 scope |
| P-007 | Payment processing | Stage 1 scope |
| P-008 | Booking transactions | Stage 1 scope |
| P-009 | Multilingual AI chatbot | SIH25137 pitch feature; not in Stage 1 hero path |
| P-010 | App store / production deployment | Stage 1 scope |
| P-011 | Automated E2E test suite | Unless team explicitly adds in Stage 1 |
| P-012 | Monitoring / logging infrastructure | Stage 2 operations |
| P-013 | Blockchain integrations | Not in team Stage 1/2 documentation |

---

## Principles (Guidance, Not Technology Locks)

| Principle | Status |
|-----------|--------|
| Working prototype > unnecessary infrastructure | LOCKED |
| Do not over-engineer for hypothetical Stage 2 | LOCKED |
| Do not rename contract fields casually | LOCKED |
| Mark uncertainty explicitly | LOCKED |

---

## How to Lock a New Decision

1. Propose in team channel / standup  
2. Log in `DECISION_LOG.md`  
3. Add row here under LOCKED  
4. Update affected contract docs  
5. Coder 1 confirms

Do **not** move items to LOCKED without team awareness.
