class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Anthropic key lives ONLY in Supabase Edge Function env secrets — never here.

  static const int freeTierAnalysisLimit = 3;
}
