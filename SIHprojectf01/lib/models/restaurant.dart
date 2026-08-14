class Restaurant {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final int reviewCount;
  final String? priceLevel;
  final String? photoReference;

  double distanceKm;
  double recommendationScore;

  Restaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.rating,
    required this.reviewCount,
    this.priceLevel,
    this.photoReference,
    this.distanceKm = 0,
    this.recommendationScore = 0,
  });
}