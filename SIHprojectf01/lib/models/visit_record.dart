import 'place_category.dart';

/// Consented individual visit event (processed locally on device, then anonymized)
class ConsentedVisit {
  final String id;
  final String placeId;
  final String placeName;
  final PlaceCategory category;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final int durationMinutes;
  final double accuracyMeters;
  final bool isDwellVerified; // True if dwell >= 15 min inside POI radius

  ConsentedVisit({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.category,
    required this.arrivalTime,
    required this.departureTime,
    required this.durationMinutes,
    required this.accuracyMeters,
    required this.isDwellVerified,
  });

  Map<String, dynamic> toAnonymizedAggregationPayload() => {
    'placeId': placeId,
    'category': category.name,
    'hourOfDay': arrivalTime.hour,
    'dayOfWeek': arrivalTime.weekday,
    'dwellMinutes': durationMinutes,
    // Note: Absolutely NO user identifiers or coordinates are transmitted
  };
}

/// Anonymized aggregated mobility stats for a place
class AggregateVisitStats {
  final String placeId;
  final String placeName;
  final int totalVisits;
  final int averageDwellMinutes;
  final String busiestTimeWindow; // e.g. "5:00 PM – 8:00 PM"
  final String quietestTimeWindow; // e.g. "10:00 AM – 1:00 PM"
  final String bestVisitWindow; // e.g. "5:00 PM – 6:30 PM (Sunset)"
  final String trend; // "Rising (+24% this week)", "Stable", "Peak Season"
  final double crowdDensityFactor; // 0.0 to 1.0
  final bool isDemoData;
  final String confidenceLevel; // "High confidence (300+ observations)", "Moderate"

  AggregateVisitStats({
    required this.placeId,
    required this.placeName,
    required this.totalVisits,
    required this.averageDwellMinutes,
    required this.busiestTimeWindow,
    required this.quietestTimeWindow,
    required this.bestVisitWindow,
    required this.trend,
    this.crowdDensityFactor = 0.5,
    this.isDemoData = false,
    this.confidenceLevel = 'Moderate',
  });

  String get summaryLabel =>
      '🔥 $totalVisits TripSafe visits · Avg stay $averageDwellMinutes min · Busiest $busiestTimeWindow';
}
