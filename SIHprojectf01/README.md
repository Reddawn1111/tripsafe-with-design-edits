# TripSafe dark theme — complete package (direction 1a, Accent panel)

Replace everything below over `SIHprojectf01/`. Paths match one-to-one.

## One dependency

`pubspec.yaml`, under `dependencies:`

```yaml
  google_fonts: ^6.2.1
```

then `flutter pub get`.

## Files in this package

**Foundation** (replace once)

```
lib/utils/app_theme.dart
lib/widgets/common_widgets.dart
lib/widgets/buttons.dart
lib/app/app.dart                     themeMode: dark
```

**Screens rebuilt to match the mockups**

```
lib/screens/home/home_screen.dart
lib/screens/safety/safety_check_screen.dart
lib/screens/planning/planning_screen.dart
lib/screens/itinerary/itinerary_screen.dart
lib/screens/journey/active_journey_screen.dart
lib/screens/memories/memories_screen.dart
lib/screens/group/group_screen.dart
lib/screens/expenses/expenses_screen.dart
lib/screens/timeline/timeline_screen.dart
lib/screens/trip_summary/trip_summary_screen.dart
lib/screens/risk_alert/risk_alert_screen.dart
```

**Screens conformed to the theme** (layout and logic untouched; hardcoded
light-mode colours swapped for dark-theme tokens, radii and type updated)

```
lib/screens/discovery/explore_screen.dart          + new saffron header, pill search
lib/screens/discovery/discovery_screen.dart
lib/screens/discovery/destination_detail_screen.dart
lib/screens/discovery/place_detail_sheet.dart
lib/screens/itinerary/add_stop_sheet.dart
lib/screens/itinerary/updated_itinerary_screen.dart
lib/screens/expenses/settlement_screen.dart
lib/screens/adapt_trip/adapt_trip_screen.dart
lib/screens/alternative_destination/alternative_destination_screen.dart
lib/screens/authority/authority_dashboard_screen.dart
lib/screens/privacy/privacy_settings_screen.dart
```

## The system

One saturated **accent panel** per screen carries the hierarchy; everything
else is flat charcoal with a single hairline border and no elevation.

| Screen | Accent panel |
|---|---|
| Home | rust — Explore Nearby |
| Explore | saffron header |
| Planning | saffron — preferences |
| Itinerary | rust — trip header |
| Active journey | green — live tracking |
| Safety / Risk alert | saffron or rust by severity |
| Group | rust — invite code |
| Expenses | rust — total spent |
| Trip summary | green — completion |

## Token map (old → new)

| Token | Was | Now |
|---|---|---|
| `AppTheme.primary` | `#1A6FBF` | `#E4572E` rust |
| `AppTheme.secondary` | `#00BFA6` | `#F2C230` saffron |
| `AppTheme.warning` | `#FF8C00` | `#F2C230` |
| `AppTheme.danger` / `error` | `#D32F2F` | `#E4572E` |
| `AppTheme.success` | `#2E7D32` | `#3FBF74` |
| `AppSpacing.radiusSm/Md/Lg/Xl` | 8/12/20/32 | 12/18/22/28 |
| `AppTypography.*` | const system fonts | Space Grotesk getters |

Every old name still exists. New: `AppTheme.info`, `onPrimary/onSecondary/onSuccess/onInfo`,
`surfaceDark/cardDark/onDark/mutedDark/subtleDark`, `borderDark/borderLight`,
`AppSpacing.pill`, `AppTypography.screenTitle/sectionLabel/statNumber/chipLabel/buttonLabel`,
and the helpers `AppTheme.muted(context)` / `AppTheme.body(context)` / `AppTheme.tint(color)`.

New shared widgets: `AccentPanel`, `SectionLabel`, `StatusPill`, `IconChip`,
`StatBlock`, `AppProgressBar`, `PillButton`, `CircleIconButton`, `VibeChip`.
`AppCard` gained `accentBorder` + `background`; `PrimaryButton`/`SecondaryButton`
gained `color`; `TripSafeAppBar` gained `subtitle` and uppercases its title.

## Fixed from your screenshots

- Home — the "Active Journey & Dwell Tracker" badge no longer overflows
  (title + badge sit in a `Wrap`).
- Safety — the white "Safe Alternatives" box is gone; alternatives are tinted
  chips, and checklist text uses `AppTheme.body(context)`.

## Expect on first run

The Dart here is not compiler-verified. Likely small fixes: a missing import,
a `const` that needs dropping. Paste the error text and I'll fix it directly.
