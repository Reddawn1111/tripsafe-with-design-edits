/// Severity level of safety advisory
enum RiskSeverity {
  low('Low Risk', 1),
  moderate('Moderate Advisory', 2),
  high('High Warning', 3),
  severe('Severe Hazard', 4);

  final String label;
  final int level;
  const RiskSeverity(this.label, this.level);
}

/// Safety Alert model for real-time and simulated advisories
class SafetyRiskAlert {
  final String id;
  final String title;
  final String description;
  final RiskSeverity severity;
  final String category; // 'Weather', 'Coastal Alert', 'Road Closure', 'High Surge'
  final String affectedArea;
  final DateTime timestamp;
  final String recommendedAction;
  final List<String> alternativeSuggestions;
  final bool isDismissible;

  SafetyRiskAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.affectedArea,
    required this.timestamp,
    required this.recommendedAction,
    this.alternativeSuggestions = const [],
    this.isDismissible = true,
  });
}

/// Pre-trip Safety Evaluation result
class SafetyEvaluation {
  final String destination;
  final String overallSafetyStatus; // 'Safe to Travel', 'Caution Recommended', 'High Risk Detected'
  final double safetyScore; // 0.0 to 100.0 (higher is safer)
  final List<SafetyRiskAlert> activeAlerts;
  final List<String> safetyGuidelines;
  final String weatherSummary;
  final String crowdIndexLabel;

  SafetyEvaluation({
    required this.destination,
    required this.overallSafetyStatus,
    required this.safetyScore,
    required this.activeAlerts,
    required this.safetyGuidelines,
    this.weatherSummary = 'Clear skies, 28°C · Moderate breeze',
    this.crowdIndexLabel = 'Normal crowd levels',
  });
}
