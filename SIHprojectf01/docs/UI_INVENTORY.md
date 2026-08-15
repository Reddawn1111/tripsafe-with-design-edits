# TripSafe — UI/Screen Inventory & Styling Audit

*Analysis-only audit. Nothing in the codebase was modified. All facts below were verified by reading the actual Dart source in `SIHprojectf01/lib/`, `pubspec.yaml`, and `assets/`, not inferred from documentation. Where the code and the project's own docs (`docs/NAVIGATION_MAP.md`, `docs/FEATURE_STATUS.md`) disagree, that is called out explicitly — the docs were last touched 2026‑08‑11 and are stale relative to current code.*

---

## 1. Project Overview

| | |
|---|---|
| **Frontend technology** | Flutter / Dart (SDK `^3.12.2`), Material 3 (`useMaterial3: true`) |
| **Backend technology** | None. No server, no functions, no API of its own. A repository *interface* exists for a future backend (see §Data Layer) but the only concrete implementation wired at runtime is a local in‑memory adapter. |
| **Styling technology** | Flutter's native `ThemeData`/`TextStyle` system, centralized in `lib/utils/app_theme.dart`. No CSS, no design‑token package, no Figma‑tokens pipeline. |
| **Routing** | Named routes via `onGenerateRoute` in `lib/app/routes.dart` (`AppRouter`). No GoRouter, no deep‑link package. |
| **State management** | No external package (no Provider/Riverpod/Bloc). Hand‑rolled singleton `ChangeNotifier` services (`TripPlanningService.instance`, `JourneyTrackingService.instance`, `GroupTripService.instance`, `ItineraryService.instance`) plus per‑screen `StatefulWidget` local state. |
| **Component system** | 9 hand‑built reusable widgets across 4 files in `lib/widgets/` — no Flutter package (no `flutter_hooks`, no design‑system package). |
| **Authentication** | **NONE FOUND.** No login/signup screen, no session model, no auth guard anywhere in `onGenerateRoute` or `MaterialApp`. Confirmed consistent with `docs/NAVIGATION_MAP.md §7`, which lists `LoginScreen` as "POSTPONED TO STAGE 2." |
| **Real vs. mock backends** | Two live third‑party integrations actually work today: **Geoapify Places API** (real key in `app_config.dart`) and **LocationIQ reverse‑geocoding** (real key). Firebase and Supabase repository classes exist but are stub-only (`throw UnimplementedError` on every method) and are never instantiated anywhere. |
| **Number of frontend screens** | **23 screen/sheet source files** — 19 routed named screens + 1 fallback screen (`PlaceholderScreen`) + 1 stub redirect (`DiscoveryScreen`) + 2 modal bottom sheets not on the router (`PlaceDetailSheet`, `AddStopSheet`). |
| **Number of reusable (global) components** | **9** — `PrimaryButton`, `SecondaryButton`, `AppCard`, `TripSafeAppBar`, `EmptyState`, `LoadingState`, `ErrorState`, `CityPulseCard`, `LocationSummaryCard`. |
| **Number of layouts** | **0 shared app shell.** There is no persistent bottom nav bar, drawer, or wrapper `Scaffold` — every screen builds its own `Scaffold`/`AppBar` independently. This is itself a finding (see §4). |
| **Number of forms** | **6** with actual input fields (Trip Planning parameters, Explore search box, Group join code, Add‑Expense dialog, Itinerary time picker, Privacy toggles) + 1 selection sheet with no fields (`AddStopSheet`). |
| **Number of major UI states implemented app‑wide** | Loading: partial (6/23 screens). Empty: partial (6/23, inconsistent — 2 different empty‑state patterns in use). Error: partial (3/23 have a real error UI; most just skip it). Success/confirmation: `SnackBar`‑based in most flows. See §8 for the full matrix. |

**Headline structural findings** (each detailed in its section below):
1. **6 of 23 screens are orphaned** — registered in the router but reachable from nowhere in the app: `DestinationDetailScreen`, `UpdatedItineraryScreen`, `RiskAlertScreen`, `ExpensesScreen`, `SettlementScreen` (transitively, via Expenses), `MemoriesScreen`.
2. The documented "hero path" (`docs/NAVIGATION_MAP.md §2`: Safety → Journey → Risk Alert → Adapt → Alternatives → Updated Itinerary → Journey) is **not wired as a single loop** in real code — several links are missing (see §7).
3. The 3 bundled mock JSON assets (`assets/mock/*.json`) are **completely unused** — zero references anywhere in `lib/`. All actual "demo data" is hardcoded Dart object literals inside service files instead.
4. No shared app shell/bottom navigation exists — each of the 23 screens is a leaf with its own `AppBar`, and only 1 of them (`PlaceholderScreen`) uses the shared `TripSafeAppBar` component; the other 22 hand‑roll a plain `AppBar`.
5. `LocationSummaryCard` is dead code (zero imports) and is also the one shared widget that doesn't use the design‑token system at all.

---

## 2. Complete Screen List

*Status legend used throughout: **COMPLETE** / **PARTIAL** / **MOCK** (real UI, fake data) / **PLACEHOLDER** (stub or static confirmation screen) / **ORPHANED** (unreachable via any in‑app navigation).*

1. **HomeScreen** — `lib/screens/home/home_screen.dart` · Route `/` · No auth · Parent layout: none (root) · Status: **PARTIAL**
2. **DiscoveryScreen** — `lib/screens/discovery/discovery_screen.dart` · Route `/discover` · No auth · Status: **PLACEHOLDER** (13‑line pass‑through, renders `ExploreScreen`)
3. **ExploreScreen** — `lib/screens/discovery/explore_screen.dart` · Rendered by `/discover` · No auth · Status: **COMPLETE**
4. **DestinationDetailScreen** — `lib/screens/discovery/destination_detail_screen.dart` · Route `/discover/detail` · No auth · Status: **MOCK + ORPHANED**
5. **PlaceDetailSheet** — `lib/screens/discovery/place_detail_sheet.dart` · Modal (not routed), opened from `ExploreScreen` · No auth · Status: **COMPLETE**
6. **PlanningScreen** — `lib/screens/planning/planning_screen.dart` · Route `/plan` · No auth · Status: **COMPLETE**
7. **ItineraryScreen** — `lib/screens/itinerary/itinerary_screen.dart` · Route `/itinerary` · No auth · Status: **COMPLETE**
8. **UpdatedItineraryScreen** — `lib/screens/itinerary/updated_itinerary_screen.dart` · Route `/itinerary/updated` · No auth · Status: **PLACEHOLDER + ORPHANED**
9. **AddStopSheet** — `lib/screens/itinerary/add_stop_sheet.dart` · Modal (not routed), opened from `ItineraryScreen` · No auth · Status: **PARTIAL** (mock data source)
10. **SafetyCheckScreen** — `lib/screens/safety/safety_check_screen.dart` · Route `/safety` · No auth · Status: **MOCK**
11. **ActiveJourneyScreen** — `lib/screens/journey/active_journey_screen.dart` · Route `/journey` · No auth · Status: **PARTIAL**
12. **RiskAlertScreen** — `lib/screens/risk_alert/risk_alert_screen.dart` · Route `/alert` · No auth · Status: **MOCK + ORPHANED** (dead‑code fallback data, zero inbound navigation)
13. **AdaptTripScreen** — `lib/screens/adapt_trip/adapt_trip_screen.dart` · Route `/adapt` · No auth · Status: **PARTIAL**
14. **AlternativeDestinationScreen** — `lib/screens/alternative_destination/alternative_destination_screen.dart` · Route `/alternatives` · No auth · Status: **MOCK**
15. **TimelineScreen** — `lib/screens/timeline/timeline_screen.dart` · Route `/timeline` · No auth · Status: **COMPLETE** (for its documented read‑only scope)
16. **ExpensesScreen** — `lib/screens/expenses/expenses_screen.dart` · Route `/expenses` · No auth · Status: **MOCK + ORPHANED**
17. **SettlementScreen** — `lib/screens/expenses/settlement_screen.dart` · Route `/settlement` · No auth · Status: **MOCK + ORPHANED** (only reachable from the orphaned ExpensesScreen)
18. **GroupScreen** — `lib/screens/group/group_screen.dart` · Route `/group` · No auth · Status: **PARTIAL** (self‑documented as demo‑only join logic)
19. **MemoriesScreen** — `lib/screens/memories/memories_screen.dart` · Route `/memories` · No auth · Status: **PLACEHOLDER + ORPHANED** (zero service wiring, purely hardcoded)
20. **TripSummaryScreen** — `lib/screens/trip_summary/trip_summary_screen.dart` · Route `/summary` · No auth · Status: **PARTIAL** (half real stats, half hardcoded)
21. **PrivacySettingsScreen** — `lib/screens/privacy/privacy_settings_screen.dart` · Route `/privacy` (reached via raw string, not the `AppRoutes` constant) · No auth · Status: **MOCK** (toggles are cosmetic, nothing persists)
22. **AuthorityDashboardScreen** — `lib/screens/authority/authority_dashboard_screen.dart` · Route `/authority` (reached via raw string) · No auth, no role gate despite being an "authority" screen · Status: **MOCK** (`isDemoData: true` self‑flagged in the service)
23. **PlaceholderScreen** — `lib/screens/shared/placeholder_screen.dart` · Generic fallback for `onGenerateRoute`'s default case and `onUnknownRoute` · Status: **PLACEHOLDER by design**

---

## 3. Screen‑by‑Screen UI Element Checklist

