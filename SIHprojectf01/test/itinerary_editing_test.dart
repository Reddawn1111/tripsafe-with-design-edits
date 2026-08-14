import 'package:flutter_test/flutter_test.dart';
import 'package:tripsafe/models/itinerary_conflict.dart';
import 'package:tripsafe/models/place.dart';
import 'package:tripsafe/models/place_category.dart';
import 'package:tripsafe/models/trip_plan.dart';
import 'package:tripsafe/services/itinerary_conflict_service.dart';
import 'package:tripsafe/services/route_optimization_service.dart';
import 'package:tripsafe/services/travel_insights_service.dart';
import 'package:tripsafe/services/trip_planning_service.dart';

Place _place(String id, String name, double lat, double lon, {int dwellMinutes = 30, double cost = 0.0}) {
  return Place(
    id: id,
    name: name,
    latitude: lat,
    longitude: lon,
    address: 'Test Address',
    category: PlaceCategory.attraction,
    typicalDwellMinutes: dwellMinutes,
    estimatedCost: cost,
  );
}

TripPlan _buildTestTrip() {
  final stops = [
    StopItem(id: 'a', place: _place('pa', 'Alpha', 11.25, 75.78, cost: 100), startTime: '9:00 AM', endTime: '9:30 AM', estimatedDurationMinutes: 30, estimatedCost: 100),
    StopItem(id: 'b', place: _place('pb', 'Beta', 11.26, 75.79, cost: 200), startTime: '10:00 AM', endTime: '10:30 AM', estimatedDurationMinutes: 30, estimatedCost: 200),
    StopItem(id: 'c', place: _place('pc', 'Gamma', 11.27, 75.80, cost: 300), startTime: '11:00 AM', endTime: '11:30 AM', estimatedDurationMinutes: 30, estimatedCost: 300),
  ];

  return TripPlan(
    id: 'test_trip',
    title: 'Test Trip',
    destinationName: 'Test City',
    destinationLat: 11.25,
    destinationLng: 75.78,
    totalBudget: 5000.0,
    days: [DayPlan(dayNumber: 1, date: DateTime(2026, 9, 1), title: 'Day 1', stops: stops)],
  );
}

