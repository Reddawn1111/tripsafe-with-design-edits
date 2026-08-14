class AppConfig {
  AppConfig._();

  static const String geoapifyApiKey = String.fromEnvironment(
    '2e8d8eaf77084419b7bef47119acd27b',
    defaultValue: '',
  );

  static const String locationIqApiKey = String.fromEnvironment(
    'pk.33e21dba133230a48e766d76ebb6bf21',
    defaultValue: '',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String aiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );
}