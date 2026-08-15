import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/safety_risk.dart';
import '../../services/safety_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// RiskAlertScreen — detailed risk advisory, dark "accent panel" theme.
/// Layout order unchanged: alert panel, advisory details, alternatives,
/// adapt / dismiss actions.
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
    final eval =
        SafetyService.instance.evaluateSafety('Coastal Tourism Corridor');
    final alert = eval.activeAlerts.isNotEmpty
        ? eval.activeAlerts.first
        : SafetyRiskAlert(
            id: 'alert_gen_01',
            title: 'High Coastal Surge Warning',
            description:
                'Unusual tidal swells detected along shoreline rocky promenades.',
            severity: RiskSeverity.high,
            category: 'Coastal Risk',
            affectedArea: 'North Cliff Boardwalk',
            timestamp: DateTime.now(),
            recommendedAction:
                'Avoid rocky edge climbing; reroute to indoor heritage spots',
            alternativeSuggestions: [
              'Regional Art & Maritime Museum (Indoor safe)',
              'Central Botanical Gardens (Calm inland walking)',
            ],
          );

    final accent =
        alert.severity.level >= 3 ? AppTheme.danger : AppTheme.warning;
    final ink = AccentPanel.inkFor(accent);

    return Scaffold(
      appBar: const TripSafeAppBar(title: 'Risk advisory'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccentPanel(
              color: accent,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 22, color: ink),
                      const SizedBox(width: 9),
                      Text(
                        alert.severity.label.toUpperCase(),
                        style: AppTypography.sectionLabel.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 1.8,
                          color: ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.title.toUpperCase(),
                    style: AppTypography.displayMedium.copyWith(
                      color: ink,
                      fontSize: 25,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${alert.category} · ${alert.affectedArea}',
                    style: AppTypography.chipLabel.copyWith(
                      fontSize: 12,
                      color: ink.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Advisory details'),
                  const SizedBox(height: 9),
                  Text(
                    alert.description,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 12.5,
                      color: AppTheme.body(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppTheme.borderDark),
                  const SizedBox(height: 14),
                  Text(
                    'RECOMMENDED PROTOCOL',
                    style: AppTypography.sectionLabel.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.recommendedAction,
                    style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                  ),
                ],
              ),
            ),

            if (alert.alternativeSuggestions.isNotEmpty) ...[
              const SizedBox(height: 22),
              const SectionLabel('Safe alternatives'),
              const SizedBox(height: 11),
              ...alert.alternativeSuggestions.map(
                (alt) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.alt_route,
                        color: Color(0xFF00BFA6),
                        size: 16,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          alt,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12.5,
                            color: AppTheme.body(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),
            PrimaryButton(
              label: 'Adapt my trip plan',
              icon: Icons.alt_route,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adapt),
            ),
            const SizedBox(height: 11),
            SecondaryButton(
              label: 'Dismiss advisory',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
