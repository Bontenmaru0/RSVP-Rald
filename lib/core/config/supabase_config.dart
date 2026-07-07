class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  factory SupabaseConfig.fromEnvironment() {
    return SupabaseConfig(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }
}