### Screen: HomeScreen
File: `home_screen.dart` (683 lines) · `StatefulWidget`, `CustomScrollView` of slivers

**Layout**
- [x] `SafeArea` → `CustomScrollView` → `SliverToBoxAdapter` sections, no shared shell

**Header / Navigation**
- [x] Custom brand row: shield icon in colored box, "TRIPSAFE" title, tagline caption, privacy `IconButton` (→ `/privacy`)
- [x] Location pill: near‑me icon + dynamic address text + refresh `InkWell`

**Content**
- [x] "What's the plan today?" heading + 3 `_ActionCard`s (Explore Nearby / Plan a Trip & Budget / Active Journey & Dwell Tracker), each with a "Live Geoapify" / "Smart Sequence" / "Live Tracking" badge
- [x] Conditional "Active Trip" card: avatar, trip title, day/traveller count, invite‑code badge, budget row + `LinearProgressIndicator`, "Next Stop" row
- [x] Safety Radar ticker: icon (warning/verified) + description + chevron → `/safety`
- [x] City Pulse teaser row → static "See what's trending nearby" + chevron
- [x] "Explore TRIPSAFE Intelligence" 2×2 `GridView` of hub tiles: Safety Radar, Trip Group, Trip Timeline, Authority Insights

**Cards / Lists**
- [x] `_ActionCard` (icon container, title+badge row, subtitle)
- [x] Active‑trip `AppCard`
- [x] Hub tile cards (`_buildHubCard`)

**Buttons / CTAs**
- [x] 3 primary action cards (tappable)
- [x] "View Plan" `TextButton`
- [x] 4 hub‑grid tiles (tappable)
- [x] Privacy `IconButton`

**Inputs / Forms**
- [ ] None on this screen

**Icons**
- [x] `Icons.shield_outlined`, near‑me, refresh, warning/verified, bolt, chevrons, per‑hub icons

**Images / Media**
- [ ] None (icon‑only, no photography)

**Typography**
- [x] Uses `AppTypography.displayMedium/titleLarge/bodyMedium/caption` throughout

**Dynamic Data**
- [x] Location text — DYNAMIC‑SERVICE (`LocationService().getCurrentLocationAddress()`)
- [x] `activeTrip` — DYNAMIC‑SERVICE (`TripPlanningService.instance.activeTrip`)
- [x] `safetyEval` — DYNAMIC‑SERVICE (`SafetyService.instance.evaluateSafety(...)`)
- [x] Hub tile list — DYNAMIC‑STATE but hardcoded config literal (not fetched)
- [ ] "TRIPSAFE" brand text, tagline, section headings, badge text — STATIC

**Loading State**
- [x] Location pill only: "Detecting GPS location..." while fetching
- [ ] No page‑level skeleton/spinner

**Empty State**
- [ ] **NOT IMPLEMENTED** — "no active trip" simply omits the whole Active Trip section; no message shown

**Error State**
- [x] Location pill: "Location unavailable · Tap to retry"
- [ ] No error handling elsewhere on the page

**Success State**
- [x] Implicit — default render once data resolves

**Interaction States**
- [ ] No custom hover/focus/disabled/pressed styling anywhere — stock `InkWell`/button ripple only

**Responsive Behavior**
- [x] `Expanded`/`Spacer`/slivers used for flex
- [ ] `GridView.count(crossAxisCount: 2)` is **hardcoded to 2 columns** regardless of width — will look sparse on tablets. No `MediaQuery`/`LayoutBuilder` breakpoints.

---

### Screen: DiscoveryScreen
File: `discovery_screen.dart` (13 lines) · `StatelessWidget`

**Layout** — [x] Single `build()` returning `const ExploreScreen();` — no UI of its own.
All other categories: **N/A — pure pass‑through wrapper.** Every element, state, and behavior lives in `ExploreScreen` below.

---

### Screen: ExploreScreen
File: `explore_screen.dart` (901 lines) · `StatefulWidget`, most feature‑complete screen in the app

**Layout**
- [x] `RefreshIndicator` → `CustomScrollView` (pull‑to‑refresh)

**Header / Navigation**
- [x] `AppBar`: "TripSafe Explore" title + location subtitle row, refresh `IconButton`, Demo Mode toggle `IconButton` (science icon)
- [x] Conditional amber "DEMO DATA" banner with "Exit Demo" link

**Content**
- [x] Search `TextField` ("Search places, cafes, sunsets...")
- [x] "What's your vibe?" horizontal `ChoiceChip` bar (10 `UserIntent` values)
- [x] `CityPulseCard` (shared widget)
- [x] "⭐ Recommended Around You" horizontal carousel (230px cards)
- [x] "🔥 Popular with TripSafe Travellers" list section
- [x] "🌅 Best Time to Visit" horizontal carousel (140px cards)
- [x] "Build a Trip Plan & Budget" CTA banner → `/plan`
- [x] "📍 All Nearby Spots (N)" full list

**Cards / Lists**
- [x] Recommended carousel card: category‑emoji icon box, name, category+distance, match% badge, reason pill, dwell/cost, "Add to Trip" button
- [x] Popular card: fire emoji icon, name, visit/review count, busiest‑hours text, bookmark icon
- [x] Best‑time card: name, "Best for", "Recommended", "Typical stay"
- [x] Standard place tile: avatar, name, category+distance, address, add icon

**Buttons / CTAs**
- [x] "Add to Trip" `OutlinedButton.icon` (recommended carousel)
- [x] "Start" `ElevatedButton` (plan‑trigger banner)
- [x] Add `IconButton` (standard tiles), bookmark `IconButton` (popular cards)
- [x] "Show All Places" reset action (empty state)
- [x] "Launch Demo Mode" / "Retry" / "Switch to Demo Mode" recovery buttons

**Inputs / Forms**
- [x] Search `TextField` — free text, optional, live‑filters via `onChanged`, no validation

**Icons**
- [x] Search, location, science(demo), category emojis, star, fire, sunrise, bookmark, chevrons

**Images / Media**
- [ ] No photography on the list cards themselves (place photos only shown in `PlaceDetailSheet`)

**Typography**
- [x] `AppTypography`/`AppSpacing` used consistently throughout

**Dynamic Data**
- [x] `_currentPosition`/`_currentAddress` — DYNAMIC‑SERVICE (`LocationService`), DYNAMIC‑MOCK Bangalore‑coordinate fallback if GPS fails
- [x] `_allNearbyPlaces`/`_rankedPlaces` — DYNAMIC‑SERVICE (live `GeoapifyPlacesNearbyService`) or DYNAMIC‑MOCK (`MockNearbyDiscoveryService`), gated by the Demo Mode toggle
- [x] City Pulse — DYNAMIC‑SERVICE (`TravelInsightsService().computeCityPulse(...)`)
- [x] Best‑time text — DYNAMIC‑SERVICE (`getBestTimeToVisitGuide`)
- [x] Search query — user input, local state

**Loading State**
- [x] Full sliver spinner + "Discovering real nearby places..." message

**Empty State**
- [x] Shared `EmptyState` widget with "Show All Places" recovery action

**Error State**
- [x] `_buildUnconfiguredState()` — dedicated "Geoapify Key Required" state with "Launch Demo Mode" CTA
- [x] `_buildErrorState()` — "Discovery Error" + Retry + "Switch to Demo Mode"

**Success State**
- [x] Full sliver‑list content render

**Interaction States**
- [x] `ChoiceChip.selected` — bold white‑on‑primary vs. normal
- [x] Demo‑mode icon changes color when active
- [x] `RefreshIndicator` pull‑to‑refresh
- [ ] No custom hover/focus/disabled styling beyond chip/button defaults

**Responsive Behavior**
- [ ] Carousel cards use **fixed pixel widths/heights** (270×230, 240×140) — will not adapt to very small or very large screens. No `MediaQuery`/`LayoutBuilder`.

---

### Screen: DestinationDetailScreen
File: `destination_detail_screen.dart` (80 lines) · `StatelessWidget` · **ORPHANED — no call site anywhere navigates here**

**Layout** — [x] `AppBar` + `SingleChildScrollView` + `AppCard` hero + bullet list + CTA button

**Header / Navigation** — [x] `AppBar` title = `destTitle` (from `destinationId` param, STATIC fallback `'Kozhikode & Coastal Circuit'`)

**Content**
- [x] Hero card: title, STATIC subtitle "South India Coastal Heritage & Sunset Promenade", 2 STATIC badge chips ("Safety Score: 92/100", "Avg: ₹2,000/day")
- [x] "Highlights & Must‑See Spots" — 4 STATIC bullet lines (none derived from `destinationId`)

**Cards / Lists** — [x] 1 hero `AppCard`

**Buttons / CTAs** — [x] `PrimaryButton` "Plan Trip to $destTitle" → `/plan`

**Inputs / Forms** — [ ] None

**Icons** — [x] route icon on CTA

**Images / Media** — [ ] None

**Typography** — [x] Standard `AppTypography` styles

**Dynamic Data** — [x] Only `destTitle` is dynamic (from constructor param); everything else (safety score, cost, highlights) is **STATIC and unrelated to the actual destination passed in**

**Loading / Empty / Error State** — [ ] **NOT IMPLEMENTED** (no async calls at all)

**Success State** — [x] Only state; always renders the same static layout

**Interaction States** — [ ] Not implemented beyond default button press

**Responsive Behavior** — [x] Scrollable, but no adaptive sizing beyond that

---

