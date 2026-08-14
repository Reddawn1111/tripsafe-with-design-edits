import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Structured result of a reverse-geocode lookup.
class LocationAddress {
  final double latitude;
  final double longitude;
  final String? road;
  final String? landmark; // suburb / neighbourhood / area
  final String? town;
  final String? city;
  final String? state;
  final String? postcode;
  final String fullAddress;

  LocationAddress({
    required this.latitude,
    required this.longitude,
    this.road,
    this.landmark,
    this.town,
    this.city,
    this.state,
    this.postcode,
    required this.fullAddress,
  });

  /// Short bold label for a collapsed header, e.g. "Kogilu" or "Indiranagar".
  String get areaLabel => landmark ?? town ?? city ?? 'Current Location';

  /// One-line truncated subtitle.
  String get shortLine {
    final parts = [road, town, city].where((e) => e != null && e.isNotEmpty);
    if (parts.isEmpty) return fullAddress;
    return parts.join(', ');
  }

  String get cityAndPincode {
    final parts =
        [city, state, postcode].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isEmpty ? '-' : parts.join(', ');
  }
}

class LocationService {
  static const _apiKey = 'pk.33e21dba133230a48e766d76ebb6bf21';

  /// Fetches raw device GPS position using Geolocator.
  Future<Position> getCurrentPosition() async {
    return _determinePosition();
  }

  /// Obtains current GPS position and performs reverse geocoding lookup.
  Future<LocationAddress> getCurrentLocationAddress() async {
    final position = await _determinePosition();
    return getAddressForCoordinates(position.latitude, position.longitude);
  }

  /// Reverse-geocodes known coordinates without requesting GPS again.
  Future<LocationAddress> getAddressForCoordinates(double lat, double lon) async {
    return _reverseGeocode(lat, lon);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are turned off. Please enable GPS/Location and try again.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. Please grant location access to use this app.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it from your device settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw Exception(
        'Timed out while getting your GPS location. Try moving to an open area and retry.',
      );
    }
  }

  Future<LocationAddress> _reverseGeocode(double lat, double lon) async {
    final uri = Uri.parse(
      'https://us1.locationiq.com/v1/reverse'
      '?key=$_apiKey&lat=$lat&lon=$lon&format=json&addressdetails=1',
    );

    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('The address lookup timed out. Check your internet connection.');
    } catch (_) {
      throw Exception('No internet connection. Please check your network and try again.');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Address lookup failed: invalid or missing API key.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Address lookup failed (server returned ${response.statusCode}). Please try again.',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data.containsKey('error')) {
      throw Exception('No address could be found for this location.');
    }

    final address = (data['address'] as Map<String, dynamic>?) ?? {};

    return LocationAddress(
      latitude: lat,
      longitude: lon,
      road: (address['road'] ?? address['pedestrian'] ?? address['footway'])
          ?.toString(),
      landmark: (address['suburb'] ??
              address['neighbourhood'] ??
              address['city_district'])
          ?.toString(),
      town: (address['village'] ?? address['town'])?.toString(),
      city: (address['city'] ?? address['town'])?.toString(),
      state: address['state']?.toString(),
      postcode: address['postcode']?.toString(),
      fullAddress: data['display_name']?.toString() ?? 'Address unavailable',
    );
  }
}
