import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/place_category.dart';
import 'places_config.dart';

/// Custom Exception thrown when Places API is not configured or fails.
class PlacesApiException implements Exception {
  final String code;
  final String message;

  PlacesApiException(this.code, this.message);

  @override
  String toString() => message;
}

/// Abstract service interface for nearby place discovery.
abstract class NearbyDiscoveryService {
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusMeters = PlacesConfig.defaultRadiusMeters,
    List<String>? includedTypes,
  });
}

/// Production Geoapify Places API provider.
/// Strictly enforces: NO SILENT FALLBACK TO MOCK DATA.
class GeoapifyPlacesNearbyService implements NearbyDiscoveryService {
  final String apiKey;
  final http.Client _client;

  GeoapifyPlacesNearbyService({
    String? apiKey,
    http.Client? client,
  })  : apiKey = apiKey ?? PlacesConfig.geoapifyApiKey,
        _client = client ?? http.Client();

  @override
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusMeters = PlacesConfig.defaultRadiusMeters,
    List<String>? includedTypes,
  }) async {
    final activeKey = apiKey;

    if (activeKey.isEmpty ||
        activeKey == 'YOUR_API_KEY' ||
        activeKey == 'YOUR_GEOAPIFY_API_KEY' ||
        activeKey == 'YOUR_API_KEY_HERE') {
      throw PlacesApiException(
        'API_NOT_CONFIGURED',
        'Geoapify API key is not configured. Please set GEOAPIFY_API_KEY to fetch live places around your location.',
      );
    }

    final categories = _resolveCategories(includedTypes);
    final radius = radiusMeters.round();
    final filter = 'circle:$longitude,$latitude,$radius';
    final bias = 'proximity:$longitude,$latitude';

    final uri = Uri.https(
      'api.geoapify.com',
      '/v2/places',
      {
        'categories': categories,
        'filter': filter,
        'bias': bias,
        'limit': PlacesConfig.maxResultCount.toString(),
        'lang': 'en',
        'apiKey': activeKey,
      },
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw PlacesApiException(
        'AUTH_ERROR',
        'Geoapify authentication failed: Invalid or restricted API Key (${response.statusCode}).',
      );
    }

    if (response.statusCode != 200) {
      throw PlacesApiException(
        'API_ERROR',
        'Geoapify Places API returned error status ${response.statusCode}.\n${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>? ?? [];

    final seenIds = <String>{};
    final places = <Place>[];

    for (final feature in features) {
      if (feature is! Map<String, dynamic>) continue;

      final place = Place.fromGeoapifyFeature(feature);
      if (place.id.isEmpty || seenIds.contains(place.id)) continue;
      if (_isExcludedCategory(place.types)) continue;

      seenIds.add(place.id);
      places.add(place);
    }

    return places;
  }

  String _resolveCategories(List<String>? includedTypes) {
    if (includedTypes == null || includedTypes.isEmpty) {
      return PlacesConfig.geoapifyTravelCategories;
    }

    final mapped = <String>{};
    for (final type in includedTypes) {
      mapped.addAll(_mapGenericTypeToGeoapify(type));
    }

    return mapped.isEmpty
        ? PlacesConfig.geoapifyTravelCategories
        : mapped.join(',');
  }

  List<String> _mapGenericTypeToGeoapify(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
      case 'food':
        return ['catering.restaurant', 'catering.fast_food'];
      case 'cafe':
        return ['catering.cafe', 'catering.bakery'];
      case 'beach':
        return ['natural.beach'];
      case 'park':
      case 'nature':
        return ['leisure.park', 'natural.forest', 'natural.waterfall'];
      case 'museum':
        return ['entertainment.museum', 'entertainment.culture'];
      case 'tourist_attraction':
      case 'attraction':
        return ['tourism.attraction', 'tourism.sights', 'heritage'];
      case 'viewpoint':
        return ['tourism.viewpoint', 'natural.peak'];
      case 'shopping':
      case 'shopping_mall':
        return ['commercial.shopping_mall', 'commercial.marketplace'];
      case 'entertainment':
        return ['entertainment.cinema', 'entertainment.theme_park'];
      case 'activity':
        return ['sport.fitness_centre', 'leisure.sports_centre', 'leisure.playground'];
      case 'hotel':
      case 'stays':
        return ['accommodation.hotel', 'accommodation.hostel'];
      default:
        return [type];
    }
  }

  bool _isExcludedCategory(List<String> categories) {
    return categories.any(
      (category) => PlacesConfig.excludedCategoryPrefixes.any(
        (prefix) => category.toLowerCase().startsWith(prefix),
      ),
    );
  }
}

