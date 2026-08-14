import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/safety_risk.dart';
import '../../services/safety_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// RiskAlertScreen — Detailed view of an active risk alert with adaptation triggers (Step 17)
class RiskAlertScreen extends StatelessWidget {
  final String tripId;
  final String alertId;

  const RiskAlertScreen({
    super.key,
    this.tripId = '',
    this.alertId = '',
  });

  @override
  Widget build(BuildContext context) {
    final eval = SafetyService.instance.evaluateSafety('Coastal Tourism Corridor');
    final alert = eval.activeAlerts.isNotEmpty
        ? eval.activeAlerts.first
        : SafetyRiskAlert(
            id: 'alert_gen_01',
            title: 'High Coastal Surge Warning',
            description: 'Unusual tidal swells detected along shoreline rocky promenades.',
            severity: RiskSeverity.high,
            category: 'Coastal Risk',
            affectedArea: 'North Cliff Boardwalk',
            timestamp: DateTime.now(),
            recommendedAction: 'Avoid rocky edge climbing; reroute to indoor heritage spots',
            alternativeSuggestions: [
              'Regional Art & Maritime Museum (Indoor safe)',
              'Central Botanical Gardens (Calm inland walking)',
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety & Risk Advisory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppTheme.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 36, color: AppTheme.warning),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        Text(
                          'Category: ${alert.category} · Affected: ${alert.affectedArea}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Advisory Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(alert.description, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  const Text('Recommended Protocol:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(alert.recommendedAction, style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (alert.alternativeSuggestions.isNotEmpty) ...[
              const Text('Suggested Safe Alternatives:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...alert.alternativeSuggestions.map(
                (alt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route, color: AppTheme.secondary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(alt, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            PrimaryButton(
              label: 'Adapt My Trip Plan',
              icon: Icons.alt_route,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adapt),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(child: Text('Dismiss Advisory')),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
