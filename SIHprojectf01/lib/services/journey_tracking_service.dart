import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/visit_record.dart';
import 'travel_insights_service.dart';
import 'trip_planning_service.dart';

/// Service managing Live Journey Tracking, Deviation Detection & Dwell Logging (Steps 10, 11, 12)
class JourneyTrackingService extends ChangeNotifier {
  static final JourneyTrackingService instance = JourneyTrackingService._internal();
  factory JourneyTrackingService() => instance;
  JourneyTrackingService._internal();

  final TravelInsightsService _insightsService = TravelInsightsService();

  bool _isJourneyActive = false;
  bool get isJourneyActive => _isJourneyActive;

  int _currentStopIndex = 0;
  int get currentStopIndex => _currentStopIndex;

  DateTime? _journeyStartTime;
  DateTime? get journeyStartTime => _journeyStartTime;

  final List<Place> _observedStops = [];
  List<Place> get observedStops => List.unmodifiable(_observedStops);

  Place? _pendingSpontaneousStop;
  Place? get pendingSpontaneousStop => _pendingSpontaneousStop;

  Timer? _dwellSimulationTimer;

  /// Start an active journey for the current active trip
  void startJourney() {
    _isJourneyActive = true;
    _currentStopIndex = 0;
    _journeyStartTime = DateTime.now();
    _observedStops.clear();

    final activeTrip = TripPlanningService.instance.activeTrip;
    if (activeTrip != null && activeTrip.days.isNotEmpty && activeTrip.days.first.stops.isNotEmpty) {
      _observedStops.add(activeTrip.days.first.stops.first.place);
    }

    notifyListeners();
  }

  /// Mark current stop as completed and advance to next planned stop
  void completeCurrentStop() {
    final activeTrip = TripPlanningService.instance.activeTrip;
    if (activeTrip == null || activeTrip.days.isEmpty) return;

    final currentStops = activeTrip.days.first.stops;
    if (_currentStopIndex < currentStops.length) {
      final stop = currentStops[_currentStopIndex];
      stop.isVisited = true;

      // Log consented dwell visit
      final visit = ConsentedVisit(
        id: 'vis_${DateTime.now().millisecondsSinceEpoch}',
        placeId: stop.place.id,
        placeName: stop.place.name,
        category: stop.place.category,
        arrivalTime: DateTime.now().subtract(Duration(minutes: stop.estimatedDurationMinutes)),
        departureTime: DateTime.now(),
        durationMinutes: stop.estimatedDurationMinutes,
        accuracyMeters: 10.0,
        isDwellVerified: true,
      );
      _insightsService.recordConsentedVisit(visit);

      _currentStopIndex++;
      if (_currentStopIndex < currentStops.length) {
        _observedStops.add(currentStops[_currentStopIndex].place);
      }
    }

    if (_currentStopIndex >= currentStops.length) {
      _isJourneyActive = false; // Journey complete
    }

    notifyListeners();
  }

  /// Simulate detection of an unplanned stop visit (dwell > 15 min at nearby cafe/store)
  void simulateSpontaneousVisit(Place unplannedPlace) {
    _pendingSpontaneousStop = unplannedPlace;
    notifyListeners();
  }

  /// User confirms adding the spontaneous stop to itinerary
  void confirmSpontaneousStop() {
    if (_pendingSpontaneousStop == null) return;

    final place = _pendingSpontaneousStop!;
    _observedStops.add(place);

    // Record verified dwell visit
    final visit = ConsentedVisit(
      id: 'vis_${DateTime.now().millisecondsSinceEpoch}',
      placeId: place.id,
      placeName: place.name,
      category: place.category,
      arrivalTime: DateTime.now().subtract(const Duration(minutes: 25)),
      departureTime: DateTime.now(),
      durationMinutes: 25,
      accuracyMeters: 8.0,
      isDwellVerified: true,
    );
    _insightsService.recordConsentedVisit(visit);

    // Add to trip planner
    TripPlanningService.instance.addPlaceToTrip(place);

    _pendingSpontaneousStop = null;
    notifyListeners();
  }

  /// User dismisses the detected spontaneous stop
  void dismissSpontaneousStop() {
    _pendingSpontaneousStop = null;
    notifyListeners();
  }

  /// Stop/end the active journey
  void endJourney() {
    _isJourneyActive = false;
    _dwellSimulationTimer?.cancel();
    notifyListeners();
  }

  /// Trigger sample deviation for demo
  void triggerDemoDeviation() {
    final sampleCafe = Place(
      id: 'demo_dev_cafe',
      name: 'Spotted: Coastal Coconut Shack & Refreshment',
      latitude: 11.2610,
      longitude: 75.7820,
      address: 'Beachfront Walkway',
      category: PlaceCategory.cafe,
      rating: 4.8,
      reviewCount: 420,
      typicalDwellMinutes: 25,
      estimatedCost: 120.0,
      dataSource: 'Observed GPS Dwell (22 min)',
    );
    simulateSpontaneousVisit(sampleCafe);
  }
}
