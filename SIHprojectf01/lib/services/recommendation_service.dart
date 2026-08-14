import 'dart:math';
import '../models/place.dart';
import '../models/place_category.dart';

/// Recommendation Engine for TRIPSAFE (Step 4).
/// Scores and ranks nearby places using transparent, multi-factor criteria:
/// - Quality / Rating (25%)
/// - Aggregate TripSafe Visit Activity (20%)
/// - Geodesic Proximity (20%)
/// - User Intent / Vibe Match (20%)
/// - Safety & Budget Alignment (15%)
class RecommendationService {
  static const double weightRating = 0.25;
  static const double weightVisits = 0.20;
  static const double weightDistance = 0.20;
  static const double weightIntent = 0.20;
  static const double weightSafetyBudget = 0.15;

  /// Haversine formula to compute geodesic distance between 2 coordinates in km.
  double computeDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * pi / 180.0;

  /// Ranks places based on user location, intent vibe, max budget, and search radius.
  List<Place> rankPlaces({
    required List<Place> places,
    required double userLatitude,
    required double userLongitude,
    UserIntent selectedIntent = UserIntent.all,
    double searchRadiusKm = 5.0,
    double? maxBudget,
  }) {
    if (places.isEmpty) return [];

    // 1. Distance filter (exclude beyond radius)
    final withinRadius = places.where((place) {
      final distKm = computeDistanceKm(
        userLatitude,
        userLongitude,
        place.latitude,
        place.longitude,
      );
      return distKm <= searchRadiusKm;
    }).toList();

    if (withinRadius.isEmpty) return [];

    // 2. Intent matching filter
    final intentFiltered = selectedIntent == UserIntent.all
        ? withinRadius.where((p) => selectedIntent.matches(p.category, p.types)).toList()
        : withinRadius
            .where((place) => selectedIntent.matches(place.category, place.types))
            .toList();

    if (intentFiltered.isEmpty) return [];

    // Find max review and visit counts for logarithmic scaling
    final maxReviews = intentFiltered.map((p) => p.reviewCount).reduce(max);
    final maxVisits = intentFiltered.map((p) => p.visitCount).reduce(max);

    final rankedList = intentFiltered.map((place) {
      final distKm = computeDistanceKm(
        userLatitude,
        userLongitude,
        place.latitude,
        place.longitude,
      );

      // 1. Rating & Quality Score (0 to 1)
      final double ratingScore = place.hasRating
          ? (place.rating / 5.0).clamp(0.0, 1.0)
          : (place.reviewCount > 0 ? 0.7 : 0.6);

      // 2. Popularity & Aggregate TripSafe Visits Score (0 to 1)
      final double reviewPopularity = maxReviews == 0
          ? 0.0
          : (log(place.reviewCount + 1) / log(maxReviews + 1)).clamp(0.0, 1.0);
      final double visitPopularity = maxVisits == 0
          ? 0.0
          : (log(place.visitCount + 1) / log(maxVisits + 1)).clamp(0.0, 1.0);
      final double activityScore = max(reviewPopularity, visitPopularity);

      // 3. Distance Score (closer is higher)
      final double distanceScore = max(0.0, 1.0 - (distKm / searchRadiusKm));

      // 4. Intent Match Score (exact category fit)
      final bool isMatch = selectedIntent.matches(place.category, place.types);
      final double intentScore = isMatch ? 1.0 : 0.4;

      // 5. Safety & Budget Score (0 to 1)
      double safetyBudgetScore = 0.9;
      if (place.safetyStatus == 'Caution') {
        safetyBudgetScore -= 0.3;
      } else if (place.safetyStatus == 'Advisory') {
        safetyBudgetScore -= 0.15;
      }

      if (maxBudget != null && maxBudget > 0) {
        if (place.estimatedCost <= maxBudget) {
          safetyBudgetScore += 0.1;
        } else {
          safetyBudgetScore -= 0.3;
        }
      }
      safetyBudgetScore = safetyBudgetScore.clamp(0.0, 1.0);

      // Composite Multi-Factor Score
      final totalScore = (ratingScore * weightRating) +
          (activityScore * weightVisits) +
          (distanceScore * weightDistance) +
          (intentScore * weightIntent) +
          (safetyBudgetScore * weightSafetyBudget);

      // Explainable Reason
      final reason = _generateRecommendationReason(
        place: place,
        distKm: distKm,
        isIntentMatch: isMatch,
        intent: selectedIntent,
      );

      return place.copyWith(
        distanceKm: distKm,
        recommendationScore: totalScore.clamp(0.0, 1.0),
        recommendationReason: reason,
      );
    }).toList();

    // Sort descending by recommendation score
    rankedList.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));

    return rankedList;
  }

  /// Generates human-readable, explainable reason for the recommendation
  String _generateRecommendationReason({
    required Place place,
    required double distKm,
    required bool isIntentMatch,
    required UserIntent intent,
  }) {
    if (place.visitCount >= 200) {
      return '🔥 High TripSafe activity (${place.visitCount} recent visits)';
    }

    if (intent == UserIntent.photos &&
        (place.category == PlaceCategory.viewpoint || place.category == PlaceCategory.photography)) {
      return '📸 Great scenic photo spot & sunset view';
    }

    if (intent == UserIntent.eat &&
        (place.category == PlaceCategory.food || place.category == PlaceCategory.cafe)) {
      return '🍴 Highly rated culinary spot nearby';
    }

    if (place.rating >= 4.7 && place.hasRating) {
      return '⭐ Top rated ${place.rating.toStringAsFixed(1)} destination';
    }

    if (distKm <= 0.8) {
      return '📍 Quick walk (${distKm.toStringAsFixed(1)} km from you)';
    }

    if (place.reviewCount > 1000) {
      final formattedCount = (place.reviewCount / 1000).toStringAsFixed(1);
      return '⭐ Well-known favorite (${formattedCount}k reviews)';
    }

    return '${place.category.iconEmoji} Recommended ${place.category.displayName}';
  }
}