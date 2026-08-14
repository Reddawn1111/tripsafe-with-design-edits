import '../models/city_pulse_summary.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/visit_record.dart';

/// Travel Insights Service — Aggregates consented mobility events
/// into traveller recommendations and dwell intelligence (Steps 5, 6, 12, 14).
class TravelInsightsService {
  static final TravelInsightsService instance = TravelInsightsService._internal();
  factory TravelInsightsService() => instance;
  TravelInsightsService._internal();

  // In-memory store of consented, anonymized visits (simulated/local device observations)
  final Map<String, List<ConsentedVisit>> _placeVisits = {};

  /// Minimum observations required before publishing aggregate visit statistics
  static const int minConfidenceThreshold = 5;

  /// Record a consented visit event
  void recordConsentedVisit(ConsentedVisit visit) {
    if (!visit.isDwellVerified) return; // Strict rule: passing nearby != visit
    _placeVisits.putIfAbsent(visit.placeId, () => []).add(visit);
  }

  /// Get aggregated visit intelligence for a place
  AggregateVisitStats? getAggregateStats(Place place) {
    final observations = _placeVisits[place.id] ?? [];

    if (place.dataSource.contains('DEMO DATA')) {
      return AggregateVisitStats(
        placeId: place.id,
        placeName: place.name,
        totalVisits: place.visitCount,
        averageDwellMinutes: place.typicalDwellMinutes,
        busiestTimeWindow: place.busyHours ?? '5:00 PM – 8:00 PM',
        quietestTimeWindow: place.quietHours ?? '11:00 AM – 2:00 PM',
        bestVisitWindow: place.bestVisitWindow ?? '4:30 PM – 6:30 PM',
        trend: '🔥 High demand (+18% recently)',
        isDemoData: true,
        confidenceLevel: 'Simulated Demo Data',
      );
    }

    if (observations.length < minConfidenceThreshold && place.visitCount < minConfidenceThreshold) {
      return null; // Privacy rule: insufficient observations
    }

    final totalVisits = observations.length + place.visitCount;
    final totalDwellSum = observations.fold(0, (sum, v) => sum + v.durationMinutes) +
        (place.typicalDwellMinutes * place.visitCount);
    final avgDwell = (totalDwellSum / totalVisits).round();

    return AggregateVisitStats(
      placeId: place.id,
      placeName: place.name,
      totalVisits: totalVisits,
      averageDwellMinutes: avgDwell,
      busiestTimeWindow: place.busyHours ?? '5:00 PM – 8:00 PM',
      quietestTimeWindow: place.quietHours ?? '10:00 AM – 1:00 PM',
      bestVisitWindow: place.bestVisitWindow ?? 'Morning & Sunset',
      trend: totalVisits > 50 ? '🔥 High traveller activity' : '📈 Growing interest',
      isDemoData: false,
      confidenceLevel: 'High (aggregate observations)',
    );
  }

  /// Traveller-facing "City Pulse" summary — a friendly, city/area-level
  /// view of the same aggregated data behind Travel Pulse, computed over
  /// an already-loaded list of nearby places (no new network calls).
  /// Returns null when there isn't enough data to summarize, mirroring the
  /// "not enough traveller data yet" rule used elsewhere in this service.
  CityPulseSummary? computeCityPulse(List<Place> places) {
    if (places.length < 3) return null;

    final visitsByCategory = <PlaceCategory, int>{};
    for (final place in places) {
      if (place.visitCount <= 0) continue;
      visitsByCategory[place.category] =
          (visitsByCategory[place.category] ?? 0) + place.visitCount;
    }
    if (visitsByCategory.isEmpty) return null;

    final busiestEntry = visitsByCategory.entries
        .reduce((a, b) => a.value >= b.value ? a : b);

    final placesWithVisits = places.where((p) => p.visitCount > 0).toList()
      ..sort((a, b) {
        final byVisits = b.visitCount.compareTo(a.visitCount);
        return byVisits != 0 ? byVisits : b.rating.compareTo(a.rating);
      });
    final trending = placesWithVisits.first;

    return CityPulseSummary(
      busiestCategoryLabel: busiestEntry.key.displayName,
      busiestCategoryEmoji: busiestEntry.key.iconEmoji,
      trendingPlaceName: trending.name,
      trendingPlaceId: trending.id,
      isDemoData: places.any((p) => p.dataSource.contains('DEMO DATA')),
      sampleSize: placesWithVisits.length,
    );
  }

  /// Derive Best Time to Visit guidance for a place
  Map<String, String> getBestTimeToVisitGuide(Place place) {
    String bestFor;
    String bestWindow;
    String busiest;
    String typicalStay = '${place.typicalDwellMinutes} min';

    switch (place.category) {
      case PlaceCategory.viewpoint:
      case PlaceCategory.beach:
        bestFor = '🌅 Sunset & Golden Hour';
        bestWindow = place.bestVisitWindow ?? '5:00 PM – 6:30 PM';
        busiest = place.busyHours ?? '5:30 PM – 7:30 PM';
        break;
      case PlaceCategory.photography:
        bestFor = '📸 Scenic Lighting';
        bestWindow = '4:30 PM – 6:00 PM or 7:00 AM – 8:30 AM';
        busiest = '5:00 PM – 7:00 PM';
        break;
      case PlaceCategory.nature:
      case PlaceCategory.park:
        bestFor = '🌲 Fresh Air & Walking';
        bestWindow = place.bestVisitWindow ?? '7:00 AM – 10:00 AM';
        busiest = place.busyHours ?? '4:00 PM – 7:00 PM';
        break;
      case PlaceCategory.museum:
      case PlaceCategory.attraction:
        bestFor = '🏛️ Culture & Exhibits';
        bestWindow = place.bestVisitWindow ?? '10:30 AM – 1:00 PM';
        busiest = place.busyHours ?? '1:00 PM – 4:00 PM';
        break;
      case PlaceCategory.food:
      case PlaceCategory.cafe:
        bestFor = '🍴 Dining & Refreshment';
        bestWindow = place.bestVisitWindow ?? '12:30 PM – 2:00 PM / 7:30 PM – 9:00 PM';
        busiest = place.busyHours ?? '8:00 PM – 10:00 PM';
        break;
      default:
        bestFor = '📍 Sightseeing';
        bestWindow = place.bestVisitWindow ?? '11:00 AM – 3:00 PM';
        busiest = place.busyHours ?? '4:00 PM – 7:00 PM';
    }

    return {
      'bestFor': bestFor,
      'recommended': bestWindow,
      'busiest': busiest,
      'typicalStay': typicalStay,
      'dataSource': place.dataSource,
    };
  }
}
