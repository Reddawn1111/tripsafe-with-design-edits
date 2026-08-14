import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/trip_plan.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// ItineraryScreen — Displays the user's trip itinerary and day route stops (Step 8)
class ItineraryScreen extends StatelessWidget {
  final String tripId;
  const ItineraryScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Itinerary & Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'Edit Plan Parameters',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: planningService,
        builder: (context, _) {
          final trip = planningService.activeTrip;

          if (trip == null || trip.days.isEmpty || trip.totalStopsCount == 0) {
            return EmptyState(
              message:
                  'Your trip itinerary is currently empty.\nExplore nearby places or generate a budget plan!',
              icon: Icons.map_outlined,
              actionLabel: 'Explore Nearby Places',
              action: () => Navigator.of(context).pushNamed(AppRoutes.discover),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Header Card
                _buildTripHeader(context, trip),

                const SizedBox(height: AppSpacing.md),

                // Days and Stops
                ...trip.days.asMap().entries.map((entry) {
                  final dIdx = entry.key;
                  final day = entry.value;
                  return _buildDayCard(context, planningService, trip, day, dIdx);
                }),

                const SizedBox(height: AppSpacing.lg),

                // Action Buttons
                PrimaryButton(
                  label: 'Start Active Journey',
                  icon: Icons.navigation_outlined,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.journey),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.expenses),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Group Expenses & Settlement'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripHeader(BuildContext context, TripPlan trip) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${trip.destinationName} · ${trip.members.length} Travellers',
                      style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Code: ${trip.inviteCode}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Total Stops', '${trip.totalStopsCount}'),
              _buildStat('Total Budget', '₹${trip.totalBudget.round()}'),
              _buildStat('Planned Cost', '₹${trip.totalSpentOrPlanned.round()}'),
              _buildStat(
                'Remaining',
                '₹${trip.remainingBudget.round()}',
                color: trip.remainingBudget >= 0 ? AppTheme.success : AppTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    TripPlanningService service,
    TripPlan trip,
    DayPlan day,
    int dIdx,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
            ),
            child: Row(
              children: [
                Text(
                  day.title,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.route, size: 20, color: AppTheme.secondary),
                  tooltip: 'Auto-optimize route order',
                  onPressed: () {
                    service.optimizeDayRoute(dIdx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route optimized for minimal travel time!')),
                    );
                  },
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: day.stops.length,
            itemBuilder: (context, sIdx) {
              final stop = day.stops[sIdx];
              final isFirst = sIdx == 0;

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isFirst)
                      Padding(
                        padding: const EdgeInsets.only(left: 14, bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              '${stop.distanceFromPreviousKm.toStringAsFixed(1)} km · ~${stop.travelTimeFromPreviousMinutes} min transit',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: stop.isVisited
                              ? AppTheme.success
                              : AppTheme.primary.withValues(alpha: 0.12),
                          child: Text(
                            stop.isVisited ? '✓' : '${sIdx + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              color: stop.isVisited ? Colors.white : AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.place.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: stop.isVisited ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              Text(
                                '${stop.startTime} – ${stop.endTime} · (${stop.estimatedDurationMinutes}m visit)',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              if (stop.optimizationHint != null)
                                Text(
                                  stop.optimizationHint!,
                                  style: TextStyle(fontSize: 10, color: Colors.orange.shade900),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          stop.estimatedCost > 0 ? '₹${stop.estimatedCost.round()}' : 'Free',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: stop.estimatedCost > 0 ? AppTheme.primary : AppTheme.success,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                          onPressed: () => service.removeStop(dIdx, stop.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
