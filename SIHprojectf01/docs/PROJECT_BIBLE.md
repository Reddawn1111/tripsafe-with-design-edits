# TRIPSAFE — Project Bible

> **Document status:** Initial architecture phase  
> **Last updated:** 2026-08-11  
> **Primary source:** `docs/TRIPSAFE_ORIGINAL_PLAN.pdf` (**MISSING FROM REPOSITORY — see § Source of Truth**)  
> **Problem statement reference:** SIH25137 — Travel & Tourism (Software)

---

## 1. Project Name

**TRIPSAFE**

Tagline (from team public pitch): *AI-Driven Solution for Scam-Free Tourism, Authentic Food & Culture Discovery*

---

## 2. Problem

Indian domestic and inbound tourists face recurring pain points when planning and taking trips:

- **Safety uncertainty** — weather, environmental, or local risk conditions can change during a trip; travelers often lack timely guidance on whether to continue, delay, or reroute.
- **Scam and transparency risk** — unverified destinations, opaque pricing, and unreliable recommendations reduce trust (aligned with SIH25137 team pitch).
- **Fragmented planning** — discovery, itinerary creation, expense tracking, and trip memories are usually handled across separate tools with no unified “living trip” experience.
- **Poor adaptability** — most travel apps generate a static plan but do not help the traveler **adapt** when conditions change.

TRIPSAFE addresses these by combining **discovery, AI-assisted planning, safety monitoring, dynamic trip adaptation, journey tracking, expenses, and memories** in one coherent product concept.

---

## 3. Target Users

| User | Description |
|------|-------------|
| **Primary** | Indian tourists and student/travel groups planning short-to-medium leisure or cultural trips |
| **Secondary** | Travel companions sharing expenses and memories on the same trip |
| **Demo audience (Stage 1)** | SIH selection judges evaluating prototype clarity, safety intelligence, and end-to-end user journey |

---

## 4. Solution

TRIPSAFE is a **travel companion application** that helps users:

1. **Discover** verified destinations and experiences
2. **Plan** a trip with preferences (dates, budget, interests)
3. **Generate** a personalized itinerary
4. **Monitor safety** through checks and simulated/live risk conditions
5. **Receive risk alerts** when conditions change
6. **Adapt the trip** — including suggesting an **alternative destination** and producing an **updated itinerary**
7. **Continue the journey** with timeline, expenses, memories, and a trip summary

Stage 1 delivers this as a **polished, demonstrable prototype** using local/mock/simulated data.  
Stage 2 evolves the same codebase toward production infrastructure.

---

## 5. Product Vision

**Long-term vision:** A trustworthy, intelligent travel companion that keeps tourists safe, informed, and scam-aware while helping them discover authentic culture and manage the full trip lifecycle.

**Stage 1 vision:** Prove the core TRIPSAFE concept reliably in a 5-day selection prototype — especially the **dynamic safety → alert → adapt → continue** loop.

**Stage 2 vision:** Production-ready deployment for the SIH finale with real backends, persistent data, authentication, live APIs, and operational quality (security, monitoring, testing, scalability).

---

## 6. Core User Journey

### Hero demonstration path (Stage 1 priority)

```
DISCOVER
    ↓
PLAN TRIP
    ↓
GENERATE ITINERARY
    ↓
SAFETY CHECK
    ↓
SAFETY CONDITION / RISK CHANGE
    ↓
RISK ALERT
    ↓
ADAPT TRIP
    ↓
ALTERNATIVE DESTINATION
    ↓
UPDATED ITINERARY
    ↓
CONTINUE JOURNEY
```

### Extended journey (Stage 1 supporting flows)

During and after the adapted trip, users may also access:

- **Active Journey** — current day progress
- **Timeline** — chronological trip events
- **Memories** — photos/notes/moments
- **Expenses** — track and split costs
- **Settlement** — group balance summary
- **Trip Summary** — end-of-trip recap

See `docs/NAVIGATION_MAP.md` for screen-level detail.

---

## 7. MVP Scope

“MVP” in this project refers to the **Stage 1 selection prototype** (5 days).

### STAGE 1 — 5-DAY SELECTION PROTOTYPE

#### A. Discovery & Planning
| Feature | Stage 1 expectation |
|---------|---------------------|
| Browse/search destinations | Mock/local catalog |
| Destination detail | Verified-style metadata from mock data |
| Trip creation form | Dates, budget, travelers, interests |
| Itinerary generation | Rule/template or simplified AI-style generation from mock services |

#### B. Safety & Dynamic Adaptation (Hero)
| Feature | Stage 1 expectation |
|---------|---------------------|
| Initial safety check | Simulated safety scores/conditions |
| Risk condition change | Demo-triggered or scripted scenario |
| Risk alert UI | Clear alert with severity and recommendation |
| Adapt trip flow | User accepts adaptation |
| Alternative destination | Suggest from mock catalog |
| Updated itinerary | Regenerated plan for new destination |

#### C. Active Journey
| Feature | Stage 1 expectation |
|---------|---------------------|
| Journey dashboard | Current day, next activity |
| Timeline | Ordered trip events |
| Continue after adaptation | Seamless transition to updated plan |

#### D. Trip Lifecycle Support
| Feature | Stage 1 expectation |
|---------|---------------------|
| Expenses | Manual entry, local persistence |
| Settlement | Simple group split summary |
| Memories | Local notes/placeholders (media: TEAM DECISION REQUIRED) |
| Trip summary | End screen with highlights |

#### E. Foundation
| Feature | Stage 1 expectation |
|---------|---------------------|
| Navigation | Full golden-path routing |
| Mock data layer | JSON or in-memory repositories |
| Simulated safety | `MockSafetyService` pattern |
| Demo mode | Reliable scripted path for judges |

