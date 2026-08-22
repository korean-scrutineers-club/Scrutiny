/// Compile-time configuration, supplied via `--dart-define-from-file`.
///
/// Values are empty when the file is absent,
/// which [assertConfigured] turns into an immediate failure
/// rather than an obscure error from the SDK.
abstract final class Environment {
  /// The URL of the Supabase backend.
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The publishable key of the Supabase backend.
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Fails fast when the configuration file was not supplied.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty,
      'Run with --dart-define-from-file=config/dev.json',
    );
  }
}
