import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/trip_plan.dart';
import '../../services/journey_tracking_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// ActiveJourneyScreen — live journey progress, dark "accent panel" theme.
/// Layout order unchanged: live status panel, spontaneous-stop alert,
/// current stop focus, planned vs observed, demo simulator, controls.
class ActiveJourneyScreen extends StatefulWidget {
  final String tripId;
  const ActiveJourneyScreen({super.key, this.tripId = ''});

  @override
  State<ActiveJourneyScreen> createState() => _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState extends State<ActiveJourneyScreen> {
  final _journeyService = JourneyTrackingService.instance;
  final _planningService = TripPlanningService.instance;

  @override
  void initState() {
    super.initState();
    if (!_journeyService.isJourneyActive) {
      _journeyService.startJourney();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const FloatingNavBar(current: NavDestination.journey),
      appBar: TripSafeAppBar(
        title: 'Active journey',
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: 'View Journey Timeline',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.timeline),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_journeyService, _planningService]),
        builder: (context, _) {
          final activeTrip = _planningService.activeTrip;
          if (activeTrip == null || activeTrip.days.isEmpty) {
            return EmptyState(
              message: 'No active trip found to track.\nGenerate a trip plan first.',
              icon: Icons.navigation_outlined,
              actionLabel: 'Plan a trip',
              action: () => Navigator.pushNamed(context, AppRoutes.plan),
            );
          }

          final dayStops = activeTrip.days.first.stops;
          final currentIdx = _journeyService.currentStopIndex;
          final currentStop =
              currentIdx < dayStops.length ? dayStops[currentIdx] : null;
          final pendingSpontaneous = _journeyService.pendingSpontaneousStop;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              104,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLiveStatusPanel(activeTrip, currentIdx, dayStops.length),

                if (pendingSpontaneous != null) ...[
                  const SizedBox(height: 16),
                  _buildSpontaneousStopAlert(pendingSpontaneous),
                ],

                if (currentStop != null) ...[
                  const SizedBox(height: 16),
                  _buildCurrentStopFocus(currentStop),
                ],

                const SizedBox(height: 18),
                _buildPlannedVsObserved(dayStops, currentIdx),

                const SizedBox(height: 18),
                _buildDemoSimulator(),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'End journey',
                        icon: Icons.stop_circle_outlined,
                        color: AppTheme.danger,
                        onPressed: () {
                          _journeyService.endJourney();
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.summary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Timeline',
                        icon: Icons.timeline,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.timeline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Live status — the green accent panel ───────────────────────────────
  Widget _buildLiveStatusPanel(TripPlan trip, int currentIdx, int totalStops) {
    const ink = AppTheme.onSuccess;

    return AccentPanel(
      color: AppTheme.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: const BoxDecoration(
                  color: ink,
                  borderRadius: AppSpacing.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TRACKING',
                      style: AppTypography.chipLabel.copyWith(
                        color: AppTheme.success,
                        fontSize: 10.5,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                trip.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.chipLabel.copyWith(
                  color: ink.withValues(alpha: 0.75),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentIdx',
                style: AppTypography.displayLarge.copyWith(
                  color: ink,
                  fontSize: 52,
                  letterSpacing: -2.4,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  'of $totalStops stops verified',
                  style: AppTypography.titleSmall.copyWith(
                    color: ink.withValues(alpha: 0.75),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented progress — one bar per stop.
          Row(
            children: List.generate(totalStops, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == totalStops - 1 ? 0 : 5),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: i < currentIdx ? ink : ink.withValues(alpha: 0.22),
                      borderRadius: AppSpacing.pill,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Text(
            'Consented location sharing on',
            style: AppTypography.caption.copyWith(
              color: ink.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Spontaneous stop alert ─────────────────────────────────────────────
  Widget _buildSpontaneousStopAlert(dynamic place) {
    return AppCard(
      accentBorder: AppTheme.info,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, color: AppTheme.info, size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Unplanned dwell detected',
                  style: AppTypography.titleSmall,
                ),
              ),
              const SizedBox(width: 8),
              const StatusPill(label: '22 min', color: AppTheme.info),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                color: AppTheme.body(context),
              ),
              children: [
                const TextSpan(text: "You've been at "),
                TextSpan(
                  text: place.name,
                  style: AppTypography.chipLabel.copyWith(
                    color: AppTheme.onDark,
                    fontSize: 12,
                  ),
                ),
                const TextSpan(
                  text: ' longer than a pass-through. Log it as a stop?',
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Dismiss',
                  onPressed: _journeyService.dismissSpontaneousStop,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: PrimaryButton(
                  label: 'Add stop',
                  color: AppTheme.info,
                  onPressed: _journeyService.confirmSpontaneousStop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Current stop ───────────────────────────────────────────────────────
  Widget _buildCurrentStopFocus(StopItem stop) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: Color(0xFF00BFA6), size: 17),
              const SizedBox(width: 9),
              Text(
                'CURRENT STOP',
                style: AppTypography.sectionLabel.copyWith(
                  fontSize: 10.5,
                  letterSpacing: 1.6,
                  color: const Color(0xFF00BFA6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stop.place.name,
            style: AppTypography.displayMedium.copyWith(fontSize: 23),
          ),
          const SizedBox(height: 8),
          Text(
            '${stop.place.category.displayName} · ${stop.startTime} – ${stop.endTime}',
            style: AppTypography.caption.copyWith(
              fontSize: 11.5,
              color: AppTheme.muted(context),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppTheme.muted(context),
              ),
              const SizedBox(width: 6),
              Text(
                'Planned dwell ${stop.estimatedDurationMinutes} min',
                style: AppTypography.caption.copyWith(
                  fontSize: 11.5,
                  color: AppTheme.muted(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Verify this stop',
              icon: Icons.check_circle_outline,
              color: AppTheme.onDark,
              onPressed: () {
                _journeyService.completeCurrentStop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Completed ${stop.place.name} · visit logged'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Planned vs observed ────────────────────────────────────────────────
  Widget _buildPlannedVsObserved(List<StopItem> plannedStops, int currentIdx) {
    final observed = _journeyService.observedStops;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLANNED ROUTE',
                  style: AppTypography.sectionLabel.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 1.4,
                    color: AppTheme.muted(context),
                  ),
                ),
                const SizedBox(height: 11),
                ...plannedStops.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final isCurrent = i == currentIdx && !s.isVisited;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.isVisited
                                ? AppTheme.success
                                : isCurrent
                                    ? AppTheme.primary
                                    : Colors.transparent,
                            border: s.isVisited || isCurrent
                                ? null
                                : Border.all(
                                    color: AppTheme.muted(context),
                                    width: 1.5,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11.5,
                              fontWeight:
                                  isCurrent ? FontWeight.w700 : FontWeight.w400,
                              color: s.isVisited
                                  ? AppTheme.muted(context)
                                  : AppTheme.onDark,
                              decoration: s.isVisited
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: AppCard(
            accentBorder: AppTheme.success,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OBSERVED DWELLS',
                  style: AppTypography.sectionLabel.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 1.4,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 11),
                if (observed.isEmpty)
                  Text(
                    'Starting route…',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11.5,
                      color: AppTheme.muted(context),
                    ),
                  )
                else
                  ...observed.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall
                                  .copyWith(fontSize: 11.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check,
                            size: 13,
                            color: AppTheme.success,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Demo simulator (hackathon evaluation aid) ──────────────────────────
  Widget _buildDemoSimulator() {
    return AppCard(
      accentBorder: AppTheme.secondary,
      background: AppTheme.tint(AppTheme.secondary, 0.08),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        children: [
          const Icon(Icons.science, color: AppTheme.secondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo: simulate a GPS dwell deviation',
              style: AppTypography.caption.copyWith(
                fontSize: 11.5,
                color: AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PillButton(
            label: 'Simulate',
            dense: true,
            color: AppTheme.secondary,
            onPressed: _journeyService.triggerDemoDeviation,
          ),
        ],
      ),
    );
  }
}
