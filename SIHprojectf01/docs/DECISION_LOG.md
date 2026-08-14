# TRIPSAFE — Decision Log

> **Format:** Decision ID · Date · Decision · Reason · Status · Owner · Affected files/features  
> **Rule:** Log only real decisions. Do not fabricate history.

---

## Active Decisions

| ID | Date | Decision | Reason | Status | Owner | Affected |
|----|------|----------|--------|--------|-------|----------|
| D-001 | 2026-08-11 | Adopt **two-stage development** (Stage 1 prototype / Stage 2 production) | SIH selection requires 5-day demo; finale requires production path | **LOCKED** | Team / Coder 1 | All docs, ROADMAP |
| D-002 | 2026-08-11 | Stage 1 uses **local, mock, and simulated data only** | Reliable demo without backend dependency | **LOCKED** | Coder 1 | ARCHITECTURE, SERVICE_CONTRACT |
| D-003 | 2026-08-11 | **Dynamic Safety Adaptation** is the hero feature for Stage 1 demo | Differentiates TRIPSAFE; core narrative for judges | **LOCKED** | Member 5 + Coder 1 | PROJECT_BIBLE, NAVIGATION_MAP, TEST_CHECKLIST |
| D-004 | 2026-08-11 | **Contract-driven development** — DATA_CONTRACT and SERVICE_CONTRACT are approval gates | Parallel work without integration conflicts | **LOCKED** | Coder 1 | DATA_CONTRACT, SERVICE_CONTRACT, OWNERSHIP |
| D-005 | 2026-08-11 | **No auth, backend, DB, payments, or booking in Stage 1** | Scope control for 5-day timeline | **LOCKED** | Coder 1 | PROJECT_BIBLE, LOCKED_DECISIONS |
| D-006 | 2026-08-11 | **Repository/service abstraction** for Stage 2 swap (Mock → Live) | Extensibility without over-engineering | **LOCKED** | Coder 1 | ARCHITECTURE, SERVICE_CONTRACT |
| D-007 | 2026-08-11 | Initial documentation set populated from team Phase 0 brief + SIH25137 public context | PDF source missing; docs needed before coding | **ACTIVE** | Member 6 + Coder 1 | All docs/ |
| D-008 | 2026-08-11 | **Multilingual AI chatbot postponed to Stage 2** | Present in SIH25137 pitch but not Stage 1 hero path | **POSTPONED** | Team | LOCKED_DECISIONS, ROADMAP |
| D-009 | 2026-08-11 | **Coder 1** owns architecture approval and **main** branch merges | Clear technical authority | **LOCKED** | Team | OWNERSHIP |
| D-010 | 2026-08-11 | **Member 4** proposes schema changes; **Coder 1** approves | Data consistency | **LOCKED** | Team | OWNERSHIP, DATA_CONTRACT |

---

## Pending Decisions (TEAM DECISION REQUIRED)

| ID | Date | Topic | Status | Owner | Notes |
|----|------|-------|--------|-------|-------|
| D-P01 | 2026-08-11 | Frontend framework selection | **OPEN** | Coder 1 | Blocks application scaffold |
| D-P02 | 2026-08-11 | State management library | **OPEN** | Coder 1 | |
| D-P03 | 2026-08-11 | Local persistence strategy | **OPEN** | Coder 1 | |
| D-P04 | 2026-08-11 | Stage 1 target platform | **OPEN** | Coder 1 + Member 5 | |
| D-P05 | 2026-08-11 | Add `TRIPSAFE_ORIGINAL_PLAN.pdf` to repository | **OPEN** | Member 6 | Primary source missing |
| D-P06 | 2026-08-11 | Reconcile docs with PDF after upload | **OPEN** | Coder 1 | May change scope |

---

## Decision Template (copy for new entries)

```
| D-XXX | YYYY-MM-DD | [Decision text] | [Why] | LOCKED / ACTIVE / POSTPONED / SUPERSEDED | [Owner] | [Files/features] |
```

---

## Superseded Decisions

_None yet._

---

## CONFLICT FOUND (Requires Human Resolution)

| ID | Document A | Document B | Conflict | Why it matters |
|----|------------|------------|----------|----------------|
| C-001 | SIH25137 team public pitch (LinkedIn) | Team Phase 0 documentation brief | Public pitch emphasizes **scam-free tourism, verified spots, multilingual chatbot, pricing, food/culture** without explicit **dynamic risk adaptation loop** | Stage 1 hero path may under-represent chatbot/scam features OR public pitch may under-represent adaptation — **PDF required to reconcile** |
| C-002 | `docs/TRIPSAFE_ORIGINAL_PLAN.pdf` (expected) | Current documentation set | **PDF not present in repository** | Cannot verify primary requirements; all docs marked provisional until PDF added |

**Resolution owner:** Coder 1 + full team after PDF upload.
