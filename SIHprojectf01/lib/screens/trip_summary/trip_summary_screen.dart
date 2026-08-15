import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// TripSummaryScreen — post-trip recap, dark "accent panel" theme.
/// Layout order unchanged: completion panel, metrics grid, contribution
/// note, return home.
class TripSummaryScreen extends StatelessWidget {
  final String tripId;
  const TripSummaryScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;
    final activeTrip = planningService.activeTrip;

    return Scaffold(
      appBar: const TripSafeAppBar(title: 'Trip summary'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccentPanel(
              color: AppTheme.success,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.celebration, size: 34),
                  const SizedBox(height: 14),
                  Text(
                    'JOURNEY\nCOMPLETED',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppTheme.onSuccess,
                      fontSize: 32,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activeTrip?.title ?? 'Coastal Trail & City Getaway',
                    style: AppTypography.chipLabel.copyWith(
                      fontSize: 12.5,
                      color: AppTheme.onSuccess.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            const SectionLabel('Highlights & metrics'),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    context,
                    'Stops visited',
                    '${activeTrip?.totalStopsCount ?? 4}',
                    Icons.pin_drop,
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricTile(
                    context,
                    'Trip days',
                    '${activeTrip?.days.length ?? 1}',
                    Icons.calendar_today,
                    AppTheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    context,
                    'Mobility dwells',
                    '4 verified',
                    Icons.timer,
                    AppTheme.info,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricTile(
                    context,
                    'Safety index',
                    '100% safe',
                    Icons.shield,
                    AppTheme.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            AppCard(
              accentBorder: AppTheme.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.volunteer_activism_outlined,
                        color: AppTheme.info,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Travel intelligence contribution',
                          style: AppTypography.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Your anonymous dwell events have helped update community visit '
                    'hours and best-time-to-visit recommendations for fellow travellers.',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppTheme.body(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Return to home',
              icon: Icons.home,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (_) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleLarge.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.chipLabel.copyWith(
              fontSize: 9.5,
              letterSpacing: 1,
              color: AppTheme.muted(context),
            ),
          ),
        ],
      ),
    );
  }
}
