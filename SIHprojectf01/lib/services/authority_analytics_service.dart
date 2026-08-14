import '../models/authority_insight.dart';

/// Service generating aggregate mobility intelligence and Explainable Priority Rankings
/// for Tourism & Municipal Authorities (Steps 15, 16).
class AuthorityAnalyticsService {
  static final AuthorityAnalyticsService instance = AuthorityAnalyticsService._internal();
  factory AuthorityAnalyticsService() => instance;
  AuthorityAnalyticsService._internal();

  /// Fetches district-level mobility summary with explainable priority scores
  DistrictMobilitySummary getDistrictMobilitySummary({String districtName = 'Coastal Tourism Corridor (Kozhikode)'}) {
    final priorityItems = [
      ExplainablePriorityItem(
        id: 'rec_001',
        title: 'Sanitation & Seating Capacity Review',
        locationName: 'Sunset Promenade & Beach Walk',
        priorityScore: 88,
        urgency: 'High',
        category: 'Facility Improvement / Sanitation',
        confidence: 'High (840 aggregate dwell observations)',
        evidence:
            'Observed 1,820 peak visits with 54 min average dwell between 5–8 PM. Current public toilet & shaded bench capacity index is 85% utilized.',
        recommendedAction:
            'Potential pressure detected. Capacity review recommended for portable sanitation kiosks and additional promenade seating.',
        expectedImpact: 'Reduces visitor queue times by ~35% and improves pedestrian comfort index.',
        validationStatus: 'Requires field validation',
        scoreComponents: {
          'Peak Visitor Volume': 0.35,
          'Long Dwell Time': 0.25,
          'Facility Stress Factor': 0.20,
          'Visitor Growth Rate': 0.20,
        },
        classification: DataClassificationType.recommended,
      ),
      ExplainablePriorityItem(
        id: 'rec_002',
        title: 'Corridor Traffic & Park-and-Ride Feasibility',
        locationName: 'North Beach Highway Corridor (NH-66 Jn)',
        priorityScore: 82,
        urgency: 'High',
        category: 'Road Pressure & Parking',
        confidence: 'High (GPS transit speed profiles)',
        evidence:
            'High vehicular flow (est. 450 vehicles/hr) with average transit delay of 18 min on the 2.4 km approach during weekend evenings.',
        recommendedAction:
            'Potential corridor bottleneck detected. Consider deploying weekend shuttle loop from South Stadium lot and dynamic signage.',
        expectedImpact: 'Estimated 28% reduction in beachfront road congestion.',
        validationStatus: 'Under municipal review',
        scoreComponents: {
          'Transit Delay Index': 0.35,
          'Vehicle Influx': 0.30,
          'Parking Occupancy': 0.20,
          'Safety Gap': 0.15,
        },
        classification: DataClassificationType.recommended,
      ),
      ExplainablePriorityItem(
        id: 'rec_003',
        title: 'Visitor Flow Redistribution Campaign',
        locationName: 'Heritage Crafts Market vs Central Arboretum',
        priorityScore: 71,
        urgency: 'Medium',
        category: 'Visitor Redistribution',
        confidence: 'Moderate (Cross-destination visit graphs)',
        evidence:
            'Crafts Market operates at 92% crowd density while nearby Central Arboretum (0.8 km away) remains at 34% capacity during identical afternoon hours.',
        recommendedAction:
            'Promote combined heritage walking circuit in app discovery to distribute pedestrian load to underutilized park zone.',
        expectedImpact: 'Forecasted 15–20% footfall balance between adjacent sites.',
        validationStatus: 'Validated by pilot data',
        scoreComponents: {
          'Density Imbalance': 0.40,
          'Proximity Score': 0.30,
          'Visitor Interest Alignment': 0.30,
        },
        classification: DataClassificationType.recommended,
      ),
      ExplainablePriorityItem(
        id: 'rec_004',
        title: 'Tidal Safety Boardwalk Signage',
        locationName: 'Rocky Cove Viewpoint',
        priorityScore: 68,
        urgency: 'Medium',
        category: 'Safety Monitoring',
        confidence: 'High (Coastal alert overlay)',
        evidence:
            'High visitor interest for photography coinciding with elevated spring high-tide advisory.',
        recommendedAction:
            'Deploy illuminated warning signage and active lifeguard patrol during 5:00–7:00 PM window.',
        expectedImpact: 'Prevents rocky edge slipping incidents during peak photography hours.',
        validationStatus: 'Requires field validation',
        scoreComponents: {
          'Environmental Risk': 0.45,
          'Visitor Footfall': 0.35,
          'Physical Barrier Adequacy': 0.20,
        },
        classification: DataClassificationType.recommended,
      ),
    ];

    final corridors = [
      MobilityCorridor(
        id: 'corridor_1',
        originName: 'City Center / Rail Terminal',
        destinationName: 'Sunset Promenade Beach',
        estimatedHourlyVolume: 620,
        averageTravelMinutes: 22,
        bottleneckRiskScore: 0.72,
        suggestedIntervention: 'Run dedicated electric tourist shuttles during 4:30–8:30 PM',
      ),
      MobilityCorridor(
        id: 'corridor_2',
        originName: 'Heritage Quarter',
        destinationName: 'Bazaar & Food Street',
        estimatedHourlyVolume: 410,
        averageTravelMinutes: 12,
        bottleneckRiskScore: 0.45,
        suggestedIntervention: 'Designate pedestrian-only zone on Bazaar Street past 6:00 PM',
      ),
      MobilityCorridor(
        id: 'corridor_3',
        originName: 'North Highway Junction',
        destinationName: 'Hillside Viewpoint',
        estimatedHourlyVolume: 290,
        averageTravelMinutes: 16,
        bottleneckRiskScore: 0.58,
        suggestedIntervention: 'Active traffic wardens at hairpin bend 2',
      ),
    ];

    return DistrictMobilitySummary(
      districtName: districtName,
      totalActiveTravellers: 3840,
      totalVisitsToday: 14200,
      averageDwellMinutes: 52.4,
      peakCrowdIndex: 0.76,
      activeAlertsCount: 2,
      priorityActions: priorityItems,
      majorCorridors: corridors,
      isDemoData: true,
    );
  }
}
