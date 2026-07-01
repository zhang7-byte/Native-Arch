import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import 'supabase_config.dart';
import 'sync_service.dart';

/// Owns auth + sync state and exposes it to the UI. Local-first: when Supabase
/// is unconfigured or signed out, the app still works fully offline; this just
/// drives the optional cloud-sync layer.
class SyncController extends ChangeNotifier {
  SyncController(this._db) {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      _service = SyncService(_db, client);
      // Reflect auth changes in the UI (the login gate). Syncing itself only
      // happens on app close or when the user taps "Sync now".
      _authSub = client.auth.onAuthStateChange.listen((_) => notifyListeners());
    }
  }

  final AppDatabase _db;
  SyncService? _service;
  StreamSubscription<AuthState>? _authSub;

  bool _syncing = false;
  String? _error;
  DateTime? _lastSyncedAt;
  SyncResult? _lastResult;

  bool get isConfigured => SupabaseConfig.isConfigured;
  SupabaseClient? get _client => SupabaseConfig.clientOrNull;
  User? get user => _client?.auth.currentUser;
  bool get isSignedIn => user != null;
  bool get isSyncing => _syncing;
  String? get error => _error;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  SyncResult? get lastResult => _lastResult;

  Future<void> signIn(String email, String password) async {
    await _client!.auth
        .signInWithPassword(email: email.trim(), password: password);
    // The auth listener fires sign-in -> syncNow + notifyListeners.
  }

  /// Returns true if a session was created immediately (email confirmation off).
  Future<bool> signUp(String email, String password) async {
    final res =
        await _client!.auth.signUp(email: email.trim(), password: password);
    notifyListeners();
    return res.session != null;
  }

  Future<void> signOut() async {
    await _client!.auth.signOut();
    notifyListeners();
  }

  /// Diagnostic: reports the role the local session token claims and the role
  /// the SERVER actually sees for a request (via the whoami() function). A
  /// mismatch (local=authenticated, server=anon) means the token isn't being
  /// attached to data requests.
  Future<String> diagnose() async {
    final client = _client;
    if (client == null) return 'Cloud sync is not configured.';
    final out = StringBuffer();
    final session = client.auth.currentSession;
    if (session == null) {
      out.writeln('• Local: no active session (signed out?).');
    } else {
      try {
        final parts = session.accessToken.split('.');
        final claims = json.decode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
            as Map<String, dynamic>;
        out.writeln('• Local token: role=${claims['role']} '
            'sub=${claims['sub']} expired=${session.isExpired}');
      } catch (e) {
        out.writeln('• Local token decode failed: $e');
      }
    }
    try {
      final res = await client.rpc('whoami');
      out.write('• Server sees: $res');
    } catch (e) {
      out.write('• Server whoami() failed: $e');
    }
    return out.toString().trim();
  }

  /// Upload this device's snapshot, overwriting the cloud copy.
  Future<void> push() => _run(() => _service!.push());

  /// Download the cloud snapshot, replacing this device's data.
  Future<void> pull() => _run(() => _service!.pull());

  Future<void> _run(Future<SyncResult> Function() op) async {
    if (_service == null || !isSignedIn || _syncing) return;
    _syncing = true;
    _error = null;
    notifyListeners();
    try {
      _lastResult = await op();
      _lastSyncedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