---

### STAGE 2 — POST-SELECTION / SIH FINALE

**Not built during Stage 1.** Documented for direction only.

| Area | Stage 2 direction |
|------|-----------------|
| Backend | REST/GraphQL API server |
| Database | Persistent cloud storage |
| Authentication | User accounts, sessions |
| Travel data | Live destination/accommodation APIs |
| Safety data | Live weather, disaster, advisory feeds |
| Real-time | Push notifications, live updates where appropriate |
| AI chatbot | Multilingual support (from SIH25137 pitch — **POSTPONED TO STAGE 2**) |
| Production QA | Automated tests, CI/CD, monitoring |
| Deployment | App store / web hosting |
| Security & performance | Hardening, scaling |

See `docs/ROADMAP.md` for phased detail.

---

## 8. Hero Feature

**Dynamic Safety Adaptation**

When safety conditions change mid-trip, TRIPSAFE does not leave the traveler stranded with a static plan. It:

1. Detects or receives a risk change
2. Surfaces a **Risk Alert**
3. Guides the user through **Adapt Trip**
4. Proposes an **Alternative Destination**
5. Delivers an **Updated Itinerary**
6. Lets the user **Continue Journey**

This is the primary judge-facing differentiator for Stage 1.

---

## 9. Constraints

| Constraint | Detail |
|------------|--------|
| Timeline | **5 days** for Stage 1 prototype |
| Team size | 2 coders + 4 support members |
| Infrastructure | **No backend, database, or auth in Stage 1** unless explicitly approved |
| Data | Local, mock, simulated, or placeholder only in Stage 1 |
| Goal | Demonstration reliability > production completeness |
| Architecture | Clean and extensible, but **not over-engineered** |
| Source plan | `docs/TRIPSAFE_ORIGINAL_PLAN.pdf` must be added to repo for full requirement traceability |

---

## 10. Technology Decisions

| Decision | Status | Notes |
|----------|--------|-------|
| Mobile + software app (SIH25137 category) | **LOCKED** | Problem statement category: Software / Mobile and Web Solutions |
| Stage 1: local/mock data only | **LOCKED** | Per two-stage strategy |
| Stage 1: no production backend | **LOCKED** | Per two-stage strategy |
| Repository/service abstraction for Stage 2 swap | **LOCKED** | e.g. `MockSafetyService` → `LiveSafetyService` |
| Frontend framework (Flutter, React Native, etc.) | **TEAM DECISION REQUIRED** | Not specified in available sources |
| State management library | **TEAM DECISION REQUIRED** | Not specified in available sources |
| Local persistence mechanism | **TEAM DECISION REQUIRED** | e.g. in-memory vs local file vs on-device store |
| Itinerary generation approach (rules vs LLM API) | **TEAM DECISION REQUIRED** | Stage 1 may use templates/rules; Stage 2 may use live AI |
| Multilingual AI chatbot | **POSTPONED TO STAGE 2** | Mentioned in SIH25137 team pitch, not in Stage 1 hero path |

See `docs/LOCKED_DECISIONS.md` and `docs/ARCHITECTURE.md`.

---

## 11. Development Principles

1. **Working prototype first** — a reliable demo beats premature infrastructure.
2. **Clean, extensible structure** — interfaces that allow Stage 2 replacement without rewrite.
3. **Minimum necessary abstraction** — no speculative enterprise patterns.
4. **Contract-driven development** — models (`DATA_CONTRACT.md`) and services (`SERVICE_CONTRACT.md`) are shared truth; do not rename casually.
5. **Golden path reliability** — the hero journey must work every demo.
6. **Beginner-friendly codebase** — understandable layers for “vibe coding” with AI assistance.
7. **Document uncertainty** — use `TEAM DECISION REQUIRED`, never silent guesses.
8. **Single Git source of truth** — all changes tracked; main branch protected per `OWNERSHIP.md`.

---

## 12. Explicit Non-Goals

### Stage 1 non-goals
- Production backend server
- Cloud database
- User authentication / accounts
- Real payment processing or booking transactions
- Live third-party travel API integration
- Live safety/environmental API integration
- Real-time push notification infrastructure
- App store deployment
- Multilingual AI chatbot (unless team explicitly promotes to Stage 1)
- Blockchain integrations (not supported by current team documentation)
- Geo-fencing / government incident response system (different SIH problem domain)

### Stage 2 non-goals (until explicitly scoped)
- Specific cloud provider choice
- Specific AI/LLM vendor
- Full production compliance certification

---

## 13. Source of Truth Hierarchy

1. **`docs/TRIPSAFE_ORIGINAL_PLAN.pdf`** — primary product source (**currently missing from repository**)
2. **This documentation set** — team-approved contracts and architecture
3. **SIH25137 public references** — supplementary context only; not a substitute for the PDF

> **Action required:** Add `docs/TRIPSAFE_ORIGINAL_PLAN.pdf` to the repository and reconcile any differences with this documentation.

---

## 14. Related Documents

| Document | Purpose |
|----------|---------|
| `ARCHITECTURE.md` | Technical structure |
| `DATA_CONTRACT.md` | Shared models |
| `SERVICE_CONTRACT.md` | Shared services |
| `NAVIGATION_MAP.md` | Screens and routes |
| `OWNERSHIP.md` | Team responsibilities |
| `LOCKED_DECISIONS.md` | Approved vs open decisions |
| `DECISION_LOG.md` | Decision history |
| `FEATURE_STATUS.md` | Feature tracking |
| `TEST_CHECKLIST.md` | Stage 1 testing |
| `ROADMAP.md` | Two-stage roadmap |
