import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// TripSummaryScreen — Post-trip statistics, mobility contribution recap & wrap-up
class TripSummaryScreen extends StatelessWidget {
  final String tripId;
  const TripSummaryScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;
    final activeTrip = planningService.activeTrip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Completion Summary'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration, color: Colors.white, size: 48),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Journey Completed!',
                    style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    activeTrip?.title ?? 'Coastal Trail & City Getaway',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Trip Highlights & Metrics', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricTile('Stops Visited', '${activeTrip?.totalStopsCount ?? 4}', Icons.pin_drop)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildMetricTile('Trip Days', '${activeTrip?.days.length ?? 1}', Icons.calendar_today)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: _buildMetricTile('Mobility Dwells', '4 Verified', Icons.timer)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildMetricTile('Safety Index', '100% Safe', Icons.shield)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Mobility Contribution Note (Step 12 loop)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism_outlined, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Travel Intelligence Contribution',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your anonymous dwell events have helped update community visit hours and best time to visit recommendations for fellow travellers!',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade900),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            PrimaryButton(
              label: 'Return to Home',
              icon: Icons.home,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
