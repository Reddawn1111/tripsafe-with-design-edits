import '../models/authority_insight.dart';
import '../models/place.dart';
import '../models/safety_risk.dart';
import '../models/trip_plan.dart';
import '../models/visit_record.dart';

/// Backend-ready data access interface for TripSafe.
///
/// The UI and application services never talk to Firebase/Supabase SDKs
/// directly — they go through this interface. The active implementation
/// today is [LocalDemoTravelRepository] (a thin adapter over the existing
/// in-memory singleton services). [FirebaseTravelRepository] and
/// [SupabaseTravelRepository] exist as interface-conformant stubs so the
/// shape is ready, without requiring either SDK to be installed yet.
///
/// Scoped to what the app can actually exercise today: trips, itinerary,
/// visit events, place/safety/authority insight reads. Not a speculative
/// full CRUD surface for entities nothing in the app produces yet.
abstract class TravelDataRepository {
  Future<TripPlan?> getActiveTrip();

  Future<TripPlan> saveTrip(TripPlan trip);

  Future<void> recordVisitEvent(ConsentedVisit visit);

  Future<AggregateVisitStats?> getPlaceInsights(Place place);

  Future<SafetyEvaluation> getSafetyEvaluation(String destinationName);

  Future<List<ExplainablePriorityItem>> getAuthorityInsights();
}
