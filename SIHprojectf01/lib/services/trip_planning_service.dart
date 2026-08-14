import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/trip_plan.dart';
import 'recommendation_service.dart';
import 'route_optimization_service.dart';

/// Service managing Budget Planning & Itinerary generation (Step 7 & 8)
class TripPlanningService extends ChangeNotifier {
  static final TripPlanningService instance = TripPlanningService._internal();
  factory TripPlanningService() => instance;
  TripPlanningService._internal() {
    _initSampleTrip();
  }

  final RouteOptimizationService _routeOptimizer = RouteOptimizationService();
  final RecommendationService _recommendationService = RecommendationService();

  TripPlan? _activeTrip;
  TripPlan? get activeTrip => _activeTrip;

  void setActiveTrip(TripPlan plan) {
    _activeTrip = plan;
    notifyListeners();
  }

  /// Generates a realistic, budget-conscious multi-day plan from candidate places
  TripPlan generatePlanFromPlaces({
    required TripPreferences preferences,
    required List<Place> availablePlaces,
    required double userLat,
    required double userLon,
  }) {
    final double totalBudget = preferences.totalTripBudget;
    final int daysCount = preferences.durationDays;
    final double perDayBudget = totalBudget / daysCount;

    // Filter & rank available candidate places
    final rankedPlaces = _recommendationService.rankPlaces(
      places: availablePlaces,
      userLatitude: userLat,
      userLongitude: userLon,
      selectedIntent: UserIntent.all,
      searchRadiusKm: 12.0,
    );

    final List<DayPlan> days = [];
    final List<Place> pool = List<Place>.from(rankedPlaces);
    final startDate = DateTime.now().add(const Duration(days: 1));

    for (int d = 1; d <= daysCount; d++) {
      final dayDate = startDate.add(Duration(days: d - 1));
      final List<StopItem> dayStops = [];
      double daySpent = 0.0;
      int dayMinutes = 0;
      final maxDayMinutes = preferences.availableHoursPerDay * 60;

      // Select diverse stops for the day (e.g. Activity/Sight + Lunch/Cafe + Scenic Sunset)
      while (pool.isNotEmpty && dayMinutes < maxDayMinutes && dayStops.length < 5) {
        // Pick best candidate that fits budget
        final candidateIdx = pool.indexWhere((p) => daySpent + p.estimatedCost <= perDayBudget * 1.25);
        final place = candidateIdx != -1 ? pool.removeAt(candidateIdx) : pool.removeAt(0);

        final stop = StopItem(
          id: 'stop_${d}_${dayStops.length + 1}',
          place: place,
          startTime: '10:00 AM',
          endTime: '11:00 AM',
          estimatedDurationMinutes: place.typicalDwellMinutes,
          estimatedCost: place.estimatedCost * preferences.groupSize,
        );

        dayStops.add(stop);
        daySpent += stop.estimatedCost;
        dayMinutes += stop.estimatedDurationMinutes + 20; // 20 min travel allowance
      }

      // Optimize day stop sequence and compute travel times
      final optimizedStops = _routeOptimizer.optimizeSequence(
        dayStops,
        startLat: userLat,
        startLon: userLon,
      );

      String dayTitle = 'Day $d: Highlights & Exploration';
      if (d == 1) {
        dayTitle = 'Day 1: Arrival & Coastal Vibe';
      } else if (d == 2) {
        dayTitle = 'Day 2: Heritage, Trails & Sunset';
      }

      days.add(
        DayPlan(
          dayNumber: d,
          date: dayDate,
          title: dayTitle,
          stops: optimizedStops,
        ),
      );
    }

    final newPlan = TripPlan(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      title: '${preferences.destinationName} Getaway',
      destinationName: preferences.destinationName,
      destinationLat: userLat,
      destinationLng: userLon,
      startDate: startDate,
      endDate: startDate.add(Duration(days: daysCount - 1)),
      totalBudget: totalBudget,
      members: [
        GroupMember(id: 'mem_1', name: 'You (Organizer)', role: 'Organizer', avatarInitials: 'YO'),
        if (preferences.groupSize > 1)
          GroupMember(id: 'mem_2', name: 'Rohan', role: 'Traveller', avatarInitials: 'RO'),
        if (preferences.groupSize > 2)
          GroupMember(id: 'mem_3', name: 'Priya', role: 'Traveller', avatarInitials: 'PR'),
      ],
      days: days,
      status: 'planning',
      inviteCode: 'TRIP-${(1000 + (DateTime.now().millisecond * 7) % 9000)}',
    );

    _activeTrip = newPlan;
    notifyListeners();
    return newPlan;
  }

