class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.publishableKey,
  });

  final String url;
  final String publishableKey;

  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  factory SupabaseConfig.fromEnvironment() {
    return SupabaseConfig(
      url: const String.fromEnvironment('SUPABASE_URL'),
      publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    );
  }
}
