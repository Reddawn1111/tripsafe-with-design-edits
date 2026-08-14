import '../models/authority_insight.dart';
import '../models/place.dart';
import '../models/safety_risk.dart';
import '../models/trip_plan.dart';
import '../models/visit_record.dart';
import 'travel_data_repository.dart';

/// Supabase-backed implementation of [TravelDataRepository] — NOT YET
/// CONNECTED. Deliberately has no `supabase_flutter` import: the interface
/// shape is ready, but wiring up the real SDK is future work (Stage 2+),
/// per the product spec's "no unnecessary package bloat" rule. Every
/// method throws until that work happens.
class SupabaseTravelRepository implements TravelDataRepository {
  static const _notConnectedMessage =
      'SupabaseTravelRepository is not yet connected. Install '
      'supabase_flutter and implement this adapter to enable Supabase as '
      'the active backend.';

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
