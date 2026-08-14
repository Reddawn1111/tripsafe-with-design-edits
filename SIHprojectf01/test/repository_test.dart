import 'package:flutter_test/flutter_test.dart';
import 'package:tripsafe/models/trip_plan.dart';
import 'package:tripsafe/repositories/firebase_travel_repository.dart';
import 'package:tripsafe/repositories/local_demo_travel_repository.dart';
import 'package:tripsafe/repositories/supabase_travel_repository.dart';
import 'package:tripsafe/services/trip_planning_service.dart';

void main() {
  group('LocalDemoTravelRepository', () {
    test('getActiveTrip reads through to TripPlanningService.instance', () async {
      final repo = LocalDemoTravelRepository();
      final fromRepo = await repo.getActiveTrip();
      expect(fromRepo, same(TripPlanningService.instance.activeTrip));
    });

    test('saveTrip writes through to TripPlanningService.instance', () async {
      final repo = LocalDemoTravelRepository();
      final newTrip = TripPlan(
        id: 'repo_test_trip',
        title: 'Repository Test Trip',
        destinationName: 'Test Destination',
        destinationLat: 1.0,
        destinationLng: 2.0,
        totalBudget: 1000.0,
        days: const [],
      );

      final saved = await repo.saveTrip(newTrip);

      expect(saved.id, 'repo_test_trip');
      expect(TripPlanningService.instance.activeTrip?.id, 'repo_test_trip');
    });
  });

  group('Backend adapter stubs (not yet connected)', () {
    test('FirebaseTravelRepository throws UnimplementedError', () async {
      final repo = FirebaseTravelRepository();
      expect(() => repo.getActiveTrip(), throwsUnimplementedError);
    });

    test('SupabaseTravelRepository throws UnimplementedError', () async {
      final repo = SupabaseTravelRepository();
      expect(() => repo.getActiveTrip(), throwsUnimplementedError);
    });
  });
}
