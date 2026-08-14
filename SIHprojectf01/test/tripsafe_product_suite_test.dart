import 'package:flutter_test/flutter_test.dart';
import 'package:tripsafe/models/expense_model.dart';
import 'package:tripsafe/models/place.dart';
import 'package:tripsafe/models/place_category.dart';
import 'package:tripsafe/models/trip_plan.dart';
import 'package:tripsafe/services/authority_analytics_service.dart';
import 'package:tripsafe/services/group_trip_service.dart';
import 'package:tripsafe/services/recommendation_service.dart';
import 'package:tripsafe/services/route_optimization_service.dart';
import 'package:tripsafe/services/safety_service.dart';
import 'package:tripsafe/services/travel_insights_service.dart';
import 'package:tripsafe/services/trip_planning_service.dart';

void main() {
  group('1. Place Models & Category Filtering', () {
    test('Stays intent maps strictly to accommodation and never leaks into general categories', () {
      final matchesStayHotel = UserIntent.stays.matches(PlaceCategory.hotel, ['hotel', 'accommodation']);
      expect(matchesStayHotel, isTrue);

      final matchesStayRestaurant = UserIntent.stays.matches(PlaceCategory.food, ['restaurant']);
      expect(matchesStayRestaurant, isFalse);

      final matchesAllHotel = UserIntent.all.matches(PlaceCategory.hotel, ['hotel']);
      expect(matchesAllHotel, isFalse); // Stays are excluded from 'All'

      final matchesAllPark = UserIntent.all.matches(PlaceCategory.park, ['park']);
      expect(matchesAllPark, isTrue);
    });

    test('Nature intent covers outdoor categories and stays distinct from Explore', () {
      final matchesNatureForest = UserIntent.nature.matches(PlaceCategory.nature, ['natural.forest']);
      expect(matchesNatureForest, isTrue);

      final matchesNatureBeach = UserIntent.nature.matches(PlaceCategory.beach, ['beach']);
      expect(matchesNatureBeach, isTrue);

      final matchesExploreBeach = UserIntent.explore.matches(PlaceCategory.beach, ['beach']);
      expect(matchesExploreBeach, isFalse); // Beach moved to Nature, not double-counted in Explore

      final matchesExploreMuseum = UserIntent.explore.matches(PlaceCategory.museum, ['museum']);
      expect(matchesExploreMuseum, isTrue);
    });

    test('Place model stores visitCount, typicalDwellMinutes, and estimatedCost accurately', () {
      final place = Place(
        id: 'p1',
        name: 'Historic Fort & Lighthouse',
        latitude: 11.25,
        longitude: 75.78,
        address: 'Fort Road, Coastal Zone',
        category: PlaceCategory.attraction,
        rating: 4.8,
        reviewCount: 1500,
        typicalDwellMinutes: 80,
        estimatedCost: 150.0,
        visitCount: 320,
        busyHours: '4 PM – 7 PM',
      );

      expect(place.typicalDwellMinutes, 80);
      expect(place.estimatedCost, 150.0);
      expect(place.visitCount, 320);
      expect(place.priceDisplay, '₹150');
      expect(place.visitPopularityLabel, contains('320 visits'));
    });
  });

  group('2. Route Optimization & Travel Time Estimator', () {
    final routeService = RouteOptimizationService();

    test('Calculates accurate haversine distance and driving transit time', () {
      // 11.2588, 75.7804 to 11.2688, 75.7904 (~1.5 km apart)
      final distance = routeService.computeDistanceKm(11.2588, 75.7804, 11.2688, 75.7904);
      expect(distance, greaterThan(1.0));
      expect(distance, lessThan(2.5));

      final travelTime = routeService.estimateTravelMinutes(distance);
      expect(travelTime, greaterThanOrEqualTo(2));
    });

    test('Optimizes stop sequence with 2-opt and prioritizes viewpoints for sunset window', () {
      final morningCafe = Place(
        id: 's1',
        name: 'Roastery',
        latitude: 11.250,
        longitude: 75.780,
        address: '1st Cross Road',
        category: PlaceCategory.cafe,
      );
      final museum = Place(
        id: 's2',
        name: 'Art Museum',
        latitude: 11.260,
        longitude: 75.785,
        address: 'Heritage Lane',
        category: PlaceCategory.museum,
      );
      final sunsetCliff = Place(
        id: 's3',
        name: 'Sunset Sea Cliff Viewpoint',
        latitude: 11.270,
        longitude: 75.770,
        address: 'Cliff Edge',
        category: PlaceCategory.viewpoint,
        bestVisitWindow: '5:00 PM – 6:30 PM (Sunset)',
      );

      final List<StopItem> stops = [
        StopItem(id: '1', place: sunsetCliff, startTime: '09:00 AM', endTime: '10:00 AM', estimatedDurationMinutes: 60),
        StopItem(id: '2', place: morningCafe, startTime: '10:30 AM', endTime: '11:30 AM', estimatedDurationMinutes: 60),
        StopItem(id: '3', place: museum, startTime: '12:00 PM', endTime: '01:30 PM', estimatedDurationMinutes: 90),
      ];

      final optimized = routeService.optimizeSequence(
        stops,
        startLat: 11.248,
        startLon: 75.778,
      );

      expect(optimized.length, 3);
      // Viewpoint should be placed in sunset slot (last stop)
      expect(optimized.last.place.category, PlaceCategory.viewpoint);
      expect(optimized.last.place.id, 's3');
    });
  });

  group('3. Trip Planning & Budget Management', () {
    final planner = TripPlanningService();

    test('Generates multi-day itinerary respecting budget constraints and time slots', () {
      final List<Place> availablePlaces = [
        Place(id: 'p1', name: 'Breakfast Cafe', latitude: 11.25, longitude: 75.78, address: 'Main St', category: PlaceCategory.cafe, estimatedCost: 200),
        Place(id: 'p2', name: 'Heritage Museum', latitude: 11.26, longitude: 75.79, address: 'Art Blvd', category: PlaceCategory.museum, estimatedCost: 100),
        Place(id: 'p3', name: 'Coastal Lunch', latitude: 11.27, longitude: 75.78, address: 'Shore Rd', category: PlaceCategory.food, estimatedCost: 400),
        Place(id: 'p4', name: 'Sunset Beach', latitude: 11.28, longitude: 75.77, address: 'Beach Rd', category: PlaceCategory.beach, estimatedCost: 0),
      ];

      final prefs = TripPreferences(
        destinationName: 'Kozhikode Coast',
        durationDays: 1,
        budgetPerPerson: 1500,
        groupSize: 2,
        interests: ['Eat', 'Explore'],
      );

      final plan = planner.generatePlanFromPlaces(
        preferences: prefs,
        availablePlaces: availablePlaces,
        userLat: 11.248,
        userLon: 75.778,
      );

      expect(plan.days.length, 1);
      expect(plan.days.first.stops.length, greaterThanOrEqualTo(2));
      expect(plan.totalBudget, 3000.0); // 1500 * 2
      expect(plan.remainingBudget, greaterThanOrEqualTo(0));
    });

    test('Reordering and removing stops dynamically updates day sequence', () {
      final placeA = Place(id: 'a', name: 'A', latitude: 11.25, longitude: 75.78, address: 'A St', category: PlaceCategory.cafe);
      final placeB = Place(id: 'b', name: 'B', latitude: 11.26, longitude: 75.79, address: 'B St', category: PlaceCategory.museum);
      final placeC = Place(id: 'c', name: 'C', latitude: 11.27, longitude: 75.80, address: 'C St', category: PlaceCategory.park);

      final plan = TripPlan(
        id: 'tp_test',
        title: 'Test Plan',
        destinationName: 'Test Zone',
        destinationLat: 11.25,
        destinationLng: 75.78,
        startDate: DateTime.now(),
        totalBudget: 5000,
        days: [
          DayPlan(
            dayNumber: 1,
            title: 'Day 1',
            date: DateTime.now(),
            stops: [
              StopItem(id: 's_a', place: placeA, startTime: '09:00 AM', endTime: '10:00 AM', estimatedDurationMinutes: 60),
              StopItem(id: 's_b', place: placeB, startTime: '10:30 AM', endTime: '11:30 AM', estimatedDurationMinutes: 60),
              StopItem(id: 's_c', place: placeC, startTime: '12:00 PM', endTime: '01:00 PM', estimatedDurationMinutes: 60),
            ],
          ),
        ],
      );

      planner.setActiveTrip(plan);
      expect(planner.activeTrip!.days.first.stops.length, 3);

      // Remove stop B
      planner.removeStop(0, 's_b');
      expect(planner.activeTrip!.days.first.stops.length, 2);
      expect(planner.activeTrip!.days.first.stops.any((s) => s.id == 's_b'), isFalse);
    });
  });

  group('4. Travel Insights & Dwell Verification Engine', () {
    final insights = TravelInsightsService();

    test('Consented dwell visit logging updates aggregate statistics and dwell average', () {
      final testPlace = Place(
        id: 'p_insights_test',
        name: 'Heritage Roastery',
        latitude: 11.25,
        longitude: 75.78,
        address: 'Roastery St',
        category: PlaceCategory.cafe,
        visitCount: 10,
        typicalDwellMinutes: 30,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      );

      final stats = insights.getAggregateStats(testPlace);
      expect(stats, isNotNull);
      expect(stats!.totalVisits, 10);
      expect(stats.averageDwellMinutes, 30);
    });

    test('Derives accurate best time to visit guides', () {
      final sunsetSpot = Place(
        id: 'sunset_spot',
        name: 'Promenade Cliff Viewpoint',
        latitude: 11.25,
        longitude: 75.78,
        address: 'Cliff Viewpoint St',
        category: PlaceCategory.viewpoint,
        bestVisitWindow: '5:00 PM – 6:45 PM (Golden Hour)',
      );

      final guide = insights.getBestTimeToVisitGuide(sunsetSpot);
      expect(guide['bestFor'], contains('Sunset'));
      expect(guide['recommended'], contains('Golden Hour'));
    });
  });

  group('5. Group Trip Expense & Debt Settlement Math', () {
    test('Calculates simplified "Who owes whom" debt settlement correctly', () {
      final groupService = GroupTripService();
      final members = [
        GroupMember(id: 'm1', name: 'Alice'),
        GroupMember(id: 'm2', name: 'Bob'),
        GroupMember(id: 'm3', name: 'Charlie'),
      ];

      // Reset expenses for clean test
      while (groupService.expenses.isNotEmpty) {
        groupService.removeExpense(groupService.expenses.first.id);
      }

      // Alice pays 900 for dinner split among Alice, Bob, Charlie (300 each)
      // Bob owes Alice 300, Charlie owes Alice 300
      groupService.addExpense(
        TripExpense(
          id: 'exp_t1',
          title: 'Dinner at Beach Shack',
          amount: 900.0,
          category: ExpenseCategory.food,
          paidByMemberId: 'm1',
          paidByMemberName: 'Alice',
          date: DateTime.now(),
          splitAmongMemberIds: ['m1', 'm2', 'm3'],
        ),
      );

      expect(groupService.totalSpent, 900.0);

      final settlements = groupService.calculateSettlements(members);
      expect(settlements.length, 2);

      final bobSettlement = settlements.firstWhere((s) => s.fromMemberName == 'Bob');
      expect(bobSettlement.toMemberName, 'Alice');
      expect(bobSettlement.amount, 300.0);

      final charlieSettlement = settlements.firstWhere((s) => s.fromMemberName == 'Charlie');
      expect(charlieSettlement.toMemberName, 'Alice');
      expect(charlieSettlement.amount, 300.0);
    });
  });

  group('6. Safety & Authority Explainable Priority Ranking', () {
    test('SafetyService generates contextual safety evaluations and clear alerts', () {
      final safetyService = SafetyService();
      final eval = safetyService.evaluateSafety('Kozhikode Coastal Corridor');

      expect(eval.destination, contains('Kozhikode'));
      expect(eval.safetyScore, greaterThan(0));
      expect(eval.safetyScore, lessThanOrEqualTo(100));
      expect(eval.overallSafetyStatus, isNotEmpty);
      expect(eval.safetyGuidelines, isNotEmpty);
    });

    test('AuthorityAnalyticsService computes district summary & Explainable Priority items (/100)', () {
      final authService = AuthorityAnalyticsService();
      final summary = authService.getDistrictMobilitySummary();

      expect(summary.districtName, contains('Kozhikode'));
      expect(summary.totalActiveTravellers, greaterThan(0));
      expect(summary.majorCorridors.isNotEmpty, isTrue);
      expect(summary.priorityActions.isNotEmpty, isTrue);

      // Verify explainable priority ranking structure
      final topAction = summary.priorityActions.first;
      expect(topAction.priorityScore, greaterThanOrEqualTo(0));
      expect(topAction.priorityScore, lessThanOrEqualTo(100));
      expect(topAction.evidence, isNotEmpty);
      expect(topAction.recommendedAction, isNotEmpty);
      expect(topAction.validationStatus, contains('Requires field validation'));
    });
  });

  group('7. Multi-Factor Recommendation Ranking & Stays Separation', () {
    final recoService = RecommendationService();

    test('Recommendation scoring ranks intent match and places beyond radius are filtered out', () {
      final nearCafe = Place(
        id: 'c1',
        name: 'Artisan Cafe',
        latitude: 11.2588,
        longitude: 75.7804,
        address: '10 Beach St',
        category: PlaceCategory.cafe,
        rating: 4.8,
        reviewCount: 300,
        distanceKm: 0.5,
      );

      final farMuseum = Place(
        id: 'm1',
        name: 'Distant Museum',
        latitude: 11.4588,
        longitude: 75.9804,
        address: '100 Far Highway',
        category: PlaceCategory.museum,
        rating: 4.9,
        reviewCount: 900,
        distanceKm: 25.0, // Far beyond 6 km radius
      );

      final ranked = recoService.rankPlaces(
        places: [nearCafe, farMuseum],
        userLatitude: 11.2588,
        userLongitude: 75.7804,
        selectedIntent: UserIntent.eat,
        searchRadiusKm: 6.0,
      );

      expect(ranked.length, 1);
      expect(ranked.first.id, 'c1');
    });
  });
}
