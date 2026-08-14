class AppConfig {
  AppConfig._();

  // TODO: Replace these before final/public release.
  static const String geoapifyApiKey =
      '2e8d8eaf77084419b7bef47119acd27b';

  static const String locationIqApiKey =
      'pk.33e21dba133230a48e766d76ebb6bf21';

  static const String supabaseUrl = '';

  static const String supabaseAnonKey = '';

  static bool get geoapifyConfigured =>
      geoapifyApiKey.isNotEmpty &&
      geoapifyApiKey != 'YOUR_GEOAPIFY_KEY_HERE';

  static bool get locationIqConfigured =>
      locationIqApiKey.isNotEmpty &&
      locationIqApiKey != 'YOUR_LOCATIONIQ_KEY_HERE';

  static bool get supabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}