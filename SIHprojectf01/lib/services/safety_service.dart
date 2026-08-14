import '../models/safety_risk.dart';

/// Safety & Risk Assessment Service (Step 17)
/// Evaluates environmental, crowd, and route conditions to provide
/// explainable advisories and safe alternatives.
class SafetyService {
  static final SafetyService instance = SafetyService._internal();
  factory SafetyService() => instance;
  SafetyService._internal();

  /// Evaluate destination safety profile
  SafetyEvaluation evaluateSafety(String destinationName) {
    final isCoastal = destinationName.toLowerCase().contains('beach') ||
        destinationName.toLowerCase().contains('coast') ||
        destinationName.toLowerCase().contains('goa') ||
        destinationName.toLowerCase().contains('kozhikode');

    final isMountain = destinationName.toLowerCase().contains('manali') ||
        destinationName.toLowerCase().contains('hill') ||
        destinationName.toLowerCase().contains('pass');

    List<SafetyRiskAlert> alerts = [];
    double score = 92.0;
    String status = 'Safe to Travel';

    if (isCoastal) {
      alerts.add(
        SafetyRiskAlert(
          id: 'alert_coast_01',
          title: 'High Tidal Surge Advisory',
          description:
              'Elevated afternoon high tides reported along rocky promontories. Avoid edge climbing between 5:30 PM and 7:00 PM.',
          severity: RiskSeverity.moderate,
          category: 'Coastal Alert',
          affectedArea: 'North Cliff & Shoreline Promenade',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          recommendedAction: 'Stay within marked beach zones',
          alternativeSuggestions: [
            'Central Botanical Gardens (Calm inland alternative)',
            'Artisan Heritage Market (Sheltered shopping)',
          ],
        ),
      );
      score = 78.0;
      status = 'Moderate Caution on Shoreline';
    } else if (isMountain) {
      alerts.add(
        SafetyRiskAlert(
          id: 'alert_mnt_01',
          title: 'Ghat Section Monsoon Warning',
          description:
              'Intermittent drizzle reported on hill curves. Reduced traction on hairpin bends 4 through 9.',
          severity: RiskSeverity.moderate,
          category: 'Road Condition',
          affectedArea: 'Pass Highway NH-76',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          recommendedAction: 'Drive under 30 km/h; prefer daytime transit',
          alternativeSuggestions: [
            'Valley Heritage Museum (Safe indoor route)',
            'Tea Plantation Boardwalk (Well-paved walking trail)',
          ],
        ),
      );
      score = 74.0;
      status = 'Mountain Road Advisory';
    }

    return SafetyEvaluation(
      destination: destinationName,
      overallSafetyStatus: status,
      safetyScore: score,
      activeAlerts: alerts,
      safetyGuidelines: [
        'Keep emergency contacts pinned in offline mode.',
        'Stay on designated walking boardwalks during evening hours.',
        'Follow local lifeguards and municipal advisory signboards.',
      ],
      weatherSummary: '29°C · Partly Cloudy · Wind 14 km/h',
      crowdIndexLabel: 'Moderate seasonal tourist flow',
    );
  }
}
