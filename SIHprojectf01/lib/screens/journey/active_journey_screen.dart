import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/trip_plan.dart';
import '../../services/journey_tracking_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// ActiveJourneyScreen — Live Journey Progress, Planned vs Observed stops & Deviation Logger (Step 10 & 11)
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
      appBar: AppBar(
        title: const Text('Active Journey Tracker'),
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
              message: 'No active trip found to track.\nGenerate a trip plan first!',
              icon: Icons.navigation_outlined,
              actionLabel: 'Plan Trip',
              action: () => Navigator.pushNamed(context, AppRoutes.plan),
            );
          }

          final dayStops = activeTrip.days.first.stops;
          final currentIdx = _journeyService.currentStopIndex;
          final currentStop = currentIdx < dayStops.length ? dayStops[currentIdx] : null;
          final pendingSpontaneous = _journeyService.pendingSpontaneousStop;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Live Tracking Header
                _buildLiveStatusBanner(activeTrip, currentIdx, dayStops.length),

                const SizedBox(height: AppSpacing.md),

                // Spontaneous Stop Alert Dialog / Card (Step 10 Deviation Detection)
                if (pendingSpontaneous != null)
                  _buildSpontaneousStopAlert(pendingSpontaneous),

                // Current Active Stop Card
                if (currentStop != null) ...[
                  _buildCurrentStopFocus(currentStop),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Planned vs Observed Comparison Section
                _buildPlannedVsObservedSection(dayStops, currentIdx),

                const SizedBox(height: AppSpacing.lg),

                // Demo Deviation Simulator Button for Hackathon Evaluation
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.science, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo: Simulate GPS dwell deviation at unvisited cafe',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                        ),
                      ),
                      TextButton(
                        onPressed: _journeyService.triggerDemoDeviation,
                        child: const Text('Simulate Stop', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Action controls
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
                        label: const Text('End Journey'),
                        onPressed: () {
                          _journeyService.endJourney();
                          Navigator.pushReplacementNamed(context, AppRoutes.summary);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: PrimaryButton(
                        label: 'View Timeline',
                        icon: Icons.timeline,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.timeline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveStatusBanner(TripPlan trip, int currentIdx, int totalStops) {
    final progress = totalStops > 0 ? (currentIdx / totalStops).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                    SizedBox(width: 6),
                    Text(
                      'TRACKING ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Stop $currentIdx of $totalStops Complete',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trip.title,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.greenAccent,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpontaneousStopAlert(dynamic place) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.blue.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, color: Colors.blue, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Spontaneous Stop Detected!',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Dwell: 22 min', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'You remained at "${place.name}" for >15 min. Would you like to log this visit and add it to your trip itinerary?',
            style: AppTypography.caption.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _journeyService.dismissSpontaneousStop,
                child: const Text('Dismiss', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add This Stop', style: TextStyle(color: Colors.white)),
                onPressed: _journeyService.confirmSpontaneousStop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStopFocus(StopItem stop) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: AppTheme.secondary, size: 20),
              const SizedBox(width: 6),
              Text(
                'CURRENT TARGET STOP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stop.place.name,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${stop.place.category.displayName} · Planned window: ${stop.startTime} – ${stop.endTime}',
            style: AppTypography.caption.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Estimated visit dwell: ${stop.estimatedDurationMinutes} minutes',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Verify Dwell & Complete Stop',
              icon: Icons.check_circle_outline,
              onPressed: () {
                _journeyService.completeCurrentStop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.success,
                    content: Text('✓ Completed stop: ${stop.place.name}. Logged consented visit.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedVsObservedSection(List<StopItem> plannedStops, int currentIdx) {
    final observed = _journeyService.observedStops;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planned Journey vs Observed Journey',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planned column
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PLANNED ROUTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    ...plannedStops.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${s.place.name}',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: s.isVisited ? TextDecoration.lineThrough : null,
                            color: s.isVisited ? Colors.grey : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Observed column
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OBSERVED DWELLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    const SizedBox(height: 6),
                    if (observed.isEmpty)
                      const Text('Starting route...', style: TextStyle(fontSize: 11, color: Colors.grey))
                    else
                      ...observed.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '✓ ${p.name}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