/// Explicit Demo Mode Provider.
/// ONLY executed when the user explicitly enables Demo Mode in the UI.
/// Dynamically generates sample places offset relative to the user's ACTUAL GPS coordinates.
class MockNearbyDiscoveryService implements NearbyDiscoveryService {
  @override
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusMeters = PlacesConfig.defaultRadiusMeters,
    List<String>? includedTypes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final places = [
      Place(
        id: 'demo_1',
        name: 'Central Botanical Gardens & Arboretum',
        latitude: latitude + 0.008,
        longitude: longitude + 0.006,
        address: 'Park Avenue, Green Corridor',
        category: PlaceCategory.park,
        rating: 4.8,
        reviewCount: 2450,
        priceLevel: 'FREE',
        types: ['park', 'tourist_attraction', 'scenic'],
        photoUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        visitCount: 320,
        typicalDwellMinutes: 55,
        busyHours: '4:00 PM – 7:00 PM',
        quietHours: '7:00 AM – 11:00 AM',
        bestVisitWindow: '4:30 PM – 6:30 PM (Cool breeze & shade)',
        estimatedCost: 30.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_2',
        name: 'Sunset Lookout & Sea Cliff Promenade',
        latitude: latitude + 0.004,
        longitude: longitude - 0.005,
        address: 'Hillside Drive, Sunset Point',
        category: PlaceCategory.viewpoint,
        rating: 4.9,
        reviewCount: 1820,
        priceLevel: 'FREE',
        types: ['viewpoint', 'scenic', 'photography'],
        photoUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
        visitCount: 450,
        typicalDwellMinutes: 45,
        busyHours: '5:30 PM – 7:30 PM',
        quietHours: '11:00 AM – 3:00 PM',
        bestVisitWindow: '5:00 PM – 6:30 PM (Golden Hour Sunset)',
        estimatedCost: 0.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_3',
        name: 'Artisan Heritage Roastery & Bakery',
        latitude: latitude - 0.003,
        longitude: longitude + 0.004,
        address: '14 Market Street, Heritage Quarter',
        category: PlaceCategory.cafe,
        rating: 4.7,
        reviewCount: 1290,
        priceLevel: 'MODERATE',
        types: ['cafe', 'food', 'bakery'],
        photoUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
        visitCount: 180,
        typicalDwellMinutes: 38,
        busyHours: '8:30 AM – 11:00 AM',
        quietHours: '2:00 PM – 4:30 PM',
        bestVisitWindow: '9:00 AM – 11:00 AM (Fresh bakes & coffee)',
        estimatedCost: 280.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_4',
        name: 'Regional Art & Maritime Heritage Museum',
        latitude: latitude - 0.007,
        longitude: longitude - 0.003,
        address: '88 Station Road, Cultural District',
        category: PlaceCategory.museum,
        rating: 4.6,
        reviewCount: 840,
        priceLevel: 'INEXPENSIVE',
        types: ['museum', 'tourist_attraction', 'cultural'],
        photoUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=800',
        visitCount: 95,
        typicalDwellMinutes: 80,
        busyHours: '11:30 AM – 3:00 PM',
        quietHours: '3:30 PM – 5:30 PM',
        bestVisitWindow: '10:00 AM – 12:30 PM (Guided tours available)',
        estimatedCost: 100.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_5',
        name: 'Pine Ridge Nature Trail & Stream',
        latitude: latitude + 0.012,
        longitude: longitude - 0.008,
        address: 'Green Valley Reserve Entrance',
        category: PlaceCategory.nature,
        rating: 4.7,
        reviewCount: 950,
        priceLevel: 'FREE',
        types: ['nature', 'park', 'hiking'],
        photoUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800',
        visitCount: 140,
        typicalDwellMinutes: 70,
        busyHours: '6:30 AM – 9:00 AM',
        quietHours: '12:00 PM – 3:00 PM',
        bestVisitWindow: '7:00 AM – 9:30 AM (Bird watching & quiet trail)',
        estimatedCost: 0.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_6',
        name: 'Spice Route Bistro & Claypot Kitchen',
        latitude: latitude - 0.005,
        longitude: longitude + 0.008,
        address: '22 Riverfront Boulevard',
        category: PlaceCategory.food,
        rating: 4.6,
        reviewCount: 1650,
        priceLevel: 'MODERATE',
        types: ['restaurant', 'food'],
        photoUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        visitCount: 290,
        typicalDwellMinutes: 50,
        busyHours: '7:30 PM – 10:00 PM',
        quietHours: '1:00 PM – 2:30 PM',
        bestVisitWindow: '7:30 PM – 9:00 PM (Dinner & riverfront seating)',
        estimatedCost: 450.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_7',
        name: 'Old Town Crafts Market & Bazaar',
        latitude: latitude + 0.002,
        longitude: longitude - 0.006,
        address: 'Clocktower Square, Bazaar St',
        category: PlaceCategory.shopping,
        rating: 4.5,
        reviewCount: 3100,
        priceLevel: 'MODERATE',
        types: ['shopping', 'market', 'store'],
        photoUrl: 'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=800',
        visitCount: 520,
        typicalDwellMinutes: 65,
        busyHours: '5:00 PM – 8:30 PM',
        quietHours: '11:00 AM – 3:00 PM',
        bestVisitWindow: '4:30 PM – 7:00 PM (Evening street lighting & artisan stalls)',
        estimatedCost: 350.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
      Place(
        id: 'demo_8',
        name: 'Ocean Watersports & Kayaking Bay',
        latitude: latitude + 0.009,
        longitude: longitude + 0.011,
        address: 'North Beach Cove',
        category: PlaceCategory.activity,
        rating: 4.8,
        reviewCount: 760,
        priceLevel: 'MODERATE',
        types: ['activity', 'sports', 'beach'],
        photoUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
        visitCount: 160,
        typicalDwellMinutes: 90,
        busyHours: '9:00 AM – 12:00 PM',
        quietHours: '1:00 PM – 3:00 PM',
        bestVisitWindow: '8:30 AM – 11:30 AM (Calm water tides)',
        estimatedCost: 600.0,
        dataSource: 'DEMO DATA — simulated consenting travellers',
      ),
    ];

    return places;
  }
}
