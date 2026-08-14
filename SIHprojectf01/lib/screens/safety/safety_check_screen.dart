import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/safety_risk.dart';
import '../../services/safety_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// SafetyCheckScreen — Pre-trip safety radar, environmental evaluations & safe alternatives (Step 17)
class SafetyCheckScreen extends StatelessWidget {
  final String tripId;
  const SafetyCheckScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripPlanningService.instance.activeTrip;
    final destination = activeTrip?.destinationName ?? 'Current Travel Zone';
    final eval = SafetyService.instance.evaluateSafety(destination);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Radar & Advisories'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Safety Score & Status Card
            _buildSafetyScoreCard(eval),

            const SizedBox(height: AppSpacing.md),

            // Active Advisories Section
            if (eval.activeAlerts.isNotEmpty) ...[
              Text(
                'Active Environmental & Route Advisories',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...eval.activeAlerts.map((alert) => _buildAlertCard(context, alert)),
              const SizedBox(height: AppSpacing.md),
            ],

            // Weather & Local Conditions Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Live Conditions Overlay', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${eval.weatherSummary} · ${eval.crowdIndexLabel}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Essential Safety Checklist
            Text(
              'TripSafe Essential Checklist',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...eval.safetyGuidelines.map(
              (guideline) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        guideline,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action button
            PrimaryButton(
              label: 'Proceed to Itinerary',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.itinerary),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyScoreCard(SafetyEvaluation eval) {
    final isSafe = eval.safetyScore >= 80;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSafe ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSafe ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isSafe ? AppTheme.success : AppTheme.warning,
            child: Text(
              '${eval.safetyScore.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eval.overallSafetyStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSafe ? Colors.green.shade900 : Colors.amber.shade900,
                  ),
                ),
                Text(
                  'Destination: ${eval.destination}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, SafetyRiskAlert alert) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.severity.label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(alert.description, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            'Recommended Action: ${alert.recommendedAction}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          if (alert.alternativeSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Safe Alternatives:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ...alert.alternativeSuggestions.map(
                    (alt) => Text('• $alt', style: TextStyle(fontSize: 11, color: Colors.grey.shade900)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.alt_route, size: 16),
              label: const Text('Adapt Trip Plan'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adapt),
            ),
          ),
        ],
      ),
    );
  }
}
