import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/trip_plan.dart';
import '../../services/journey_tracking_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// TimelineScreen — chronological journey progression, dark theme.
/// Read-only; the AppBar action jumps to ItineraryScreen for editing.
///
/// Progress colouring (passed/current) is only meaningful for Day 1 — the
/// only day JourneyTrackingService tracks live progress against.
class TimelineScreen extends StatelessWidget {
  final String tripId;
  const TimelineScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;
    final journeyService = JourneyTrackingService.instance;
    final activeTrip = planningService.activeTrip;

    return Scaffold(
      appBar: TripSafeAppBar(
        title: 'Timeline',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'Edit Itinerary',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.itinerary),
          ),
        ],
      ),
      body: activeTrip == null || activeTrip.days.isEmpty
          ? const EmptyState(
              message: 'No active journey timeline to display.',
              icon: Icons.timeline,
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              itemCount: activeTrip.days.length,
              itemBuilder: (context, dIdx) {
                final day = activeTrip.days[dIdx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SectionLabel(day.title),
                      ),
                      ..._buildDayStops(
                        context,
                        day,
                        dIdx == 0,
                        journeyService,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<Widget> _buildDayStops(
    BuildContext context,
    DayPlan day,
    bool isTrackedDay,
    JourneyTrackingService journeyService,
  ) {
    final stops = day.stops;

    return List.generate(stops.length, (index) {
      final stop = stops[index];
      final isPassed = isTrackedDay && index <= journeyService.currentStopIndex;
      final isCurrent = isTrackedDay && index == journeyService.currentStopIndex;
      final dotColor = isPassed
          ? (isCurrent ? AppTheme.primary : AppTheme.success)
          : AppTheme.mutedDark;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPassed ? dotColor : Colors.transparent,
                    border: isPassed
                        ? null
                        : Border.all(color: AppTheme.mutedDark, width: 1.5),
                  ),
                  child: isPassed
                      ? Icon(
                          isCurrent ? Icons.near_me : Icons.check,
                          size: 12,
                          color: isCurrent
                              ? AppTheme.onPrimary
                              : AppTheme.onSuccess,
                        )
                      : null,
                ),
                if (index < stops.length - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPassed
                          ? AppTheme.success.withValues(alpha: 0.5)
                          : const Color(0x1FFFFFFF),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  accentBorder: isCurrent ? AppTheme.primary : null,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              stop.place.name,
                              style: AppTypography.titleSmall.copyWith(
                                color: isCurrent
                                    ? AppTheme.primary
                                    : stop.isSkipped
                                        ? AppTheme.muted(context)
                                        : AppTheme.onDark,
                                decoration: stop.isSkipped
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            stop.startTime,
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: AppTheme.muted(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${stop.place.category.displayName} · dwell ${stop.estimatedDurationMinutes} min',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppTheme.muted(context),
                        ),
                      ),
                      if (isPassed && !isCurrent) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 13,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Dwell verified · consented visit recorded',
                                style: AppTypography.chipLabel.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
