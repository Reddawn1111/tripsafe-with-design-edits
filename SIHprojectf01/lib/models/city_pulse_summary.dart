/// Traveller-facing, city/area-level summary of aggregated TripSafe visit
/// data — the friendly consumer form of the same underlying aggregates
/// behind per-place Travel Pulse. Never reveals individual visitors,
/// coordinates, or timestamps.
class CityPulseSummary {
  final String busiestCategoryLabel;
  final String busiestCategoryEmoji;
  final String trendingPlaceName;
  final String trendingPlaceId;
  final bool isDemoData;
  final int sampleSize;

  const CityPulseSummary({
    required this.busiestCategoryLabel,
    required this.busiestCategoryEmoji,
    required this.trendingPlaceName,
    required this.trendingPlaceId,
    required this.isDemoData,
    required this.sampleSize,
  });
}
