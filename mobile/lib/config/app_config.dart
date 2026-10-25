/// Mirrors frontend/.env public values for the Split My Bill Supabase project.
class AppConfig {
  static const supabaseUrl = 'https://lsxftyyekiozsnszutne.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxzeGZ0eXlla2lvenNuc3p1dG5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyMTA3NDQsImV4cCI6MjA1OTc4Njc0NH0.hM4QMe4VKzFM-PjKhLFnAGC5jHHP6XDeCWDHeGrC6a0';

  /// The deployed PWA (`NEXT_PUBLIC_DOMAIN`); history share links point here.
  static const webBaseUrl = 'https://split-my-bill.vercel.app';

  /// Same production API the PWA uses for Gemini receipt OCR.
  static const scanApiUrl = '$webBaseUrl/scan';

  /// Deep link used after Google OAuth. Add this exact URL to
  /// Supabase → Authentication → URL Configuration → Redirect URLs.
  static const authRedirectUrl = 'com.splitmybill.app://login-callback/';

  static const authCallbackScheme = 'com.splitmybill.app';
}