  /// Reorder stops in a day plan and recalculate route metrics
  void reorderStops(int dayIndex, int oldIndex, int newIndex) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final stops = List<StopItem>.from(day.stops);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);

    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Automatically optimize a day's stops
  void optimizeDayRoute(int dayIndex) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final optimized = _routeOptimizer.optimizeSequence(day.stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: optimized);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Add a Place to the current trip itinerary
  void addPlaceToTrip(Place place, {int dayIndex = 0}) {
    if (_activeTrip == null) {
      // Create a default trip if none exists
      _initSampleTrip();
    }

    if (dayIndex >= _activeTrip!.days.length) dayIndex = 0;

    final day = _activeTrip!.days[dayIndex];
    final stops = List<StopItem>.from(day.stops);

    stops.add(
      StopItem(
        id: 'stop_${DateTime.now().millisecondsSinceEpoch}',
        place: place,
        startTime: '12:00 PM',
        endTime: '1:00 PM',
        estimatedDurationMinutes: place.typicalDwellMinutes,
        estimatedCost: place.estimatedCost,
      ),
    );

    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Remove a stop from the trip
  void removeStop(int dayIndex, String stopId) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final stops = day.stops.where((s) => s.id != stopId).toList();
    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);

    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Pins a stop's start time (e.g. from a time-picker edit) and
  /// recalculates the day's route metrics so the pin persists.
  void updateStopStartTime(int dayIndex, String stopId, String newStartTime) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final stops = day.stops
        .map((s) => s.id == stopId ? s.copyWith(pinnedStartTime: newStartTime) : s)
        .toList();

    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Swaps a stop's place (e.g. "change place") and recalculates metrics.
  void replaceStopPlace(int dayIndex, String stopId, Place newPlace) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final stops = day.stops
        .map(
          (s) => s.id == stopId
              ? s.copyWith(
                  place: newPlace,
                  estimatedDurationMinutes: newPlace.typicalDwellMinutes,
                  estimatedCost: newPlace.estimatedCost,
                )
              : s,
        )
        .toList();

    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Inserts a new stop at an arbitrary position within a day (unlike
  /// [addPlaceToTrip], which always appends).
  void insertStopAt(int dayIndex, int position, Place place) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final stops = List<StopItem>.from(day.stops);
    final insertAt = position.clamp(0, stops.length);

    stops.insert(
      insertAt,
      StopItem(
        id: 'stop_${DateTime.now().millisecondsSinceEpoch}',
        place: place,
        startTime: '12:00 PM',
        endTime: '1:00 PM',
        estimatedDurationMinutes: place.typicalDwellMinutes,
        estimatedCost: place.estimatedCost,
      ),
    );

    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Toggles a stop's skipped state. Skipped stops stay in the plan but are
  /// excluded from [DayPlan.totalPlannedCost] and rendered struck-through.
  void toggleSkipStop(int dayIndex, String stopId) {
    if (_activeTrip == null || dayIndex >= _activeTrip!.days.length) return;

    final day = _activeTrip!.days[dayIndex];
    final stops = day.stops
        .map((s) => s.id == stopId ? s.copyWith(isSkipped: !s.isSkipped) : s)
        .toList();

    final recalculated = _routeOptimizer.calculateRouteMetrics(stops);
    final updatedDays = List<DayPlan>.from(_activeTrip!.days);
    updatedDays[dayIndex] = day.copyWith(stops: recalculated);

    _activeTrip = _activeTrip!.copyWith(days: updatedDays);
    notifyListeners();
  }

  /// Initial sample trip for demo & instant testing
  void _initSampleTrip() {
    final now = DateTime.now();
    final day1Stops = [
      StopItem(
        id: 'sample_stop_1',
        place: Place(
          id: 'demo_1',
          name: 'Central Botanical Gardens',
          latitude: 12.9716,
          longitude: 77.5946,
          address: 'Lalbagh Rd, Mavalli',
          category: PlaceCategory.park,
          rating: 4.8,
          reviewCount: 2450,
          typicalDwellMinutes: 60,
          estimatedCost: 30.0,
          visitCount: 320,
          bestVisitWindow: '8:00 AM – 11:00 AM',
          dataSource: 'DEMO DATA — simulated consenting travellers',
        ),
        startTime: '9:30 AM',
        endTime: '10:30 AM',
        estimatedDurationMinutes: 60,
        distanceFromPreviousKm: 0.0,
        travelTimeFromPreviousMinutes: 0,
        estimatedCost: 90.0,
      ),
      StopItem(
        id: 'sample_stop_2',
        place: Place(
          id: 'demo_3',
          name: 'Artisan Heritage Roastery',
          latitude: 12.9780,
          longitude: 77.6010,
          address: '14 Market Street',
          category: PlaceCategory.cafe,
          rating: 4.7,
          reviewCount: 1290,
          typicalDwellMinutes: 40,
          estimatedCost: 280.0,
          visitCount: 180,
          bestVisitWindow: '9:00 AM – 11:00 AM',
          dataSource: 'DEMO DATA — simulated consenting travellers',
        ),
        startTime: '10:45 AM',
        endTime: '11:25 AM',
        estimatedDurationMinutes: 40,
        distanceFromPreviousKm: 1.8,
        travelTimeFromPreviousMinutes: 15,
        estimatedCost: 840.0,
      ),
      StopItem(
        id: 'sample_stop_3',
        place: Place(
          id: 'demo_2',
          name: 'Sunset Lookout & Promenade',
          latitude: 12.9850,
          longitude: 77.6120,
          address: 'Hillside Drive, Viewpoint',
          category: PlaceCategory.viewpoint,
          rating: 4.9,
          reviewCount: 1820,
          typicalDwellMinutes: 50,
          estimatedCost: 0.0,
          visitCount: 450,
          bestVisitWindow: '5:00 PM – 6:30 PM (Sunset)',
          dataSource: 'DEMO DATA — simulated consenting travellers',
        ),
        startTime: '5:00 PM',
        endTime: '5:50 PM',
        estimatedDurationMinutes: 50,
        distanceFromPreviousKm: 2.4,
        travelTimeFromPreviousMinutes: 18,
        estimatedCost: 0.0,
        optimizationHint: '🌅 Sunset peak window: 5:00–6:30 PM',
      ),
    ];

    _activeTrip = TripPlan(
      id: 'demo_trip_001',
      title: 'City Exploration & Coastal Vibe',
      destinationName: 'Kozhikode & Beach Trail',
      destinationLat: 11.2588,
      destinationLng: 75.7804,
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      totalBudget: 4500.0,
      members: [
        GroupMember(id: 'mem_1', name: 'You (Organizer)', role: 'Organizer', avatarInitials: 'YO'),
        GroupMember(id: 'mem_2', name: 'Aarav', role: 'Traveller', avatarInitials: 'AA'),
        GroupMember(id: 'mem_3', name: 'Ananya', role: 'Traveller', avatarInitials: 'AN'),
      ],
      days: [
        DayPlan(
          dayNumber: 1,
          date: now,
          title: 'Day 1: Gardens, Heritage & Sunset',
          stops: day1Stops,
        ),
      ],
      status: 'planning',
      inviteCode: 'TRIP-5832',
    );
  }
}
