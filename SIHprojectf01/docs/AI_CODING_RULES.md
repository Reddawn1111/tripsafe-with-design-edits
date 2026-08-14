# TRIPSAFE — AI CODING RULES

## PROJECT

TRIPSAFE is a mobile travel application for SIH260562.

Its core purpose is to capture, organize and manage trip-related
information.

Major user-facing areas include:

- Trip planning
- Itinerary
- Your Diary
- Journey information
- Safety awareness
- Dynamic trip adaptation

## DEVELOPMENT STAGES

Stage 1:
5-day SIH selection prototype.

Stage 2:
Post-selection evolution toward a production-oriented
application for the SIH finale.

Currently build ONLY Stage 1.

Do not implement Stage 2 infrastructure unless explicitly requested.

## SOURCE OF TRUTH

Product requirements:
docs/PROJECT_BIBLE.md

Architecture:
docs/ARCHITECTURE.md

Data models:
docs/DATA_CONTRACT.md

Services:
docs/SERVICE_CONTRACT.md

Navigation:
docs/NAVIGATION_MAP.md

Team ownership:
docs/OWNERSHIP.md

Locked decisions:
docs/LOCKED_DECISIONS.md

Feature status:
docs/FEATURE_STATUS.md

Roadmap:
docs/ROADMAP.md

Testing:
docs/TEST_CHECKLIST.md

## DEVELOPMENT RULES

1. Do not invent product requirements.
2. Follow the existing project documentation.
3. Do not rename approved models, fields, functions or routes
   without explicit approval.
4. Do not modify unrelated files.
5. Do not add packages unless necessary.
6. Do not create backend infrastructure during Stage 1.
7. Do not add Firebase, cloud databases, authentication,
   payments or booking unless explicitly requested.
8. Keep UI separate from business logic.
9. Keep data access separate from UI.
10. Use the existing service/repository contracts.
11. Prefer the smallest implementation that satisfies the task.
12. Do not over-engineer for Stage 2.
13. Do not automatically continue into additional features.
14. After completing a task, format the code.
15. Run static analysis after meaningful code changes.
16. Run relevant tests.
17. Report errors instead of hiding them.
18. Stop when the requested task is complete.

## GIT RULES

Never:

- reset Git history
- force push
- delete unrelated files
- overwrite another developer's work
- commit unless explicitly instructed

## WORKFLOW

For every task:

1. Inspect only the relevant existing files.
2. Identify dependencies.
3. Implement the requested change.
4. Format.
5. Analyze.
6. Test.
7. Report what changed.
8. Stop.

Do not automatically start the next feature.

## IMPORTANT PRODUCT CONCEPT

"Your Diary" is the user's digital trip logbook.

It is intended to allow users to keep trip-related information
such as:

- photos
- notes
- tickets
- receipts
- expenses
- places
- memories

Stage 1 should implement only the subset explicitly approved
for the current feature task.

Advanced capabilities such as OCR, cloud storage and automatic
media processing belong to future development unless explicitly
approved.

## SAFETY FEATURE

Dynamic Safety Adaptation is a major TRIPSAFE differentiator.

The intended demonstration flow is:

Safety condition changes
→ risk detected
→ user alert
→ affected plan identified
→ alternative proposed
→ itinerary adapted
→ updated journey

Stage 1 may use simulated/local data.

Do not introduce live safety APIs unless explicitly requested.

END OF RULES
