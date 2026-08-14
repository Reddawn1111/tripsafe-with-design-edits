# TRIPSAFE — Team Ownership

> **Last updated:** 2026-08-11  
> **Team:** GLITCH-X (SIH25137)

---

## Team Roster

| ID | Role | Focus |
|----|------|-------|
| **Coder 1** | Tech Lead | Architecture, integration, Git main, final technical decisions |
| **Coder 2** | Feature Developer | Screen + service implementation |
| **Member 3** | Research + Safety Intelligence | Safety scenarios, risk logic content, demo narratives |
| **Member 4** | Data Management | Mock data, JSON assets, schema/data contract support |
| **Member 5** | UI/UX + Branding + Presentation | Design, visuals, demo story, pitch alignment |
| **Member 6** | QA + Documentation + Demo | Testing, docs upkeep, demo scripts, rehearsal |

---

## Individual Responsibilities

### Coder 1 — Tech Lead

**Owns:**
- Overall technical architecture (`ARCHITECTURE.md`)
- Service and repository interfaces
- GitHub `main` branch protection and merge approval
- Final technical integration decisions
- Resolving technical blockers between Coder 2 and support members
- Framework/tooling choices (with team input)
- Code review for all PRs to `main`

**Does NOT unilaterally own:**
- Visual design final sign-off (shared with Member 5)
- Mock destination content copy (Member 4 + 3)

---

### Coder 2 — Feature Developer

**Owns:**
- UI screen implementation per `NAVIGATION_MAP.md`
- Wiring services to screens
- Shared widget implementation
- Feature branches for assigned `FEATURE_STATUS` items
- Unit tests for assigned services (if time permits)

**Reports to:** Coder 1 for architecture and merge

---

### Member 3 — Research + Safety Intelligence

**Owns:**
- Safety scenario research (landslide, flood, weather, etc.)
- `safety_scenarios.json` / `DemoScenario` content
- Risk alert copy (titles, messages, recommended actions)
- Alternative destination rationale text (`reason` fields)
- Validation that hero demo narrative is realistic for judges

**Collaborates with:** Member 4 (data files), Member 5 (presentation wording)

---

### Member 4 — Data Management

**Owns:**
- Mock JSON assets (`assets/mock/`)
- Destination catalog completeness and consistency with `DATA_CONTRACT.md`
- Data validation (required fields, IDs, references)
- Schema change proposals (draft PRs to `DATA_CONTRACT.md`)
- Seed data for golden-path demo

**Schema approval:** Proposes changes; **Coder 1 approves**

---

### Member 5 — UI/UX + Branding + Presentation

**Owns:**
- Visual design system (colors, typography, spacing)
- Screen mockups / wireframes
- App branding (logo, name treatment, icon — **TEAM DECISION REQUIRED** for final assets)
- Demo script and presentation slide alignment
- UX review of navigation flows

**Design approval:** Member 5 leads; **Coder 1 confirms feasibility**

---

### Member 6 — QA + Documentation + Demo

**Owns:**
- `TEST_CHECKLIST.md` execution
- `FEATURE_STATUS.md` updates during development
- Demo rehearsal and reset procedures
- Bug reporting and regression tracking
- Keeping docs in sync after decisions (with Coder 1 review)
- Golden-path walkthrough before submission

---

## Authority Matrix (No Conflicts)

| Decision | Primary owner | Approver | Notes |
|----------|---------------|----------|-------|
| Architecture | Coder 1 | — | Documented in `ARCHITECTURE.md` |
| GitHub `main` merges | Coder 1 | — | All PRs require Coder 1 review |
| Data/schema changes | Member 4 (propose) | Coder 1 (approve) | Update `DATA_CONTRACT.md` |
| Service API changes | Coder 1 | Coder 2 (implement) | Update `SERVICE_CONTRACT.md` |
| Design / UX | Member 5 | Coder 1 (feasibility) | |
| Safety content | Member 3 | Member 6 (demo test) | |
| Testing sign-off (Stage 1) | Member 6 | Coder 1 | Before demo freeze |
| Final technical integration | **Coder 1** | — | Single authority |
| Product scope change | Coder 1 + Member 5 | Full team notify | Log in `DECISION_LOG.md` |
| Locked decisions | Coder 1 | — | Update `LOCKED_DECISIONS.md` |

---

## Module Ownership Map

| Module / Feature | Implementation owner | Content/data owner | QA owner |
|------------------|---------------------|-------------------|----------|
| Discovery | Coder 2 | Member 4 | Member 6 |
| Planning | Coder 2 | Member 5 (UX) | Member 6 |
| Itinerary generation | Coder 2 | Member 4 | Member 6 |
| Safety check | Coder 2 | Member 3 | Member 6 |
| Risk alert | Coder 2 | Member 3 | Member 6 |
| Adapt trip / alternatives | Coder 2 | Member 3 + 4 | Member 6 |
| Active journey | Coder 2 | Member 5 | Member 6 |
| Timeline | Coder 2 | Member 4 | Member 6 |
| Expenses / settlement | Coder 2 | Member 4 | Member 6 |
| Memories | Coder 2 | Member 5 | Member 6 |
| Trip summary | Coder 2 | Member 5 | Member 6 |
| Demo scenario tooling | Coder 2 | Member 3 + 6 | Member 6 |
| Documentation | Member 6 | Coder 1 (review) | — |

---

## Communication Rules

1. Schema or service changes → update contract docs **before** implementation merge.
2. Scope changes → log in `DECISION_LOG.md` same day.
3. Blockers > 2 hours → escalate to Coder 1.
4. Demo-breaking bugs → Member 6 tags Coder 1 immediately.

---

## Escalation Path

```
Feature issue → Coder 2
       ↓
Architecture / integration → Coder 1
       ↓
Scope / product → Coder 1 + Member 5 → full team
```
