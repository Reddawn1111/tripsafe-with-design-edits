import '../models/authority_insight.dart';
import '../models/place.dart';
import '../models/safety_risk.dart';
import '../models/trip_plan.dart';
import '../models/visit_record.dart';
import '../services/authority_analytics_service.dart';
import '../services/safety_service.dart';
import '../services/travel_insights_service.dart';
import '../services/trip_planning_service.dart';
import 'travel_data_repository.dart';

/// Default MVP repository: a thin adapter over the app's existing in-memory
/// singleton services. This is intentionally NOT a new data store — it
/// forwards straight into [TripPlanningService], [TravelInsightsService],
/// [SafetyService] and [AuthorityAnalyticsService] so screens that already
/// read those singletons directly stay the single source of truth.
class LocalDemoTravelRepository implements TravelDataRepository {
  @override
  Future<TripPlan?> getActiveTrip() async {
    return TripPlanningService.instance.activeTrip;
  }

  @override
  Future<TripPlan> saveTrip(TripPlan trip) async {
    TripPlanningService.instance.setActiveTrip(trip);
    return trip;
  }

  @override
  Future<void> recordVisitEvent(ConsentedVisit visit) async {
    TravelInsightsService.instance.recordConsentedVisit(visit);
  }

  @override
  Future<AggregateVisitStats?> getPlaceInsights(Place place) async {
    return TravelInsightsService.instance.getAggregateStats(place);
  }

  @override
  Future<SafetyEvaluation> getSafetyEvaluation(String destinationName) async {
    return SafetyService.instance.evaluateSafety(destinationName);
  }

  @override
  Future<List<ExplainablePriorityItem>> getAuthorityInsights() async {
    return AuthorityAnalyticsService.instance
        .getDistrictMobilitySummary()
        .priorityActions;
  }
}
