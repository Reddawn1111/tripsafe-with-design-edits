import 'place_category.dart';

/// Generic model representing a nearby Point of Interest / Place.
/// Supports multi-category discovery, aggregate visit intelligence, and route planning.
class Place {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final PlaceCategory category;
  final double rating;
  final int reviewCount;
  final String? priceLevel; // e.g. FREE, INEXPENSIVE, MODERATE, EXPENSIVE
  final List<String> types;
  final String? photoUrl;
  final String? photoReference;
  final Map<String, dynamic>? metadata;

  // Visit & Mobility Intelligence (consent-based aggregated signals)
  final int visitCount;
  final int typicalDwellMinutes;
  final String? busyHours;
  final String? quietHours;
  final String? bestVisitWindow;
  final double estimatedCost; // In INR (₹)
  final double dataConfidence; // 0.0 to 1.0
  final String dataSource; // 'Geoapify Provider', 'TripSafe Aggregate', 'DEMO DATA'
  final String safetyStatus; // 'Safe', 'Advisory', 'Caution'

  // Dynamic ranking variables calculated by RecommendationService
  double distanceKm;
  double recommendationScore;
  String recommendationReason;

  Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address = '',
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.priceLevel,
    this.types = const [],
    this.photoUrl,
    this.photoReference,
    this.metadata,
    this.visitCount = 0,
    this.typicalDwellMinutes = 45,
    this.busyHours,
    this.quietHours,
    this.bestVisitWindow,
    this.estimatedCost = 0.0,
    this.dataConfidence = 0.85,
    this.dataSource = 'Geoapify Provider',
    this.safetyStatus = 'Safe',
    this.distanceKm = 0.0,
    this.recommendationScore = 0.0,
    this.recommendationReason = '',
  });

  bool get hasRating => rating > 0;
  bool get hasReviews => reviewCount > 0;
  bool get hasTripSafeVisits => visitCount > 0;

  String get ratingLabel =>
      hasRating ? rating.toStringAsFixed(1) : 'Unavailable';

  String get reviewCountLabel {
    if (!hasReviews) return 'Reviews unavailable';
    return '$reviewCount reviews';
  }

  /// Price display string (e.g. Free, ₹, ₹₹, ₹₹₹)
  String get priceDisplay {
    if (priceLevel == null || priceLevel!.isEmpty) {
      if (estimatedCost > 0) return '₹${estimatedCost.round()}';
      return '';
    }
    if (priceLevel!.contains('FREE')) return 'Free';
    if (priceLevel!.contains('INEXPENSIVE') || priceLevel == '1') return '₹';
    if (priceLevel!.contains('MODERATE') || priceLevel == '2') return '₹₹';
    if (priceLevel!.contains('EXPENSIVE') || priceLevel == '3') return '₹₹₹';
    if (priceLevel!.contains('VERY_EXPENSIVE') || priceLevel == '4') return '₹₹₹₹';
    return priceLevel!;
  }

  /// Label for visit intelligence
  String get visitPopularityLabel {
    if (visitCount >= 20) {
      return '🔥 Popular with TripSafe travellers ($visitCount visits)';
    } else if (visitCount > 0) {
      return '📈 Growing visitor interest ($visitCount visits)';
    }
    return 'Not enough traveller data yet';
  }

  /// Create a Place instance from a Geoapify Places API GeoJSON feature.
  factory Place.fromGeoapifyFeature(Map<String, dynamic> feature) {
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};

    final categories = (properties['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final longitude = (properties['lon'] as num?)?.toDouble() ??
        (coordinates.isNotEmpty ? (coordinates[0] as num).toDouble() : 0.0);
    final latitude = (properties['lat'] as num?)?.toDouble() ??
        (coordinates.length > 1 ? (coordinates[1] as num).toDouble() : 0.0);

    final address = properties['formatted']?.toString() ??
        properties['address_line1']?.toString() ??
        'Address unavailable';

    final name = properties['name']?.toString();
    final displayName = (name != null && name.isNotEmpty) ? name : address;

    String? priceLevel;
    double defaultEstimatedCost = 0.0;
    final cat = PlaceCategory.primaryFromGeoapifyCategories(categories);

    if (categories.any((c) => c.contains('no_fee'))) {
      priceLevel = 'FREE';
      defaultEstimatedCost = 0.0;
    } else {
      switch (cat) {
        case PlaceCategory.food:
          priceLevel = 'MODERATE';
          defaultEstimatedCost = 400.0;
          break;
        case PlaceCategory.cafe:
          priceLevel = 'INEXPENSIVE';
          defaultEstimatedCost = 200.0;
          break;
        case PlaceCategory.attraction:
        case PlaceCategory.museum:
          priceLevel = 'INEXPENSIVE';
          defaultEstimatedCost = 150.0;
          break;
        case PlaceCategory.entertainment:
        case PlaceCategory.activity:
          priceLevel = 'MODERATE';
          defaultEstimatedCost = 500.0;
          break;
        case PlaceCategory.shopping:
          priceLevel = 'MODERATE';
          defaultEstimatedCost = 600.0;
          break;
        case PlaceCategory.hotel:
          priceLevel = 'EXPENSIVE';
          defaultEstimatedCost = 2500.0;
          break;
        default:
          priceLevel = 'FREE';
          defaultEstimatedCost = 0.0;
      }
    }

    // Default heuristic dwell time based on category
    int defaultDwell = 45;
    switch (cat) {
      case PlaceCategory.beach:
      case PlaceCategory.park:
      case PlaceCategory.nature:
        defaultDwell = 60;
        break;
      case PlaceCategory.museum:
      case PlaceCategory.attraction:
        defaultDwell = 90;
        break;
      case PlaceCategory.food:
        defaultDwell = 50;
        break;
      case PlaceCategory.cafe:
        defaultDwell = 35;
        break;
      case PlaceCategory.viewpoint:
      case PlaceCategory.photography:
        defaultDwell = 30;
        break;
      case PlaceCategory.shopping:
        defaultDwell = 75;
        break;
      default:
        defaultDwell = 45;
    }

    return Place(
      id: properties['place_id']?.toString() ?? '',
      name: displayName,
      latitude: latitude,
      longitude: longitude,
      address: address,
      category: cat,
      rating: 0.0,
      reviewCount: 0,
      priceLevel: priceLevel,
      types: categories,
      photoUrl: null,
      photoReference: null,
      typicalDwellMinutes: defaultDwell,
      estimatedCost: defaultEstimatedCost,
      dataSource: 'Geoapify Provider',
      busyHours: cat == PlaceCategory.food ? '7:30 PM – 10:00 PM' : '4:00 PM – 7:00 PM',
      quietHours: '10:00 AM – 1:00 PM',
      bestVisitWindow: (cat == PlaceCategory.viewpoint || cat == PlaceCategory.beach)
          ? '5:00 PM – 6:30 PM (Sunset)'
          : '11:00 AM – 3:00 PM',
    );
  }

  /// Copy with updated scores and visit intelligence
  Place copyWith({
    double? distanceKm,
    double? recommendationScore,
    String? recommendationReason,
    int? visitCount,
    int? typicalDwellMinutes,
    String? busyHours,
    String? quietHours,
    String? bestVisitWindow,
    double? estimatedCost,
    double? dataConfidence,
    String? dataSource,
    String? safetyStatus,
  }) {
    return Place(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
      priceLevel: priceLevel,
      types: types,
      photoUrl: photoUrl,
      photoReference: photoReference,
      metadata: metadata,
      visitCount: visitCount ?? this.visitCount,
      typicalDwellMinutes: typicalDwellMinutes ?? this.typicalDwellMinutes,
      busyHours: busyHours ?? this.busyHours,
      quietHours: quietHours ?? this.quietHours,
      bestVisitWindow: bestVisitWindow ?? this.bestVisitWindow,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      dataConfidence: dataConfidence ?? this.dataConfidence,
      dataSource: dataSource ?? this.dataSource,
      safetyStatus: safetyStatus ?? this.safetyStatus,
      distanceKm: distanceKm ?? this.distanceKm,
      recommendationScore: recommendationScore ?? this.recommendationScore,
      recommendationReason: recommendationReason ?? this.recommendationReason,
    );
  }
}
