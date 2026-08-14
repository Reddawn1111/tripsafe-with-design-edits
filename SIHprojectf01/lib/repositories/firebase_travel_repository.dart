import '../models/authority_insight.dart';
import '../models/place.dart';
import '../models/safety_risk.dart';
import '../models/trip_plan.dart';
import '../models/visit_record.dart';
import 'travel_data_repository.dart';

/// Firebase-backed implementation of [TravelDataRepository] — NOT YET
/// CONNECTED. Deliberately has no `firebase_core`/`cloud_firestore` import:
/// the interface shape is ready, but wiring up the real SDK is future work
/// (Stage 2+), per the product spec's "don't install a huge Firebase stack
/// unless required" rule. Every method throws until that work happens.
class FirebaseTravelRepository implements TravelDataRepository {
  static const _notConnectedMessage =
      'FirebaseTravelRepository is not yet connected. Install '
      'firebase_core/cloud_firestore and implement this adapter to enable '
      'Firebase as the active backend.';

  @override
  Future<TripPlan?> getActiveTrip() async {
    throw UnimplementedError(_notConnectedMessage);
  }

  @override
  Future<TripPlan> saveTrip(TripPlan trip) async {
    throw UnimplementedError(_notConnectedMessage);
  }

  @override
  Future<void> recordVisitEvent(ConsentedVisit visit) async {
    throw UnimplementedError(_notConnectedMessage);
  }

  @override
  Future<AggregateVisitStats?> getPlaceInsights(Place place) async {
    throw UnimplementedError(_notConnectedMessage);
  }

  @override
  Future<SafetyEvaluation> getSafetyEvaluation(String destinationName) async {
    throw UnimplementedError(_notConnectedMessage);
  }

  @override
  Future<List<ExplainablePriorityItem>> getAuthorityInsights() async {
    throw UnimplementedError(_notConnectedMessage);
  }
}
