/// Data classification tag for authority transparency
enum DataClassificationType {
  observed('OBSERVED', 'Direct anonymous GPS/sensor measurements'),
  calculated('CALCULATED', 'Aggregated mathematical totals & averages'),
  inferred('INFERRED', 'Statistical demand & pressure estimates'),
  recommended('RECOMMENDED', 'Actionable policy or infrastructure intervention');

  final String label;
  final String description;

  const DataClassificationType(this.label, this.description);
}

/// Explainable Priority Ranking item for Tourism & Municipal Authorities (Step 16)
class ExplainablePriorityItem {
  final String id;
  final String title;
  final String locationName;
  final int priorityScore; // 1 to 100
  final String urgency; // 'Immediate', 'High', 'Medium', 'Routine'
  final String category; // 'Crowd Management', 'Facility Improvement', 'Road Pressure', etc.
  final String confidence; // 'High (92%)', 'Moderate (78%)'
  final String evidence;
  final String recommendedAction;
  final String expectedImpact;
  final String validationStatus; // 'Requires field validation', 'Under review', 'Validated'
  final Map<String, double> scoreComponents; // e.g. {'visitation': 0.35, 'dwell': 0.25, 'risk': 0.20, 'capacity': 0.20}
  final DataClassificationType classification;

  ExplainablePriorityItem({
    required this.id,
    required this.title,
    required this.locationName,
    required this.priorityScore,
    required this.urgency,
    required this.category,
    required this.confidence,
    required this.evidence,
    required this.recommendedAction,
    required this.expectedImpact,
    this.validationStatus = 'Requires field validation',
    required this.scoreComponents,
    this.classification = DataClassificationType.recommended,
  });
}

/// Movement flow between tourist hotspots
class MobilityCorridor {
  final String id;
  final String originName;
  final String destinationName;
  final int estimatedHourlyVolume;
  final int averageTravelMinutes;
  final double bottleneckRiskScore; // 0.0 to 1.0
  final String suggestedIntervention;

  MobilityCorridor({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.estimatedHourlyVolume,
    required this.averageTravelMinutes,
    required this.bottleneckRiskScore,
    required this.suggestedIntervention,
  });
}

/// Aggregate crowd & infrastructure pressure summary for a district
class DistrictMobilitySummary {
  final String districtName;
  final int totalActiveTravellers;
  final int totalVisitsToday;
  final double averageDwellMinutes;
  final double peakCrowdIndex; // 0.0 to 1.0
  final int activeAlertsCount;
  final List<ExplainablePriorityItem> priorityActions;
  final List<MobilityCorridor> majorCorridors;
  final bool isDemoData;

  DistrictMobilitySummary({
    required this.districtName,
    required this.totalActiveTravellers,
    required this.totalVisitsToday,
    required this.averageDwellMinutes,
    required this.peakCrowdIndex,
    required this.activeAlertsCount,
    required this.priorityActions,
    required this.majorCorridors,
    this.isDemoData = true,
  });
}
