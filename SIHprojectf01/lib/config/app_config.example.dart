/// Local secret configuration template.
///
/// Copy this file to `app_config.dart` (same folder) and fill in real
/// values. `app_config.dart` is gitignored and never committed — this
/// example file is the only version tracked in source control.
abstract class AppConfig {
  AppConfig._();

  /// Geoapify Places API key. Used by [PlacesConfig]/nearby discovery.
  static const String geoapifyApiKey = 'YOUR_GEOAPIFY_API_KEY_HERE';

  /// LocationIQ reverse-geocoding API key. Used by LocationService.
  static const String locationIqApiKey = 'YOUR_LOCATIONIQ_API_KEY_HERE';

  /// Legacy — Google Places API key. Unused: the Google Places-based
  /// restaurant discovery pipeline (restaurant_service.dart) was removed
  /// as orphaned/unreferenced code. Kept as a placeholder only in case a
  /// future feature needs it again.
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';

  /// Firebase — not yet connected. See lib/repositories/firebase_travel_repository.dart.
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY_HERE';
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID_HERE';

  /// Supabase — not yet connected. See lib/repositories/supabase_travel_repository.dart.
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  /// Reserved for a future AI/LLM-assisted planning feature. Unused today.
  static const String aiApiKey = 'YOUR_AI_API_KEY_HERE';
}
