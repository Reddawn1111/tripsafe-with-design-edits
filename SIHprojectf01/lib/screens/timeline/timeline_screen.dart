import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/trip_plan.dart';
import '../../services/journey_tracking_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// TimelineScreen — Chronological journey progression with verified dwell
/// events, across all trip days. Read-only: use the edit action in the
/// AppBar to jump to ItineraryScreen for editing.
///
/// Progress coloring (passed/current) is only meaningful for Day 1 — that's
/// the only day JourneyTrackingService actually tracks live progress
/// against. Later days are shown as planned stops without progress state.
class TimelineScreen extends StatelessWidget {
  final String tripId;
  const TimelineScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;
    final journeyService = JourneyTrackingService.instance;
    final activeTrip = planningService.activeTrip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'Edit Itinerary',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.itinerary),
          ),
        ],
      ),
      body: activeTrip == null || activeTrip.days.isEmpty
          ? const Center(child: Text('No active journey timeline to display.'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: activeTrip.days.length,
              itemBuilder: (context, dIdx) {
                final day = activeTrip.days[dIdx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          day.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      ..._buildDayStops(day, dIdx == 0, journeyService),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<Widget> _buildDayStops(DayPlan day, bool isTrackedDay, JourneyTrackingService journeyService) {
    final stops = day.stops;

    return List.generate(stops.length, (index) {
      final stop = stops[index];
      final isPassed = isTrackedDay && index <= journeyService.currentStopIndex;
      final isCurrent = isTrackedDay && index == journeyService.currentStopIndex;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator column
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isPassed
                      ? (isCurrent ? AppTheme.secondary : AppTheme.success)
                      : Colors.grey.shade300,
                  child: Icon(
                    isPassed ? (isCurrent ? Icons.near_me : Icons.check) : Icons.circle,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                if (index < stops.length - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPassed ? AppTheme.success : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stop.place.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCurrent ? AppTheme.secondary : null,
                                decoration: stop.isSkipped ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Text(
                            stop.startTime,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stop.place.category.displayName} · Dwell ${stop.estimatedDurationMinutes} min',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (isPassed && !isCurrent)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            '✓ Dwell verified & consented visit recorded',
                            style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600),
                          ),
                        ),
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
