import 'package:flutter/material.dart';
import '../../models/authority_insight.dart';
import '../../services/authority_analytics_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// AuthorityDashboardScreen — Tourism & Municipal Authority Mobility Intelligence Portal (Steps 15 & 16)
class AuthorityDashboardScreen extends StatelessWidget {
  const AuthorityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = AuthorityAnalyticsService.instance.getDistrictMobilitySummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authority Mobility & Tourism Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Data Provenance & Privacy Guarantees',
            onPressed: () => _showPrivacyPolicyDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Transparency Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0x144DA3FF),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: const Color(0x4D4DA3FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aggregated from consenting travellers · Strict k-anonymity (k ≥ 50) · No individual tracking',
                      style: TextStyle(fontSize: 11, color: AppTheme.info, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // District Mobility Metrics Overview
            Text(summary.districtName, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: _buildMetricCard('Active Travellers', '${summary.totalActiveTravellers}', 'In district now', Icons.people_outline)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildMetricCard('Visits Today', '${summary.totalVisitsToday}', 'Verified dwells >15m', Icons.location_city)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Avg Dwell Time', '${summary.averageDwellMinutes.toStringAsFixed(1)} min', 'Across all POIs', Icons.timer_outlined)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMetricCard(
                    'Peak Crowd Index',
                    '${(summary.peakCrowdIndex * 100).round()}%',
                    'Elevated weekend load',
                    Icons.trending_up,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Key Mobility Corridors & Road Pressure
            Text('Mobility Corridors & Transit Pressure', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...summary.majorCorridors.map((c) => _buildCorridorCard(c)),

            const SizedBox(height: AppSpacing.lg),

            // Actionable Infrastructure Intelligence: Explainable Priority Ranking (Step 16)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explainable Priority Ranking',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Score / 100', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...summary.priorityActions.map((action) => _buildPriorityCard(context, action)),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String sub, IconData icon, {Color? color}) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? AppTheme.primary),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? AppTheme.primary)),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppTheme.mutedDark)),
        ],
      ),
    );
  }

  Widget _buildCorridorCard(MobilityCorridor c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${c.originName} ➔ ${c.destinationName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Text(
                  '~${c.estimatedHourlyVolume} trav/hr',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Average transit duration: ${c.averageTravelMinutes} min', style: const TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0x0FFFFFFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '💡 Suggested Intervention: ${c.suggestedIntervention}',
                style: const TextStyle(fontSize: 11, color: AppTheme.subtleDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(BuildContext context, ExplainablePriorityItem item) {
    final urgencyColor = item.urgency == 'High' ? AppTheme.danger : Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with score badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    '${item.priorityScore}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('📍 ${item.locationName}', style: const TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.urgency,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: urgencyColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Evidence
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Evidence: ${item.evidence}', style: const TextStyle(fontSize: 11, color: AppTheme.subtleDark)),
                  const SizedBox(height: 4),
                  Text('Confidence: ${item.confidence}', style: const TextStyle(fontSize: 10, color: AppTheme.mutedDark)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Action & Impact
            Text(
              'Recommended Action: ${item.recommendedAction}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Expected Impact: ${item.expectedImpact}',
              style: const TextStyle(fontSize: 11, color: Colors.green),
            ),
            const SizedBox(height: 6),

            // Classification tag and Validation status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.borderDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.classification.label,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.subtleDark),
                  ),
                ),
                Text(
                  'Status: ${item.validationStatus}',
                  style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppTheme.mutedDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('TRIPSAFE Privacy Guarantees'),
        content: const Text(
          '1. No individual traveller data is ever exposed to authorities.\n'
          '2. All records are aggregated over minimum k=50 consenting users.\n'
          '3. Coordinates are obfuscated to district zones.\n'
          '4. No invasive background tracking or sensitive device data is collected.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
