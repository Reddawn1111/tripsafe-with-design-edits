import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class RestaurantService {
  final String apiKey;

  RestaurantService(this.apiKey);

  Future<List<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:searchNearby',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,

        // Ask only for the fields we actually need.
        'X-Goog-FieldMask':
            'places.id,'
            'places.displayName,'
            'places.location,'
            'places.formattedAddress,'
            'places.rating,'
            'places.userRatingCount,'
            'places.priceLevel,'
            'places.photos',
      },
      body: jsonEncode({
        'includedTypes': ['restaurant'],
        'maxResultCount': 20,
        'rankPreference': 'POPULARITY',
        'locationRestriction': {
          'circle': {
            'center': {
              'latitude': latitude,
              'longitude': longitude,
            },
            'radius': radiusMeters,
          },
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Restaurant API failed: ${response.statusCode}\n${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final places = data['places'] as List<dynamic>? ?? [];

    return places.map((place) {
      final location = place['location'];

      return Restaurant(
        id: place['id'] ?? '',
        name: place['displayName']?['text'] ?? 'Unknown Restaurant',
        latitude: (location['latitude'] as num).toDouble(),
        longitude: (location['longitude'] as num).toDouble(),
        address: place['formattedAddress'] ?? '',
        rating: (place['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (place['userRatingCount'] as num?)?.toInt() ?? 0,
        priceLevel: place['priceLevel']?.toString(),
      );
    }).toList();
  }
}