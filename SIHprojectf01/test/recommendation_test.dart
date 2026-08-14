import 'package:flutter_test/flutter_test.dart';
import 'package:tripsafe/models/place.dart';
import 'package:tripsafe/models/place_category.dart';
import 'package:tripsafe/services/nearby_discovery_service.dart';
import 'package:tripsafe/services/recommendation_service.dart';

void main() {
  group('RecommendationService & Places Engine Tests', () {
    final recommendationService = RecommendationService();
    const userLat = 13.0827; // Device GPS e.g. Bengaluru
    const userLon = 80.2707;

    test('GeoapifyPlacesNearbyService throws PlacesApiException when unconfigured', () async {
      final unconfiguredService = GeoapifyPlacesNearbyService(apiKey: '');
      await expectLater(
        unconfiguredService.getNearbyPlaces(
          latitude: userLat,
          longitude: userLon,
        ),
        throwsA(isA<PlacesApiException>()),
      );
    });

    test('High review count 4.7 rating beats low review count 5.0 rating', () {
      final placeA = Place(
        id: 'a',
        name: 'Local Diner A',
        latitude: userLat + 0.005,
        longitude: userLon + 0.005,
        address: 'Street 1',
        category: PlaceCategory.food,
        rating: 5.0,
        reviewCount: 3,
      );

      final placeB = Place(
        id: 'b',
        name: 'Famous Bistro B',
        latitude: userLat + 0.006,
        longitude: userLon + 0.006,
        address: 'Street 2',
        category: PlaceCategory.food,
        rating: 4.7,
        reviewCount: 2000,
      );

      final ranked = recommendationService.rankPlaces(
        places: [placeA, placeB],
        userLatitude: userLat,
        userLongitude: userLon,
      );

      expect(ranked.first.id, equals('b'));
      expect(ranked.first.recommendationScore, greaterThan(ranked.last.recommendationScore));
    });

    test('Intent matching boosts corresponding categories', () {
      final photoSpot = Place(
        id: 'photo',
        name: 'Scenic Cliff Viewpoint',
        latitude: userLat + 0.01,
        longitude: userLon + 0.01,
        address: 'Cliff Rd',
        category: PlaceCategory.viewpoint,
        rating: 4.6,
        reviewCount: 500,
        types: ['scenic', 'viewpoint'],
      );

      final foodSpot = Place(
        id: 'food',
        name: 'City Cafe',
        latitude: userLat + 0.01,
        longitude: userLon + 0.01,
        address: 'Market St',
        category: PlaceCategory.cafe,
        rating: 4.6,
        reviewCount: 500,
        types: ['cafe'],
      );

      final rankedForPhotos = recommendationService.rankPlaces(
        places: [foodSpot, photoSpot],
        userLatitude: userLat,
        userLongitude: userLon,
        selectedIntent: UserIntent.photos,
      );

      expect(rankedForPhotos.first.id, equals('photo'));
      expect(rankedForPhotos.first.recommendationReason, contains('📸'));
    });

    test('Geoapify Place parsing leaves unavailable rating and reviews as zero', () {
      final place = Place.fromGeoapifyFeature({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [80.2707, 13.0827],
        },
        'properties': {
          'name': 'City Park',
          'place_id': 'geoapify_test_1',
          'lat': 13.0827,
          'lon': 80.2707,
          'formatted': 'City Park, Bengaluru',
          'categories': ['leisure.park'],
        },
      });

      expect(place.name, equals('City Park'));
      expect(place.category, equals(PlaceCategory.park));
      expect(place.hasRating, isFalse);
      expect(place.hasReviews, isFalse);
      expect(place.photoUrl, isNull);
    });

    test('Places beyond search radius are excluded', () {
      final nearby = Place(
        id: 'near',
        name: 'Nearby Cafe',
        latitude: userLat + 0.001,
        longitude: userLon + 0.001,
        address: 'Close St',
        category: PlaceCategory.cafe,
        rating: 4.5,
        reviewCount: 100,
      );

      final far = Place(
        id: 'far',
        name: 'Distant Landmark',
        latitude: userLat + 0.2,
        longitude: userLon + 0.2,
        address: 'Far Rd',
        category: PlaceCategory.attraction,
        rating: 5.0,
        reviewCount: 5000,
      );

      final ranked = recommendationService.rankPlaces(
        places: [nearby, far],
        userLatitude: userLat,
        userLongitude: userLon,
        searchRadiusKm: 5.0,
      );

      expect(ranked.length, equals(1));
      expect(ranked.first.id, equals('near'));
    });
  });
}