### Screen: PlaceDetailSheet
File: `place_detail_sheet.dart` (429 lines) · Modal `showModalBottomSheet`, not routed

**Layout** — [x] Drag handle → hero image banner → scrollable content

**Header / Navigation** — [x] Drag handle bar; dismissible sheet (no AppBar — it's a modal)

**Content**
- [x] Hero banner: `Image.network(place.photoUrl)` with icon‑fallback `errorBuilder`
- [x] Name + category badge
- [x] Rating, distance, price badges in a `Wrap`
- [x] "📊 Travel Pulse" card (visits/avg‑stay/busiest‑time, or empty‑data message)
- [x] Conditional recommendation‑reason box
- [x] Address row, data‑provenance row ("Source: ...")

**Cards / Lists** — [x] Travel Pulse `AppCard`

**Buttons / CTAs**
- [x] `PrimaryButton` "Add to Day Plan" / "In Itinerary" (toggle)
- [x] `OutlinedButton.icon` "Directions" — **stub: only shows a SnackBar with lat/lng, does not open a maps app**

**Inputs / Forms** — [ ] None

**Icons** — [x] star, distance pin, price tag, sun (best time), place pin

**Images / Media** — [x] `Image.network` hero banner with real fallback handling

**Typography** — [x] Standard tokens

**Dynamic Data**
- [x] `place` — DYNAMIC‑STATE (passed from caller, ultimately DYNAMIC‑SERVICE)
- [x] `guide`/`stats` — DYNAMIC‑SERVICE (`TravelInsightsService`), explicitly routed through the service "to apply k‑anonymity threshold and demo‑data gating" (code comment)
- [x] `_isAdded` — DYNAMIC‑SERVICE (`ItineraryService.instance.isPlaceInItinerary`)

**Loading State** — [ ] Not implemented (sheet receives fully‑formed data)

**Empty State** — [x] "Not enough traveller data yet — be the first to log a consented visit here."

**Error State** — [x] De facto: `Image.network` `errorBuilder` fallback to placeholder icon

**Success State** — [x] Default full render

**Interaction States** — [x] `_isAdded` toggles button label/icon/color (selected‑style state)

**Responsive Behavior** — [x] `MediaQuery` safe‑area padding, `Wrap` for badge row, `SingleChildScrollView`

---

### Screen: PlanningScreen
File: `planning_screen.dart` (539 lines) · `StatefulWidget`, reactive via `AnimatedBuilder`

**Layout** — [x] `AppBar` → `SingleChildScrollView` (Preferences card, Budget summary, Day‑plan list, CTA)

**Header / Navigation** — [x] `AppBar` "Budget & Route Planner" + conditional "Itinerary" action

**Content**
- [x] Preferences `AppCard`: destination field, 3 sliders, interest chips, generate button
- [x] Conditional Budget Summary header (Total/Planned/Remaining stat columns + budget badge)
- [x] Day‑plan list: per‑day header with auto‑optimize icon, `ReorderableListView` of stop rows
- [x] "Start Active Journey" CTA (conditional on active trip)

**Cards / Lists** — [x] Preferences card, per‑day stop cards/rows (draggable)

**Buttons / CTAs**
- [x] "Generate Plan & Route" `PrimaryButton` (disabled + relabeled "Generating Itinerary..." while busy)
- [x] Per‑day "auto‑optimize" route `IconButton`
- [x] Per‑stop remove `IconButton`
- [x] "Start Active Journey" `PrimaryButton`

**Inputs / Forms**
- [x] "Destination / Area" `TextField` — optional, no validation
- [x] Duration `Slider` (1–5 days)
- [x] Group size `Slider` (1–8)
- [x] Budget‑per‑person `Slider` (₹500–₹10,000)
- [x] "Vibes & Interests" multi‑select `FilterChip` row (7 options; **at least 1 must stay selected** — enforced in code)

**Icons** — [x] tune, place, auto‑optimize route icon, close/remove icon

**Images / Media** — [ ] None

**Typography** — [x] Standard tokens

**Dynamic Data**
- [x] Destination field initial text — DYNAMIC‑STATE from route arg, STATIC fallback otherwise
- [x] `_availableInterests` — DYNAMIC‑MOCK hardcoded 7‑item list
- [x] `activeTrip` — DYNAMIC‑SERVICE, reactive `AnimatedBuilder`
- [x] Generated plan — DYNAMIC‑SERVICE (`generatePlanFromPlaces`), sourced from live Geoapify or DYNAMIC‑MOCK fallback
- [x] GPS coordinates — DYNAMIC‑SERVICE with STATIC fallback lat/lon if GPS throws

**Loading State** — [x] Button‑level only (`_isGenerating` disables + relabels); no full‑screen skeleton

**Empty State** — [ ] **NOT IMPLEMENTED** — no active trip simply omits the summary/day‑plan sections, no message

**Error State** — [x] Red `SnackBar` "Error generating plan: $e" — no inline/retry affordance

**Success State** — [x] Green `SnackBar` "✨ Generated N‑Day Plan with N stops!"

**Interaction States**
- [x] Generate button disabled while busy
- [x] `FilterChip.selected` visual state, with a floor of 1 selected interest
- [x] Drag‑reorder via `ReorderableListView`

**Responsive Behavior** — [x] `Expanded` slider pairs, scrollable; no breakpoint logic for tablet/desktop

---

### Screen: ItineraryScreen
File: `itinerary_screen.dart` (468 lines) · `StatelessWidget` + `AnimatedBuilder` · Documented as "the canonical editing surface"

**Layout** — [x] `AppBar` → `AnimatedBuilder` → `SingleChildScrollView` (header, day cards)

**Header / Navigation** — [x] `AppBar` "Trip Itinerary & Route" + "Edit Plan Parameters" icon → `/plan`

**Content**
- [x] Trip header card: title, destination+traveller count, invite‑code badge, 4 stat columns
- [x] Per‑day cards, each with conflict banner (from `ItineraryConflictService`), reorderable stop list, "Add stop" action

**Cards / Lists**
- [x] Trip header `AppCard`
- [x] Per‑stop row: transit indicator, numbered/checkmark avatar, name (strikethrough if visited/skipped), "Skipped" badge, time range, cost, popup menu

**Buttons / CTAs**
- [x] Per‑day auto‑optimize icon
- [x] Per‑stop `PopupMenuButton`: Edit time / Change place / Insert stop after / Skip‑Unskip / Delete
- [x] "Add stop" `TextButton.icon` per day
- [x] "Start Active Journey" `PrimaryButton`, "View Group & Invite Code" `OutlinedButton.icon`

**Inputs / Forms** — [x] `showTimePicker` native dialog for "Edit time" (no validation, cancelable)

**Icons** — [x] edit‑calendar, car (transit), checkmark, warning (conflict), popup‑menu dots

**Images / Media** — [ ] None

**Typography** — [x] Standard tokens

**Dynamic Data**
- [x] `trip` — DYNAMIC‑SERVICE, reactive
- [x] `conflicts` — DYNAMIC‑SERVICE (`ItineraryConflictService().detectConflicts(day)`)
- [x] All stop mutations (reorder, skip, remove, retime, replace, insert, optimize) — real DYNAMIC‑SERVICE calls
- [x] New/replacement place — DYNAMIC‑MOCK (sourced from `AddStopSheet` → `MockNearbyDiscoveryService`)

**Loading State** — [ ] **NOT IMPLEMENTED**

**Empty State** — [x] Shared `EmptyState` widget with icon + "Explore Nearby Places" action — well implemented

**Error State** — [ ] **NOT IMPLEMENTED**

**Success State** — [x] Full itinerary render

**Interaction States**
- [x] `isVisited`/`isSkipped` drive avatar color, strikethrough, badge
- [x] Drag‑reorder, popup‑menu selection

**Responsive Behavior** — [x] `Expanded`/`Flexible` prevent text overflow in rows; no tablet/desktop breakpoints

---

### Screen: UpdatedItineraryScreen
File: `updated_itinerary_screen.dart` (58 lines) · `StatelessWidget` · **ORPHANED — no call site navigates here anywhere in `lib/`**

**Layout** — [x] `AppBar` → success banner → single CTA

**Content** — [x] Success banner: check‑circle icon, "Itinerary Successfully Adapted!" STATIC title, STATIC description about coastal stops replaced with inland ones

**Buttons / CTAs** — [x] "View Full Itinerary" `PrimaryButton` → `/itinerary`

**Dynamic Data** — [ ] **Everything is STATIC hardcoded text.** `tripId` constructor param exists but is never read or displayed.

**Loading / Empty / Error State** — [ ] **NOT IMPLEMENTED** (no async at all)

**Success State** — [x] The entire screen *is* a static success confirmation with no real backing data

**Interaction States** — [ ] Only the one button's default press

**Responsive Behavior** — [ ] No `SingleChildScrollView` — long text could overflow on very small screens (the one screen among its peer group lacking scroll‑overflow protection)

---

### Screen: AddStopSheet
File: `add_stop_sheet.dart` (137 lines) · Modal `showModalBottomSheet<Place>`, not routed · Doc comment explicitly says it intentionally uses mock data "rather than a new live‑search picker... works offline and in tests"

**Layout** — [x] `DraggableScrollableSheet` (0.4–0.9 of screen height)

**Content** — [x] Drag handle, title text ("Add a Stop" / "Change to..."), candidate list

**Cards / Lists** — [x] `ListTile` rows: category‑icon avatar, name, "category · N min visit" subtitle

**Buttons / CTAs** — [ ] No explicit buttons — tapping a row returns the selected place

**Inputs / Forms** — [ ] None (no in‑sheet search field)

**Dynamic Data** — [x] `_candidates` — **DYNAMIC‑MOCK**, explicitly sourced from `MockNearbyDiscoveryService`, never live search

**Loading State** — [x] Centered `CircularProgressIndicator` while `_isLoading`

**Empty State** — [ ] **NOT IMPLEMENTED** — empty candidate list just renders zero rows silently

**Error State** — [ ] **NOT IMPLEMENTED** — no try/catch around the load call; an exception would be unhandled

**Success State** — [x] Default list render

**Responsive Behavior** — [x] `DraggableScrollableSheet` adapts to available height; no width‑based adaptation

---

### Screen: SafetyCheckScreen
File: `safety_check_screen.dart` (231 lines) · `StatelessWidget`

**Layout** — [x] `AppBar` → `SingleChildScrollView` (score card, advisories, live‑conditions, checklist, CTA)

**Header / Navigation** — [x] `AppBar` "Safety Radar & Advisories"

**Content**
- [x] Safety score card: `CircleAvatar` numeric badge, status heading, destination subtitle
- [x] Active advisories section (conditional, only if alerts exist — no "no alerts" message when empty)
- [x] "Live Conditions Overlay" card: weather/crowd summary text
- [x] "TripSafe Essential Checklist": guideline rows with green checks

**Cards / Lists** — [x] Score card, alert cards, checklist card

**Buttons / CTAs** — [x] Per‑alert "Adapt Trip Plan" `TextButton.icon` → `/adapt`; bottom "Proceed to Itinerary" `PrimaryButton` → `/itinerary`

**Inputs / Forms** — [ ] None

**Icons** — [x] warning, sun, green check marks

**Dynamic Data**
- [x] `eval` (score/status/alerts/weather/crowd/guidelines) — DYNAMIC‑SERVICE call, but the service itself is entirely **rule‑based string‑matching** on the destination name (3 canned scenarios: coastal / mountain / default) — effectively MOCK underneath a real call shape

**Loading / Error State** — [ ] **NOT IMPLEMENTED** (synchronous, never throws)

**Empty State** — [ ] **NOT IMPLEMENTED** — when there are no active alerts, the section is silently omitted rather than showing a "you're clear" message

**Success State** — [x] Always renders (evaluation never fails)

**Interaction States** — [ ] Not implemented beyond default

**Responsive Behavior** — [x] Scrollable, `Expanded` text wrapping; no breakpoints

---

### Screen: ActiveJourneyScreen
File: `active_journey_screen.dart` (430 lines) · `StatefulWidget`, reactive via `AnimatedBuilder`

**Layout** — [x] `AppBar` → `SingleChildScrollView` (live status, spontaneous alert, current stop, planned‑vs‑observed, actions)

**Header / Navigation** — [x] `AppBar` "Active Journey Tracker" + timeline icon → `/timeline`

**Content**
- [x] Live status gradient banner: "TRACKING ACTIVE" pill, stop‑count text, trip title, `LinearProgressIndicator`
- [x] Conditional "Spontaneous Stop Detected!" alert card (Dismiss / Add This Stop)
- [x] Current‑stop‑focus card: target stop name, category+time window, dwell timer, "Verify Dwell & Complete Stop" button
- [x] Two‑column "Planned vs. Observed" comparison
- [x] Amber "Demo: Simulate GPS dwell deviation" banner with "Simulate Stop" action

**Cards / Lists** — [x] Live status banner, spontaneous‑stop card, current‑stop `AppCard`

**Buttons / CTAs** — [x] "Verify Dwell & Complete Stop" `PrimaryButton`; "End Journey" `OutlinedButton.icon` → `/summary`; "View Timeline" `PrimaryButton` → `/timeline`; demo "Simulate Stop" `TextButton`

**Inputs / Forms** — [ ] None

**Dynamic Data**
- [x] `activeTrip` — DYNAMIC‑SERVICE, but underlying data is a single hardcoded demo trip (`_initSampleTrip()`)
- [x] `currentIdx`/`observedStops`/`pendingSpontaneousStop` — DYNAMIC‑SERVICE (`JourneyTrackingService`), a real `ChangeNotifier` but **no live GPS is actually read** — everything is manually/demo‑triggered

**Loading State** — [ ] **NOT IMPLEMENTED**

**Empty State** — [x] Shared `EmptyState` — "No active trip found to track..."

**Error State** — [ ] **NOT IMPLEMENTED**

**Success State** — [x] Main scroll content

**Interaction States** — [ ] No custom hover/disabled/pressed states; buttons always enabled (no double‑tap guard on "Verify Dwell")

**Responsive Behavior** — [x] `SingleChildScrollView` + `Expanded` rows; no breakpoints

---

### Screen: RiskAlertScreen
File: `risk_alert_screen.dart` (131 lines) · `StatelessWidget` · **ORPHANED — confirmed zero inbound `Navigator.push*` calls anywhere in `lib/`**

**Layout** — [x] `AppBar` → `Padding`/`Column` (no scroll view — the one screen in this set that lacks overflow protection)

**Content**
- [x] Warning banner: icon, alert title, category+affected‑area text
- [x] "Advisory Details" card: description, "Recommended Protocol" text
- [x] Conditional "Suggested Safe Alternatives" list

**Buttons / CTAs** — [x] "Adapt My Trip Plan" `PrimaryButton` → `/adapt`; "Dismiss Advisory" `OutlinedButton` (pops)

**Dynamic Data** — [x] `alert` is sourced from `SafetyService.instance.evaluateSafety('Coastal Tourism Corridor')` — a **hardcoded literal destination string**, ignoring the screen's own `tripId`/`alertId` constructor params entirely. A separate hardcoded `SafetyRiskAlert` literal in the same method is unreachable dead code given current service logic.

**Loading / Empty / Error State** — [ ] **NOT IMPLEMENTED** (alert is guaranteed non‑null via fallback logic)

**Success State** — [x] Always renders the single alert

**Responsive Behavior** — [ ] No scroll view; long alternatives lists could overflow

---

### Screen: AdaptTripScreen
File: `adapt_trip_screen.dart` (171 lines) · `StatelessWidget`

**Layout** — [x] `AppBar` → info banner → `ListView.builder` → bottom CTA

**Content** — [x] "Smart Route Adaptation" info banner; "Recommended Safe Replacements:" list

**Cards / Lists** — [x] Per‑alternative `AppCard`: emoji avatar, name, category+rating, cost line, "Swap Stop" button

**Buttons / CTAs** — [x] "Swap Stop" `ElevatedButton` (per item); "Browse All Alternative Destinations" `PrimaryButton` → `/alternatives`

**Dynamic Data**
- [x] `safeAlternatives` — **DYNAMIC‑MOCK**, 3 fully hardcoded `Place` literals, unrelated to the actual `alertId`
- [x] "Swap Stop" action — genuinely calls DYNAMIC‑SERVICE `TripPlanningService.addPlaceToTrip()`, a real state mutation

**Loading / Empty / Error State** — [ ] **NOT IMPLEMENTED** (list is a fixed non‑empty literal)

**Success State** — [x] Green `SnackBar` "Replaced with $name! Itinerary updated."

**Interaction States** — [ ] No debounce guard against double‑tapping "Swap Stop"

**Responsive Behavior** — [x] `Expanded` + `ListView.builder`; no breakpoints

---

### Screen: AlternativeDestinationScreen
File: `alternative_destination_screen.dart` (112 lines) · `StatelessWidget` · Only reachable from `AdaptTripScreen`

**Layout** — [x] `AppBar` → `ListView.builder`

**Cards / Lists** — [x] Per‑destination `AppCard`: name + "Safe (Score NN)" badge, vibe text, highlights text, cost + "Select Destination" button

**Buttons / CTAs** — [x] "Select Destination" `ElevatedButton` → `/plan` with `destinationId` arg

**Dynamic Data** — [x] `alternatives` — **DYNAMIC‑MOCK**, a hardcoded 3‑item literal list (Wayanad/Mysuru/Coorg), with no connection to `SafetyService`, `tripId`, or `alertId` despite those being accepted as constructor params

**Loading / Empty / Error State** — [ ] **NOT IMPLEMENTED**

**Success State** — [x] Always‑non‑empty list render

**Interaction States** — [ ] No selected/highlighted state on tap — navigates away immediately

**Responsive Behavior** — [x] Scrollable list, `Row(spaceBetween)` reflow

---

### Screen: TimelineScreen
File: `timeline_screen.dart` (152 lines) · `StatelessWidget` · Explicitly documented as read‑only

**Layout** — [x] `AppBar` → `ListView.builder` over trip days

**Header / Navigation** — [x] `AppBar` "Journey Timeline" + edit‑calendar icon → `/itinerary`

**Content** — [x] Per‑day section with a vertical timeline: `CircleAvatar` dot (checkmark/near‑me/circle by state) + connecting line + stop card (name, start time, category, dwell, conditional "✓ Dwell verified" caption)

**Dynamic Data**
- [x] `activeTrip` — DYNAMIC‑SERVICE
- [x] `journeyService.currentStopIndex` — DYNAMIC‑SERVICE, but **only day‑1 progress is meaningful** (documented limitation in the file itself) — later days always render as "upcoming"

**Empty State** — [ ] Uses a plain `Center(Text(...))` rather than the shared `EmptyState` widget — **inconsistent pattern** vs. `ActiveJourneyScreen`/`ItineraryScreen`/`GroupScreen`

**Loading / Error State** — [ ] **NOT IMPLEMENTED**

**Interaction States** — [ ] Cards are not actually tappable (`onTap` never wired despite `AppCard`'s built‑in `InkWell`)

**Responsive Behavior** — [x] `IntrinsicHeight`+`Expanded` sizes the connector line to card height (a genuinely good adaptive technique); no width breakpoints

---

### Screen: ExpensesScreen
File: `expenses_screen.dart` (240 lines) · `StatefulWidget` · **ORPHANED — no `Navigator.push*` anywhere targets `/expenses`**

**Layout** — [x] `AppBar` → gradient total card → settlement CTA → expense list

**Content**
- [x] "TOTAL GROUP SPENT" gradient card with per‑person line + "Add Bill" button
- [x] "Calculate Split & Settlement" `OutlinedButton.icon` → `/settlement`
- [x] "Recorded Expenses (N)" list

**Cards / Lists** — [x] Per‑expense `AppCard`: category‑emoji avatar, title + "Paid by X · Split equally (n)", amount, delete icon

**Buttons / CTAs** — [x] "Add Bill" (opens dialog); per‑row delete icon; settlement CTA

**Inputs / Forms** — Add‑Expense `AlertDialog`: [x] Description `TextField` (informally required — non‑empty check on submit) · [x] Amount `TextField`, numeric keyboard (informally required — `amt > 0` check) · [x] Category `DropdownButtonFormField<ExpenseCategory>` (defaults to Food, always has a value) · [x] Cancel/Add buttons

**Dynamic Data** — [x] `expenses`/`total` — DYNAMIC‑SERVICE (`GroupTripService`), seeded from 3 hardcoded demo expenses at the service layer

**Loading State** — [ ] **NOT IMPLEMENTED**

**Empty State** — [x] "No group expenses recorded yet." (plain text, not the shared `EmptyState` widget)

**Error State** — [ ] **NOT IMPLEMENTED**

**Responsive Behavior** — [x] `Expanded`/`Spacer` in the total card, scrollable list

---

### Screen: SettlementScreen
File: `settlement_screen.dart` (128 lines) · `StatelessWidget` · **ORPHANED** — only entry point is the orphaned `ExpensesScreen`

**Layout** — [x] `AppBar` → info banner → settlement list → share CTA

**Content** — [x] "Fair Split Calculation" info banner; "Recommended Settlements" list

**Cards / Lists** — [x] Per‑settlement `AppCard`: red arrow avatar, "$X pays $Y" text, "Direct peer‑to‑peer settlement" subtext, amount

**Buttons / CTAs** — [x] "Share Settlement Breakdown with Group" `OutlinedButton.icon` — **stub: only shows a SnackBar, no real share/clipboard integration despite the label**

**Dynamic Data** — [x] `settlements` — DYNAMIC‑SERVICE, a real debt‑netting algorithm (`GroupTripService.calculateSettlements`) run over the same demo expense data

**Empty State** — [x] "All group expenses are completely balanced!" (plain text)

**Loading / Error State** — [ ] **NOT IMPLEMENTED**

---

### Screen: GroupScreen
File: `group_screen.dart` (226 lines) · `StatefulWidget` · **Reachable** from `ItineraryScreen` and Home's hub grid

**Layout** — [x] `AppBar` → Members section → Invite Code section → Join‑a‑Trip section

**Content**
- [x] Members list: `AppCard` of rows, each with initials avatar, name, role pill badge
- [x] Tappable Invite Code card (copies to clipboard)
- [x] "Demo Mode" notice box: **self‑documented in‑code as simulated** ("joining simulates matching your local trip. Real multi‑device sync requires a connected backend.")
- [x] Join row: code `TextField` + "Join" button

**Buttons / CTAs** — [x] Copy‑invite‑code tap action; "Join" `ElevatedButton`

**Inputs / Forms** — [x] "Enter invite code" `TextField`, `TextCapitalization.characters`, no formal validation (only a non‑empty guard)

**Dynamic Data** — [x] `trip`/`members`/`inviteCode` — DYNAMIC‑SERVICE, reactive `AnimatedBuilder`. Join‑match logic only compares against the single local trip's invite code — no backend join.

**Empty State** — [x] Shared `EmptyState` widget — "No active trip yet. Plan a trip to start a group."

**Loading State** — [ ] **NOT IMPLEMENTED**

**Success/Error State** — [x] `SnackBar` on join attempt, colored `AppTheme.success` on match, default (not styled as an error) on mismatch — **inconsistent: a failed join isn't visually marked as an error**

**Responsive Behavior** — [x] `Expanded` in join row and member rows to prevent overflow; scrollable

---

### Screen: MemoriesScreen
File: `memories_screen.dart` (96 lines) · `StatelessWidget` · **ORPHANED — zero inbound navigation, and the only screen with zero service/state wiring**

**Layout** — [x] `AppBar` → `ListView.builder` of memory cards

**Content** — [x] Per‑memory card: `Image.network` hero (160px, hardcoded Unsplash URLs), title+time row, location line, note text

**Buttons / CTAs** — [x] Add‑photo `IconButton` — **cosmetic only: shows a SnackBar, does not actually add anything to the list**

**Dynamic Data** — [ ] **Entirely DYNAMIC‑MOCK as a hardcoded `List<Map<String,String>>` literal with 2 entries — the only screen in the app with zero service/repository wiring**

**Loading / Empty State** — [ ] **NOT IMPLEMENTED** (list is always non‑empty since it's a hardcoded literal)

**Error State** — [x] Image‑only: `errorBuilder` fallback to a photo icon if the network image fails

**Responsive Behavior** — [x] Fixed 160px image height, `width: double.infinity` — no adaptive sizing

---

### Screen: TripSummaryScreen
File: `trip_summary_screen.dart` (129 lines) · `StatelessWidget` · Reachable from `ActiveJourneyScreen` "End Journey"

**Layout** — [x] `AppBar` → hero gradient banner → 2×2 metric grid → contribution note → CTA

**Content**
- [x] Hero: celebration icon, "Journey Completed!" heading, trip title
- [x] 2×2 metric tiles: Stops Visited, Trip Days, Mobility Dwells, Safety Index
- [x] "Travel Intelligence Contribution" info box

**Buttons / CTAs** — [x] "Return to Home" `PrimaryButton` — clears the nav stack back to Home (`pushNamedAndRemoveUntil`)

**Dynamic Data**
- [x] "Stops Visited" / "Trip Days" — DYNAMIC‑SERVICE (real model getters) with STATIC fallback if no active trip
- [ ] **"Mobility Dwells" and "Safety Index" are hardcoded STATIC strings** ("4 Verified" / "100% Safe") presented as if they were computed metrics — not derived from any service

**Loading / Empty / Error State** — [ ] **NOT IMPLEMENTED**

**Responsive Behavior** — [x] `Expanded` 2‑column grid, scrollable; no column‑count breakpoints

---

### Screen: PrivacySettingsScreen
File: `privacy_settings_screen.dart` (137 lines) · `StatefulWidget` · Reachable from Home's privacy icon

**Layout** — [x] `AppBar` → guarantee banner → toggle cards → static info box → version footer

**Content**
- [x] "Zero‑Surveillance Architecture" guarantee banner
- [x] "Consented Data Sharing" card: 2 `SwitchListTile`s
- [x] "Optional Device Activity" card: 1 `SwitchListTile` + STATIC "🚫 Strict Non‑Collection Guarantees" 4‑bullet box

**Inputs / Forms**
- [x] Switch — "Share Anonymized Dwell Events" (default ON)
- [x] Switch — "Contribute to Crowd Pressure Heatmaps" (default ON)
- [x] Switch — "Coarse Device Context" (default OFF)

**Dynamic Data** — [ ] All 3 toggles are local `bool` `State` fields only — **nothing persists** (no `SharedPreferences`, no service call on change); changing them has zero downstream effect anywhere else in the app

**Loading / Empty / Error State** — [ ] N/A, nothing async

**Interaction States** — [x] `activeThumbColor` styling for the "on" state; no disabled state

**Responsive Behavior** — [x] Plain `ListView`, text wraps; no adaptive layout

---

### Screen: AuthorityDashboardScreen
File: `authority_dashboard_screen.dart` (305 lines) · `StatelessWidget` · Reachable from Home's hub grid

**Layout** — [x] `AppBar` → transparency banner → district header → 2×2 metric grid → corridors list → priority ranking list

**Content**
- [x] Transparency banner: "Aggregated from consenting travellers · Strict k‑anonymity (k ≥ 50) · No individual tracking"
- [x] 2×2 metric cards: Active Travellers, Visits Today, Avg Dwell Time, Peak Crowd Index
- [x] "Mobility Corridors & Transit Pressure" cards: origin→destination, hourly‑volume badge, avg transit duration, intervention tip
- [x] "Explainable Priority Ranking" cards: circular score avatar, urgency badge, evidence box with confidence, recommended action, expected impact, classification tag, validation status

**Buttons / CTAs** — [x] Info `IconButton` → Privacy‑guarantees `AlertDialog` (4 static statements)

**Dynamic Data** — [x] `summary` — DYNAMIC‑SERVICE call, but the service returns **entirely hardcoded literal data**, explicitly flagged `isDemoData: true` in its own source

**Loading State** — [ ] **NOT IMPLEMENTED**

**Empty State** — [ ] **NOT IMPLEMENTED** — corridors/priority lists assume non‑empty, unlike the Expenses/Settlement screens which do guard for empty

**Error State** — [ ] **NOT IMPLEMENTED**

**Responsive Behavior** — [x] `Expanded` 2‑column grid (fixed, won't reflow to more columns on wide screens), scrollable

---

### Screen: PlaceholderScreen
File: `placeholder_screen.dart` (72 lines) · `StatelessWidget` · Generic router fallback

**Layout** — [x] The **only screen using the shared `TripSafeAppBar` widget** — every other screen in the app hand‑rolls its own `AppBar`

**Content** — [x] Construction icon (72px, 40%‑opacity primary), `screenName` title, `purpose` body text, conditional "Go Back" button (only if the nav stack can pop)

**Dynamic Data** — [x] `screenName`/`purpose` — DYNAMIC‑STATE, ultimately sourced from `RouteSettings.name` at the router level

**Status** — Fires only for a route‑name typo or a genuinely unknown route string; every one of the 19 `AppRoutes` constants is currently handled in the switch, so under normal use this screen is never seen by a real user today.

---

## 4. Global Component Inventory

| Component | File | Purpose | Used on | Styling | Consistency |
|---|---|---|---|---|---|
| `PrimaryButton` | `widgets/buttons.dart` | Full‑width primary CTA, optional icon + built‑in loading spinner state | Explore, Destination Detail, Planning, Itinerary, Updated Itinerary, Adapt Trip, Alternative Destination, Safety Check, Active Journey, Trip Summary | Theme‑driven (`elevatedButtonTheme`); 1 hardcoded value (white spinner) | Consistent |
| `SecondaryButton` | `widgets/buttons.dart` | Outlined secondary action, optional icon, **no loading state** (unlike PrimaryButton) | Lower usage than PrimaryButton — an inconsistency in the API surface itself (loading only on one of the two) | Theme‑driven | Consistent but incomplete API |
| `AppCard` | `widgets/common_widgets.dart` | Standard card container (border, no elevation, ripple via `InkWell`) | Nearly every screen | Fully token‑driven | Consistent |
| `TripSafeAppBar` | `widgets/common_widgets.dart` | Standardized app bar | **Only `PlaceholderScreen`** — 22 of 23 screens build a plain inline `AppBar` instead | Theme‑driven | **Inconsistent — effectively unused** |
| `EmptyState` | `widgets/common_widgets.dart` | Icon + message + optional action for empty lists | Explore, ItineraryScreen, ActiveJourneyScreen, GroupScreen | Theme‑driven (dynamic `colorScheme`) | **Inconsistent — TimelineScreen, ExpensesScreen, SettlementScreen, AuthorityDashboardScreen each build their own plain‑text or no empty‑state instead** |
| `LoadingState` | `widgets/common_widgets.dart` | Centered spinner + optional message | **Not confirmed used by any audited screen** — screens build ad hoc `CircularProgressIndicator`s instead (Explore, AddStopSheet, LocationSummaryCard) | Theme‑driven | **Likely dead/duplicated** |
| `ErrorState` | `widgets/common_widgets.dart` | Icon + message + optional retry button | **Not confirmed used** — Explore built its own custom `_buildErrorState()` instead of this shared one | Uses `AppTheme.danger` directly, bypassing dynamic `colorScheme` (won't pick up the dark‑mode error‑color override) | **Duplicated pattern** |
| `CityPulseCard` | `widgets/city_pulse_card.dart` | "What's happening around you" summary + DEMO DATA badge | Only `ExploreScreen` | Mixed — tokens for spacing/typography, but hardcoded magic numbers (radius 8, font sizes 8/10, `Colors.grey.shade200/500/700`) | Screen‑specific styling drift |
| `LocationSummaryCard` | `widgets/location_summary_card.dart` | Self‑fetching GPS location card (loading/error/success states) | **Zero imports anywhere in `lib/` — dead code** | **Does not import `app_theme.dart` at all** — every color/size is hardcoded (`Colors.redAccent`, `Colors.blueAccent`, raw `fontSize`/`EdgeInsets` numbers) | **Total design‑system outlier; candidate for deletion or adoption** |

---

## 5. Design System Inventory

**Centralization:** Colors, typography, spacing, and radius are centralized in one file, `lib/utils/app_theme.dart` (`AppTheme`, `AppTypography`, `AppSpacing` — all static/non‑instantiable classes), wired once into `MaterialApp.theme`/`darkTheme` in `app.dart`. This part of the system is genuinely centralized. The inconsistency is in **adoption**: `city_pulse_card.dart` and `location_summary_card.dart` bypass it with hardcoded values (see §4).

### Colors (named tokens in `AppTheme`)
| Token | Value | Note |
|---|---|---|
| `primary` | `#1A6FBF` (ocean blue) | Seeds `ColorScheme.fromSeed` |
| `secondary` | `#00BFA6` (teal) | |
| `warning` | `#FF8C00` (amber) | |
| `danger` | `#D32F2F` (risk red) | |
| `error` | `#D32F2F` | Alias of `danger` |
| `success` | `#2E7D32` (safe green) | |
| `_surfaceLight` / `_surfaceDark` | `#F8FAFC` / `#121417` | Private — not exposed for widget‑level reuse |
| `_cardLight` / `_cardDark` | `#FFFFFF` / `#1E2124` | Private |
| Dark‑mode‑only inline overrides | primary `#4DA3FF`, error `#EF5350`, input border `#2C3E50` | Not named constants — hardcoded inline inside `dark()` only |

**Gap:** no named `muted`/`border`/`text`/`background` tokens — those are improvised ad hoc via `Colors.grey.shade200/300/500/700` scattered across `city_pulse_card.dart`, `location_summary_card.dart`, and default `Card`/`AppBar` theme borders. This is the single biggest design‑token gap in the app.

### Typography (`AppTypography`, system font — no custom family declared)
| Style | Size / Weight / Spacing / Line‑height |
|---|---|
| `displayLarge` | 32 / 700 / ‑0.5 / 1.2 |
| `displayMedium` | 26 / 700 / ‑0.3 / 1.25 |
| `titleLarge` | 20 / 600 / ‑0.2 / 1.3 |
| `titleMedium` | 17 / 600 / — / 1.35 |
| `titleSmall` | 15 / 600 / — / 1.35 |
| `bodyLarge` | 16 / 400 / — / 1.5 |
| `bodyMedium` | 14 / 400 / — / 1.5 |
| `bodySmall` | 12 / 400 / — / 1.4 |
| `labelLarge` | 15 / 600 / 0.3 / — |
| `caption` | 12 / 400 / 0.2 / — |

### Spacing / Radius (`AppSpacing`)
- Spacing: `xs 4 · sm 8 · md 16 · lg 24 · xl 32 · xxl 48`
- Radius: `radiusSm 8 · radiusMd 12 · radiusLg 20 · radiusXl 32`

### Effects
- **Shadows: none.** `Card`/`AppBar` elevation is explicitly `0` in both themes; cards use a `BorderSide` (grey‑200 light / white‑6%‑alpha dark) instead of a shadow.
- No blur, gradient‑as‑token, or glassmorphism defined at the token level (gradients are hand‑coded per‑screen, e.g. Home's active‑trip card, Journey's status banner, Trip Summary's hero).
- No custom transition/animation curves defined beyond the one shared route‑transition (`_slide`, 280 ms `easeInOut`, used for every screen push).

### Duplicate/inconsistent styling found
- **`AppBar`**: `TripSafeAppBar` exists but 22/23 screens inline their own `AppBar` instead.
- **Empty states**: 2 competing patterns — the shared `EmptyState` widget vs. ad hoc plain `Center(Text(...))` (Timeline, Expenses, Settlement).
- **Error/Loading states**: shared `ErrorState`/`LoadingState` widgets exist but the most complex screen (`ExploreScreen`) rebuilt its own bespoke versions rather than reusing them.
- **Dark‑theme asymmetry**: `AppTheme.light()` sets `textButtonTheme` and `dividerTheme`; `AppTheme.dark()` sets neither — an unintentional gap between the two theme factories.
- **`ErrorState` widget colors from `AppTheme.danger` directly** rather than `theme.colorScheme.error`, so it won't reflect the dark‑mode error‑color override (`#EF5350`) that the rest of the theme defines.

---

## 6. Form Inventory

| Form | Screen | Fields | Required/Optional | Validation |
|---|---|---|---|---|
| **Trip Parameters** | PlanningScreen | Destination `TextField`; Duration `Slider` (1–5d); Group size `Slider` (1–8); Budget `Slider` (₹500–10,000); Interests `FilterChip` multi‑select (7 options) | All optional/defaulted; Interests enforces a floor of 1 selection in code | No field‑level validation; sliders are inherently bounded |
| **Explore Search** | ExploreScreen | Free‑text `TextField`, live filter | Optional | None — filters on `onChanged`, no submit |
| **Join a Trip** | GroupScreen | Invite‑code `TextField` (`TextCapitalization.characters`) | Informally required (empty‑string guard only) | None — string equality check against local trip's code |
| **Add Expense** | ExpensesScreen (dialog) | Description `TextField`; Amount `TextField` (numeric); Category `DropdownButtonFormField<ExpenseCategory>` | Description informally required (non‑empty check); Amount informally required (`>0` check); Category always has a default value | Minimal — no max‑length, no currency‑format validation |
| **Edit Stop Time** | ItineraryScreen | Native `showTimePicker` dialog | Optional/cancelable | Native picker only |
| **Privacy Toggles** | PrivacySettingsScreen | 3× `Switch` (Share Dwells, Crowd Heatmaps, Device Context) | N/A (booleans) | None — and **no persistence**, so the "submit" is purely cosmetic |
| **Add/Change Stop** (selection, not a form) | AddStopSheet | None — tap‑to‑select list only | N/A | N/A |

No multi‑step forms, no file/image upload fields, no date pickers (only a time picker), no radio‑button groups anywhere in the app.

---

## 7. Navigation Map

### 7.1 Actual wired navigation graph (verified from real `Navigator.push*` call sites — **not** the aspirational flow in `docs/NAVIGATION_MAP.md`)

```
HomeScreen ( / )
├── /privacy            → PrivacySettingsScreen        (raw string literal, not AppRoutes.privacy)
├── /discover            → DiscoveryScreen → ExploreScreen
│     ├── (modal) PlaceDetailSheet
│     └── /plan          → PlanningScreen
├── /plan                → PlanningScreen
│     ├── /itinerary      → ItineraryScreen   (if trip active)
│     └── /journey        → ActiveJourneyScreen (if trip active)
├── /itinerary  (with tripId arg) → ItineraryScreen
│     ├── /plan            (edit parameters)
│     ├── /discover        (empty‑state recovery action)
│     ├── /journey
│     ├── /group           → GroupScreen
│     └── (modal) AddStopSheet
├── /safety               → SafetyCheckScreen
│     ├── /itinerary       ("Proceed to Itinerary")
│     └── /adapt           (per‑alert "Adapt Trip Plan")
├── /group                → GroupScreen
├── /timeline              → TimelineScreen
│     └── /itinerary        (edit action)
└── /authority             → AuthorityDashboardScreen (raw string literal, not AppRoutes.authority)

ActiveJourneyScreen ( /journey , also reached from Home, Itinerary, Planning )
├── /timeline
└── /summary  (pushReplacementNamed, "End Journey") → TripSummaryScreen
                                                          └── pushNamedAndRemoveUntil /home ("Return to Home")

AdaptTripScreen ( /adapt , reached from SafetyCheckScreen AND RiskAlertScreen )
├── pushReplacementNamed /itinerary  ("Swap Stop")
└── /alternatives → AlternativeDestinationScreen
                       └── /plan  (with destinationId arg, "Select Destination")
```

### 7.2 Orphaned screens (registered in `routes.dart`, zero real inbound navigation)
- `/discover/detail` → **DestinationDetailScreen**
- `/itinerary/updated` → **UpdatedItineraryScreen**
- `/alert` → **RiskAlertScreen** (no screen anywhere calls `Navigator.push*(..., AppRoutes.alert)`)
- `/expenses` → **ExpensesScreen**
- `/settlement` → **SettlementScreen** (transitively orphaned — its only entry point is the orphaned ExpensesScreen)
- `/memories` → **MemoriesScreen**

### 7.3 Documented "hero path" vs. reality
`docs/NAVIGATION_MAP.md §2` describes: `SafetyCheckScreen → ActiveJourneyScreen → RiskAlertScreen → AdaptTripScreen → AlternativeDestinationScreen → UpdatedItineraryScreen → ActiveJourneyScreen`. Verified against real code, **this loop is broken in 4 places**:
1. `SafetyCheckScreen → ActiveJourneyScreen` — **not wired** (Safety only goes to Itinerary or Adapt)
2. `ActiveJourneyScreen → RiskAlertScreen` — **not wired**, and RiskAlertScreen has no real inbound path from anywhere
3. `AlternativeDestinationScreen → UpdatedItineraryScreen` — **not wired** (Alternatives goes to `/plan`, not `/itinerary/updated`)
4. `UpdatedItineraryScreen → ActiveJourneyScreen` — **not wired**, and the screen itself is unreachable anyway

The middle segment (`RiskAlertScreen → AdaptTripScreen → AlternativeDestinationScreen`) *does* work in isolation, and `AdaptTripScreen` is independently reachable from `SafetyCheckScreen`'s alert cards — but a user cannot currently traverse the full documented loop through real app navigation.

### 7.4 Route‑constant hygiene
Two working routes are navigated to via **raw string literals** instead of the centralized `AppRoutes` constants (functionally fine, but inconsistent with the rest of the codebase): `'/privacy'` and `'/authority'`, both in `home_screen.dart`.

### 7.5 Route guards
**NONE FOUND.** No auth check, no role check, anywhere in `onGenerateRoute` or `MaterialApp`. `AuthorityDashboardScreen` — conceptually a role‑gated "authority/municipal" view — is reachable by any user with no permission check at all.

---

## 8. State Inventory

### Loading states
| Implemented (screen) | Not implemented |
|---|---|
| HomeScreen (location pill only), ExploreScreen (full skeleton), PlanningScreen (button‑level only), AddStopSheet (spinner) | ItineraryScreen, ActiveJourneyScreen, SafetyCheckScreen, TimelineScreen, ExpensesScreen, SettlementScreen, GroupScreen, TripSummaryScreen, AuthorityDashboardScreen, PrivacySettingsScreen, all "Adapt/Alert/Alternatives" screens |

### Empty states
| Pattern used | Screens |
|---|---|
| Shared `EmptyState` widget | ExploreScreen, ItineraryScreen, ActiveJourneyScreen, GroupScreen |
| Ad hoc plain text (not the shared widget) | TimelineScreen, ExpensesScreen, SettlementScreen |
| **Missing entirely** | HomeScreen (no active trip), SafetyCheckScreen (no alerts), PlanningScreen (no active trip), AuthorityDashboardScreen (empty corridors/priorities), AddStopSheet (empty candidates), MemoriesScreen (N/A — always hardcoded non‑empty) |

### Error states
| Implemented | Screens |
|---|---|
| Full dedicated error UI | ExploreScreen (2 variants: unconfigured‑API and generic error, each with recovery actions) |
| `SnackBar`‑only | PlanningScreen |
| Image‑load fallback only | PlaceDetailSheet, MemoriesScreen |
| Location‑specific inline error | HomeScreen, LocationSummaryCard (dead code) |
| **Missing entirely** | ItineraryScreen, ActiveJourneyScreen, SafetyCheckScreen, RiskAlertScreen, AdaptTripScreen, AlternativeDestinationScreen, TimelineScreen, ExpensesScreen, SettlementScreen, GroupScreen (join mismatch isn't styled as an error), TripSummaryScreen, AuthorityDashboardScreen, AddStopSheet |

### Success/confirmation states
Almost entirely `SnackBar`‑based: green success snackbars on plan generation (Planning), stop swap (AdaptTrip), and group join match (Group). `UpdatedItineraryScreen` is the one screen designed as a dedicated full‑page success state, but it's currently orphaned/unreachable.

### Interaction states
- **Selected/toggled**: `ChoiceChip`/`FilterChip` selection (Explore, Planning), `_isAdded` toggle (PlaceDetailSheet), `isVisited`/`isSkipped` styling (Itinerary, Timeline)
- **Disabled**: only `PrimaryButton`'s built‑in `isLoading` disable and Planning's "Generate" button while busy — most buttons across the app are **never disabled**, including ones that could be double‑tapped (Adapt's "Swap Stop", Active Journey's "Verify Dwell")
- **Hover/Focus/Pressed**: **not implemented anywhere** beyond Flutter's stock `InkWell`/`ElevatedButton`/`OutlinedButton` ripple defaults — no custom hover, focus‑ring, or pressed styling in the whole codebase (expected for a mobile‑first app, but worth noting since Flutter also runs on web/desktop here — see `SIHprojectf01/web/` — where hover/focus matter more)
- **Expanded/collapsed**: not used anywhere (no accordions/expansion panels in the app)

---

## 9. Asset Inventory

| Asset | Path | Used by | Reusable? | Notes |
|---|---|---|---|---|
| `demo_trip.json` | `assets/mock/demo_trip.json` | **Nobody** | No | Declared in `pubspec.yaml` assets, zero references in `lib/` — dead |
| `destinations.json` | `assets/mock/destinations.json` | **Nobody** | No | Same — no `Destination` model even exists to consume it |
| `safety_scenarios.json` | `assets/mock/safety_scenarios.json` | **Nobody** | No | Same — field names don't even match `SafetyRiskAlert` |
| App launcher icons | `android/app/src/main/res/mipmap-*/ic_launcher.png`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` | OS home screen | N/A | Standard Flutter‑scaffold default paths — **could not be visually confirmed as custom‑branded vs. template default; flag as UNKNOWN** |
| `MaterialIcons-Regular.otf` / `CupertinoIcons.ttf` | bundled Flutter/Cupertino font assets | All `Icon`/`Icons.*` widgets app‑wide | Yes (framework default) | Not a custom asset — ships with Flutter |
| Place photography | `place.photoUrl` — remote `Image.network` from the Geoapify API response | PlaceDetailSheet | N/A (remote) | Real, API‑sourced — not a bundled asset |
| Memory photos | Hardcoded Unsplash URLs in `memories_screen.dart` (2 entries) | MemoriesScreen | No | Placeholder stock‑photo URLs, not project assets |
| Category "icons" | Emoji characters returned by `PlaceCategory.iconEmoji` getter | Explore, Adapt, Memories, and most card components | Yes (as data, not a file asset) | The app uses emoji as its de facto icon‑imagery system for categories rather than a custom icon/illustration set |

**No local image assets exist for photography, hero art, illustrations, or a splash/branding image** — every "photo" in the running app is either a remote URL or a Material/Cupertino icon glyph. There is no bundled logo file either — the "TRIPSAFE" wordmark on Home is plain text next to a `Icons.shield_outlined` icon, not an image asset.

---

## 10. UI Redesign Workload

| Priority | Screen/Component | Current Status | UI Work Required |
|---|---|---|---|
| **High** | HomeScreen | Partial, real data | Full visual pass; fixed 2‑col hub grid needs responsive rule; needs a real empty state for "no active trip" |
| **High** | ExploreScreen | Complete, most feature‑rich | Visual pass only — logic/states are the most solid in the app; fixed‑px carousel cards need responsive sizing |
| **High** | PlanningScreen | Complete | Visual pass; needs a designed loading state beyond button‑disable, and a real empty state |
| **High** | ItineraryScreen | Complete | Visual pass; needs loading + error states added |
| **High** | SafetyCheckScreen | Mock data, real UI shape | Needs both a visual pass and a product decision on real safety‑data sourcing; needs a "no alerts" empty state |
| **High** | ActiveJourneyScreen | Partial, demo‑driven | Visual pass; decide product‑side whether the "Simulate GPS deviation" demo affordance ships to real users |
| **High** | AdaptTripScreen / AlternativeDestinationScreen / RiskAlertScreen | Mock/partial, **navigation broken** | Fix the navigation graph first (RiskAlertScreen is currently dead) before investing design time; then visual pass |
| **Medium** | GroupScreen | Partial, reachable | Visual pass; decide whether "Join" logic should visually distinguish a failed match as an error state |
| **Medium** | TimelineScreen | Complete for its scope | Visual pass; swap its ad hoc empty‑state text for the shared `EmptyState` widget for consistency |
| **Medium** | TripSummaryScreen | Partial | Visual pass; decide whether "Mobility Dwells"/"Safety Index" become real computed metrics or stay illustrative |
| **Medium** | PlaceDetailSheet | Complete | Visual pass; "Directions" button needs real map‑launch behavior or a relabel |
| **Medium** | AddStopSheet | Partial, mock data | Visual pass; add an empty‑state and error‑handling before any redesign |
| **Medium** | AuthorityDashboardScreen | Mock (self‑flagged demo data) | Visual pass; add loading/empty/error states which are currently entirely absent |
| **Medium** | PrivacySettingsScreen | Cosmetic only | Visual pass; flag to product that toggles don't persist — redesigning the UI won't fix the missing wiring |
| **Low (decide first)** | ExpensesScreen / SettlementScreen | Mock, fully built, **orphaned** | Product decision needed: reconnect to navigation or remove — don't spend design effort until resolved |
| **Low (decide first)** | MemoriesScreen | Placeholder, **orphaned**, zero wiring | Needs a product decision + real data wiring before a redesign is worth it |
| **Low (decide first)** | DestinationDetailScreen | Mock, **orphaned** | Content is generic/hardcoded and unrelated to its own `destinationId` — needs a product decision |
| **Low (decide first)** | UpdatedItineraryScreen | Placeholder, **orphaned** | Only useful once the hero‑path navigation gap (§7.3) is fixed |
| **Global** | Design tokens | Centralized but incomplete | Add named `text`/`muted`/`border`/`background` tokens to close the gap that causes ad hoc `Colors.grey.shadeXXX` usage |
| **Global** | `TripSafeAppBar` adoption | Defined, effectively unused | Either roll it out to all 22 remaining screens for a consistent app bar, or remove it |
| **Global** | `LoadingState` / `ErrorState` adoption | Defined, duplicated ad hoc elsewhere | Consolidate ExploreScreen's bespoke loading/error UI (and any future ones) onto the shared widgets, or promote Explore's richer version to be the new shared standard |
| **Global** | `LocationSummaryCard` | Dead code, zero design‑token usage | Decide: delete it, or bring it in line with `AppTheme` if it's meant to be revived |
| **Global** | Branding/icon assets | Unconfirmed | Verify whether app‑icon assets are final brand assets or still template defaults |

---

# MASTER UI STYLING CHECKLIST

### Screens
- [ ] HomeScreen
- [ ] DiscoveryScreen (stub — verify still just a redirect before styling)
- [ ] ExploreScreen
- [ ] DestinationDetailScreen *(orphaned — confirm product intent first)*
- [ ] PlaceDetailSheet
- [ ] PlanningScreen
- [ ] ItineraryScreen
- [ ] UpdatedItineraryScreen *(orphaned — confirm product intent first)*
- [ ] AddStopSheet
- [ ] SafetyCheckScreen
- [ ] ActiveJourneyScreen
- [ ] RiskAlertScreen *(orphaned — fix navigation first)*
- [ ] AdaptTripScreen
- [ ] AlternativeDestinationScreen
- [ ] TimelineScreen
- [ ] ExpensesScreen *(orphaned — confirm product intent first)*
- [ ] SettlementScreen *(orphaned — confirm product intent first)*
- [ ] GroupScreen
- [ ] MemoriesScreen *(orphaned — confirm product intent first)*
- [ ] TripSummaryScreen
- [ ] PrivacySettingsScreen
- [ ] AuthorityDashboardScreen
- [ ] PlaceholderScreen

### Global Components
- [ ] PrimaryButton
- [ ] SecondaryButton (align its API with PrimaryButton — no loading state today)
- [ ] AppCard
- [ ] TripSafeAppBar (decide: roll out everywhere, or remove)
- [ ] EmptyState (consolidate the 3 ad hoc duplicates onto this)
- [ ] LoadingState (consolidate ad hoc spinners onto this)
- [ ] ErrorState (consolidate ExploreScreen's bespoke version, fix its hardcoded color)
- [ ] CityPulseCard (replace its hardcoded magic numbers with tokens)
- [ ] LocationSummaryCard (decide: delete or adopt into the token system)

### Screen‑Specific Components
- [ ] `_ActionCard` / `_HubTile` (Home)
- [ ] Recommended/Popular/Best‑Time carousel cards (Explore)
- [ ] Travel Pulse card (PlaceDetailSheet)
- [ ] Preferences card, day‑plan stop rows (Planning)
- [ ] Trip header card, conflict banner, stop menu (Itinerary)
- [ ] Safety score card, alert card (SafetyCheck)
- [ ] Live‑status banner, spontaneous‑stop card, current‑stop card (ActiveJourney)
- [ ] Warning banner (RiskAlert)
- [ ] Replacement card (AdaptTrip)
- [ ] Alternative‑destination card (AlternativeDestination)
- [ ] Timeline dot/connector + stop card (Timeline)
- [ ] Total‑spent gradient card, expense row (Expenses)
- [ ] Settlement row (Settlement)
- [ ] Member row, invite‑code card (Group)
- [ ] Memory card (Memories)
- [ ] Metric tile, hero banner (TripSummary)
- [ ] Toggle cards (PrivacySettings)
- [ ] Metric card, corridor card, priority card (AuthorityDashboard)

### Forms
- [ ] Trip Parameters form (Planning)
- [ ] Explore search field
- [ ] Join‑a‑Trip field (Group)
- [ ] Add Expense dialog (Expenses)
- [ ] Edit‑time picker (Itinerary)
- [ ] Privacy toggle group

### Navigation
- [ ] Fix or intentionally retire the 6 orphaned routes (§7.2)
- [ ] Repair or formally descope the hero‑path loop (§7.3)
- [ ] Replace the 2 raw‑string route calls with `AppRoutes` constants (§7.4)
- [ ] Decide on a shared app shell / bottom navigation (currently none exists)
- [ ] Decide on role‑gating for AuthorityDashboardScreen (currently open to anyone)

### States
- [ ] Add loading states to the 19 screens currently missing one
- [ ] Standardize empty states on the shared `EmptyState` widget everywhere
- [ ] Add error states to the 13 screens currently missing one
- [ ] Add disabled/double‑tap guards to un‑debounced action buttons (Adapt's Swap Stop, ActiveJourney's Verify Dwell)
- [ ] Decide whether hover/focus states are needed given the Flutter Web target exists (`SIHprojectf01/web/`)

### Responsive UI
- [ ] Fixed 2‑column grids (Home hub grid, TripSummary metrics, AuthorityDashboard metrics) — add breakpoint logic
- [ ] Fixed‑pixel carousel cards (Explore) — make width‑responsive
- [ ] RiskAlertScreen — add scroll‑overflow protection (currently the only screen without it)
- [ ] Audit the whole app against tablet/desktop widths — no screen currently has `MediaQuery`/`LayoutBuilder` breakpoint logic

### Assets
- [ ] Confirm whether app‑icon assets are final branding or still Flutter‑template defaults
- [ ] Decide the fate of the 3 unused mock JSON files (delete, or wire up as real fallback data)
- [ ] Source real photography/illustration assets to replace the 2 hardcoded Unsplash placeholder URLs in Memories
- [ ] Decide whether the emoji‑as‑icon system (category emojis) is the final visual language or a placeholder for real iconography

### Design System
- [ ] Add named `text`/`muted`/`border`/`background` color tokens to close the biggest token gap
- [ ] Bring `dark()` theme to parity with `light()` (missing `textButtonTheme`/`dividerTheme` overrides)
- [ ] Decide on a font pairing/brand typeface (currently system‑default font only)
- [ ] Establish a shadow/elevation policy if any screens need depth beyond the current flat/bordered card style
- [ ] Fix `ErrorState` to read from `theme.colorScheme.error` instead of the static `AppTheme.danger` token, so it respects dark‑mode overrides
