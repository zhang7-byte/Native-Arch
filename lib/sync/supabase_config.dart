import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase connection settings. Resolved at launch from, in order of priority:
///   1. build-time `--dart-define`s (SUPABASE_URL / SUPABASE_ANON_KEY), then
///   2. values the user saved in-app (Settings → Cloud sync).
/// When neither is present the app runs fully local-only (sync disabled, but
/// everything else works offline).
class SupabaseConfig {
  static const _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const _envKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _initialized = false;
  static bool _fromEnv = false;
  static String _url = '';

  /// True once Supabase has been successfully initialised this session.
  static bool get isConfigured => _initialized;

  /// True when the active config came from build-time `--dart-define`s (so the
  /// in-app fields are informational only).
  static bool get configuredByEnv => _fromEnv;

  /// The URL currently in use (empty when unconfigured).
  static String get activeUrl => _url;

  /// Initialises Supabase from the env defines, else the [storedUrl]/[storedKey]
  /// passed in (e.g. read from the local DB). Safe to call unconditionally; a
  /// bad/empty config simply leaves the app local-only.
  static Future<void> init(
      {String storedUrl = '', String storedKey = ''}) async {
    final envSet = _envUrl.isNotEmpty && _envKey.isNotEmpty;
    final url = envSet ? _envUrl : storedUrl.trim();
    final key = envSet ? _envKey : storedKey.trim();
    if (url.isEmpty || key.isEmpty) return;
    try {
      await Supabase.initialize(url: url, publishableKey: key);
      _url = url;
      _fromEnv = envSet;
      _initialized = true;
    } catch (_) {
      // Malformed URL/key (or already initialised) — stay local-only.
      _initialized = false;
    }
  }

  /// The client, or null when sync is not configured.
  static SupabaseClient? get clientOrNull =>
      _initialized ? Supabase.instance.client : null;
}
