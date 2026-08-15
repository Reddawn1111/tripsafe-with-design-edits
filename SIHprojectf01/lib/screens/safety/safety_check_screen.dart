import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/safety_risk.dart';
import '../../services/safety_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// SafetyCheckScreen — pre-trip safety radar, dark "accent panel" theme.
/// Layout order unchanged: score panel, advisories, live conditions,
/// essential checklist, proceed action.
class SafetyCheckScreen extends StatelessWidget {
  final String tripId;
  const SafetyCheckScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripPlanningService.instance.activeTrip;
    final destination = activeTrip?.destinationName ?? 'Current Travel Zone';
    final eval = SafetyService.instance.evaluateSafety(destination);

    return Scaffold(
      appBar: const TripSafeAppBar(title: 'Safety Radar'),
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
            _buildScorePanel(context, eval),

            if (eval.activeAlerts.isNotEmpty) ...[
              const SizedBox(height: 22),
              SectionLabel('Active advisories · ${eval.activeAlerts.length}'),
              const SizedBox(height: 11),
              ...eval.activeAlerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _buildAlertCard(context, alert),
                ),
              ),
            ],

            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  const IconChip(
                    icon: Icons.wb_sunny_outlined,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live conditions overlay',
                          style: AppTypography.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${eval.weatherSummary} · ${eval.crowdIndexLabel}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11.5,
                            color: AppTheme.muted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            const SectionLabel('Essential checklist'),
            const SizedBox(height: 10),
            ...eval.safetyGuidelines.map(
              (guideline) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        guideline,
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

            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Proceed to itinerary',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.itinerary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Score panel — the one saturated panel on this screen ───────────────
  Widget _buildScorePanel(BuildContext context, SafetyEvaluation eval) {
    final isSafe = eval.safetyScore >= 80;
    final accent = isSafe ? AppTheme.success : AppTheme.warning;
    final ink = AccentPanel.inkFor(accent);

    return AccentPanel(
      color: accent,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OVERALL STATUS',
                      style: AppTypography.sectionLabel.copyWith(
                        fontSize: 10.5,
                        letterSpacing: 1.6,
                        color: ink.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      eval.overallSafetyStatus.toUpperCase(),
                      style: AppTypography.displayMedium.copyWith(
                        color: ink,
                        fontSize: 25,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${eval.safetyScore.round()}',
                    style: AppTypography.displayLarge.copyWith(
                      color: ink,
                      fontSize: 54,
                      letterSpacing: -2.6,
                      height: 0.85,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/ 100 SCORE',
                    style: AppTypography.chipLabel.copyWith(
                      fontSize: 10.5,
                      letterSpacing: 1,
                      color: ink.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ink,
                  borderRadius: AppSpacing.pill,
                ),
                child: Text(
                  eval.destination,
                  style: AppTypography.chipLabel.copyWith(color: accent),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: ink.withValues(alpha: 0.3), width: 1.5),
                  borderRadius: AppSpacing.pill,
                ),
                child: Text(
                  'Updated just now',
                  style: AppTypography.chipLabel.copyWith(color: ink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Advisory card ──────────────────────────────────────────────────────
  Widget _buildAlertCard(BuildContext context, SafetyRiskAlert alert) {
    final accent = alert.severity.level >= 3 ? AppTheme.danger : AppTheme.warning;

    return AppCard(
      accentBorder: accent,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: accent, size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Text(alert.title, style: AppTypography.titleSmall),
              ),
              const SizedBox(width: 8),
              StatusPill(label: alert.severity.label, color: accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.description,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              color: AppTheme.body(context),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.borderDark),
          const SizedBox(height: 12),
          Text(
            'RECOMMENDED ACTION',
            style: AppTypography.sectionLabel.copyWith(
              fontSize: 10,
              letterSpacing: 1.4,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            alert.recommendedAction,
            style: AppTypography.bodySmall.copyWith(fontSize: 12),
          ),
          if (alert.alternativeSuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Tinted chips, not a light panel — keeps contrast on charcoal.
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: alert.alternativeSuggestions
                  .map(
                    (alt) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Alt: $alt',
                        style: AppTypography.chipLabel.copyWith(fontSize: 11),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PillButton(
              label: 'Adapt trip plan',
              icon: Icons.alt_route,
              color: AppTheme.primary,
              dense: true,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adapt),
            ),
          ),
        ],
      ),
    );
  }
}