void main() {
  group('StopItem / DayPlan skip semantics', () {
    test('totalPlannedCost excludes skipped stops', () {
      final place = _place('p1', 'Place', 11.25, 75.78, cost: 100);
      final stops = [
        StopItem(id: '1', place: place, startTime: '9:00 AM', endTime: '9:30 AM', estimatedDurationMinutes: 30, estimatedCost: 100),
        StopItem(id: '2', place: place, startTime: '10:00 AM', endTime: '10:30 AM', estimatedDurationMinutes: 30, estimatedCost: 200, isSkipped: true),
      ];
      final day = DayPlan(dayNumber: 1, date: DateTime(2026, 9, 1), title: 'Day 1', stops: stops);

      expect(day.totalPlannedCost, 100.0);
    });

    test('copyWith supports swapping place, isSkipped and pinnedStartTime', () {
      final placeA = _place('pa', 'Alpha', 11.25, 75.78);
      final placeB = _place('pb', 'Beta', 11.26, 75.79);
      final stop = StopItem(id: '1', place: placeA, startTime: '9:00 AM', endTime: '9:30 AM', estimatedDurationMinutes: 30);

      final swapped = stop.copyWith(place: placeB, isSkipped: true, pinnedStartTime: '5:00 PM');

      expect(swapped.place.id, 'pb');
      expect(swapped.isSkipped, isTrue);
      expect(swapped.pinnedStartTime, '5:00 PM');
      // Original untouched
      expect(stop.place.id, 'pa');
      expect(stop.isSkipped, isFalse);
    });
  });

  group('TripPlanningService itinerary edit methods', () {
    late TripPlanningService service;

    setUp(() {
      service = TripPlanningService.instance;
      service.setActiveTrip(_buildTestTrip());
    });

    test('updateStopStartTime pins the time and persists across a later reorder', () {
      service.updateStopStartTime(0, 'c', '2:00 PM');
      var stop = service.activeTrip!.days[0].stops.firstWhere((s) => s.id == 'c');
      expect(stop.pinnedStartTime, '2:00 PM');
      expect(stop.startTime, '2:00 PM');

      // Reorder stops — the pin must survive recomputation.
      service.reorderStops(0, 2, 0);
      stop = service.activeTrip!.days[0].stops.firstWhere((s) => s.id == 'c');
      expect(stop.startTime, '2:00 PM');
    });

    test('replaceStopPlace swaps the place and updates cost/duration', () {
      final newPlace = _place('new', 'New Place', 11.30, 75.85, dwellMinutes: 90, cost: 999);
      service.replaceStopPlace(0, 'b', newPlace);

      final stop = service.activeTrip!.days[0].stops.firstWhere((s) => s.id == 'b');
      expect(stop.place.id, 'new');
      expect(stop.estimatedDurationMinutes, 90);
      expect(stop.estimatedCost, 999);
    });

    test('insertStopAt inserts at the requested position, not just the end', () {
      final newPlace = _place('mid', 'Middle Place', 11.255, 75.785);
      service.insertStopAt(0, 1, newPlace);

      final stops = service.activeTrip!.days[0].stops;
      expect(stops.length, 4);
      expect(stops[0].id, 'a');
      expect(stops[1].place.id, 'mid');
      expect(stops[2].id, 'b');
      expect(stops[3].id, 'c');
    });

    test('toggleSkipStop flips isSkipped and excludes the stop from planned cost', () {
      final before = service.activeTrip!.days[0].totalPlannedCost;
      service.toggleSkipStop(0, 'b'); // Beta costs 200
      final after = service.activeTrip!.days[0].totalPlannedCost;

      expect(after, before - 200);
      expect(service.activeTrip!.days[0].stops.firstWhere((s) => s.id == 'b').isSkipped, isTrue);

      service.toggleSkipStop(0, 'b');
      expect(service.activeTrip!.days[0].totalPlannedCost, before);
    });
  });

  group('ItineraryConflictService', () {
    final conflictService = ItineraryConflictService();
    final routeService = RouteOptimizationService();

    test('no conflicts when no stop has a pinned time', () {
      final trip = _buildTestTrip();
      final conflicts = conflictService.detectConflicts(trip.days[0]);
      expect(conflicts, isEmpty);
    });

    test('flags a pinned stop that is earlier than the implied arrival time', () {
      final placeA = _place('pa', 'Alpha', 11.25, 75.78);
      final placeB = _place('pb', 'Beta', 12.50, 77.00); // far away -> long travel time

      var stops = [
        StopItem(id: 'a', place: placeA, startTime: '9:00 AM', endTime: '9:30 AM', estimatedDurationMinutes: 30),
        StopItem(id: 'b', place: placeB, startTime: '9:35 AM', endTime: '10:05 AM', estimatedDurationMinutes: 30, pinnedStartTime: '9:35 AM'),
      ];
      stops = routeService.calculateRouteMetrics(stops);
      final day = DayPlan(dayNumber: 1, date: DateTime(2026, 9, 1), title: 'Day 1', stops: stops);

      final conflicts = conflictService.detectConflicts(day);
      expect(conflicts, isNotEmpty);
      expect(conflicts.first.stopId, 'b');
      expect(conflicts.first.severity, ItineraryConflictSeverity.warning);
    });

    test('skipped stops are excluded from conflict checks', () {
      final placeA = _place('pa', 'Alpha', 11.25, 75.78);
      final placeB = _place('pb', 'Beta', 12.50, 77.00);

      var stops = [
        StopItem(id: 'a', place: placeA, startTime: '9:00 AM', endTime: '9:30 AM', estimatedDurationMinutes: 30),
        StopItem(
          id: 'b',
          place: placeB,
          startTime: '9:35 AM',
          endTime: '10:05 AM',
          estimatedDurationMinutes: 30,
          pinnedStartTime: '9:35 AM',
          isSkipped: true,
        ),
      ];
      stops = routeService.calculateRouteMetrics(stops);
      final day = DayPlan(dayNumber: 1, date: DateTime(2026, 9, 1), title: 'Day 1', stops: stops);

      expect(conflictService.detectConflicts(day), isEmpty);
    });
  });

  group('TravelInsightsService.computeCityPulse', () {
    final insightsService = TravelInsightsService();

    test('returns null when fewer than 3 places are supplied', () {
      final places = [
        _place('p1', 'Alpha', 11.25, 75.78),
        _place('p2', 'Beta', 11.26, 75.79),
      ];
      expect(insightsService.computeCityPulse(places), isNull);
    });

    test('returns null when no place has any recorded visits', () {
      final places = [
        _place('p1', 'Alpha', 11.25, 75.78),
        _place('p2', 'Beta', 11.26, 75.79),
        _place('p3', 'Gamma', 11.27, 75.80),
      ];
      expect(insightsService.computeCityPulse(places), isNull);
    });

    test('picks the busiest category and trending place from visit counts', () {
      final places = [
        Place(id: 'cafe1', name: 'Roastery', latitude: 11.25, longitude: 75.78, category: PlaceCategory.cafe, visitCount: 50, rating: 4.5),
        Place(id: 'cafe2', name: 'Bakery', latitude: 11.26, longitude: 75.79, category: PlaceCategory.cafe, visitCount: 80, rating: 4.7),
        Place(id: 'museum1', name: 'Art Museum', latitude: 11.27, longitude: 75.80, category: PlaceCategory.museum, visitCount: 20, rating: 4.2),
      ];

      final summary = insightsService.computeCityPulse(places);

      expect(summary, isNotNull);
      expect(summary!.busiestCategoryLabel, PlaceCategory.cafe.displayName); // 50+80=130 > 20
      expect(summary.trendingPlaceName, 'Bakery'); // highest single visitCount
      expect(summary.sampleSize, 3);
    });
  });
}
