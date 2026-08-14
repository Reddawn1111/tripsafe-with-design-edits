import '../models/place.dart';

/// Item stored inside the user's itinerary.
class ItineraryItem {
  final String id;
  final Place place;
  final DateTime addedAt;
  final String? note;

  ItineraryItem({
    required this.id,
    required this.place,
    required this.addedAt,
    this.note,
  });
}
