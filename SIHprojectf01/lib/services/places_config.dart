/// Configuration for Geoapify Places API and discovery provider.
abstract class PlacesConfig {
  PlacesConfig._();

  /// Geoapify API Key.
  ///
  /// Hardcoded for the college hackathon prototype.
  /// Replace YOUR_API_KEY_HERE with your actual Geoapify key.
  static const String geoapifyApiKey = '2e8d8eaf77084419b7bef47119acd27b';

  /// Helper getter to verify if the API key is configured.
  static bool get isConfigured =>
      geoapifyApiKey.isNotEmpty &&
      geoapifyApiKey != 'YOUR_API_KEY' &&
      geoapifyApiKey != 'YOUR_GEOAPIFY_API_KEY' &&
      geoapifyApiKey != 'YOUR_API_KEY_HERE';

  /// Default search radius in meters (5 km).
  static const double defaultRadiusMeters = 5000.0;

  /// Max places to fetch per request.
  static const int maxResultCount = 50;

  /// Broad travel-relevant Geoapify categories for general nearby discovery.
  ///
  /// Top-level categories are intentionally used because Geoapify
  /// supports them directly and they include relevant subcategories.
  static const String geoapifyTravelCategories =
      'accommodation,'
      'activity,'
      'commercial,'
      'catering,'
      'entertainment,'
      'leisure,'
      'natural,'
      'tourism,'
      'sport,'
      'parking';

  /// Categories excluded from general travel discovery.
  static const List<String> excludedCategoryPrefixes = [
    'healthcare',
    'education',
    'office',
    'service',
    'public_transport',
    'adult',
    'ski',
  ];
}