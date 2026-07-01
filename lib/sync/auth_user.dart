import 'supabase_config.dart';

/// The signed-in user's id, or null when local-only / signed out.
String? currentUserId() => SupabaseConfig.clientOrNull?.auth.currentUser?.id;

/// The signed-in user's email, or null when local-only / signed out.
String? currentUserEmail() =>
    SupabaseConfig.clientOrNull?.auth.currentUser?.email;
