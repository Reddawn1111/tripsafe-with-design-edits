import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../models/itinerary_item.dart';
import 'trip_planning_service.dart';

/// Service managing user's saved trip itinerary items.
/// Provides a clean interface: `addPlaceToItinerary(Place place)`
/// and integrates directly with `TripPlanningService`.
class ItineraryService extends ChangeNotifier {
  static final ItineraryService instance = ItineraryService._internal();

  factory ItineraryService() => instance;

  ItineraryService._internal();

  final List<ItineraryItem> _items = [];

  List<ItineraryItem> get items => List.unmodifiable(_items);

  bool isPlaceInItinerary(String placeId) {
    // Check local list or active trip stops
    final inLocal = _items.any((item) => item.place.id == placeId);
    final activeTrip = TripPlanningService.instance.activeTrip;
    final inActiveTrip = activeTrip?.days.any((d) => d.stops.any((s) => s.place.id == placeId)) ?? false;
    return inLocal || inActiveTrip;
  }

  /// Minimal clean interface to add a Place to the trip itinerary.
  bool addPlaceToItinerary(Place place, {String? note}) {
    if (isPlaceInItinerary(place.id)) {
      return false; // Already added
    }

    _items.add(
      ItineraryItem(
        id: 'itin_${DateTime.now().millisecondsSinceEpoch}',
        place: place,
        addedAt: DateTime.now(),
        note: note,
      ),
    );

    // Also sync to TripPlanningService active day plan
    TripPlanningService.instance.addPlaceToTrip(place);

    notifyListeners();
    return true;
  }

  /// Remove a place from itinerary
  void removePlaceFromItinerary(String placeId) {
    _items.removeWhere((item) => item.place.id == placeId);
    TripPlanningService.instance.removeStop(0, placeId);
    notifyListeners();
  }

  /// Clear all itinerary items
  void clearItinerary() {
    _items.clear();
    notifyListeners();
  }
}
