import 'package:flutter/material.dart';

import '../../sync/sync_controller.dart';
import '../glass.dart';
import '../labels.dart';
import 'sync_scope.dart';

/// Sign in/up and run cloud sync. The app works fully offline without this —
/// signing in just turns on syncing to your Supabase account.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _authError;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Returns an error message if the email/password are unusable, else null.
  /// (Guards against an empty email, which the client would otherwise treat as
  /// an anonymous sign-up — failing with a confusing "anonymous disabled".)
  String? _validate({bool signup = false}) {
    final email = _email.text.trim();
    final pw = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      return 'Enter a valid email address.';
    }
    if (pw.isEmpty) return 'Enter a password.';
    if (signup && pw.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _authError = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _authError = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmPull(BuildContext context, SyncController sync) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: const Text('Pull from cloud?'),
        content: const Text(
            'This replaces ALL data on this device with the cloud copy. A local '
            'backup of the current data is saved first. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Pull')),
        ],
      ),
    );
    if (ok == true) await sync.pull();
  }

  @override
  Widget build(BuildContext context) {
    final sync = SyncScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account & sync')),
      body: ListenableBuilder(
        listenable: sync,
        builder: (context, _) {
          if (!sync.isConfigured) return _notConfigured(context);
          if (!sync.isSignedIn) return _signedOut(context, sync);
          return _signedIn(context, sync);
        },
      ),
    );
  }

  Widget _notConfigured(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.cloud_off_outlined, size: 48),
        const SizedBox(height: 12),
        Text('Cloud sync is not configured',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text(
          'LabTrack is running local-only. To enable two-way sync, open '
          'Settings → Cloud sync, enter your Supabase project URL and anon key, '
          'then restart LabTrack.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'First run supabase/schema.sql in your Supabase SQL editor. '
          'See SYNC.md for the full walkthrough. (Builds can also be configured '
          'with --dart-define=SUPABASE_URL / SUPABASE_ANON_KEY.)',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _signedOut(BuildContext context, SyncController sync) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Sign in to sync', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _email,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          enabled: !_busy,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        if (_authError != null) ...[
          const SizedBox(height: 12),
          Text(_authError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        if (_info != null) ...[
          const SizedBox(height: 12),
          Text(_info!),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy
              ? null
              : () {
                  final err = _validate();
                  if (err != null) {
                    setState(() => _authError = err);
                    return;
                  }
                  _run(() => sync.signIn(_email.text, _password.text));
                },
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Sign in'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () {
                  final err = _validate(signup: true);
                  if (err != null) {
                    setState(() => _authError = err);
                    return;
                  }
                  _run(() async {
                    final session =
                        await sync.signUp(_email.text, _password.text);
                    if (!session && mounted) {
                      setState(() => _info =
                          'Account created. If email confirmation is on, confirm '
                          'via the email, then sign in.');
                    }
                  });
                },
          child: const Text('Create account'),
        ),
      ],
    );
  }

  Widget _signedIn(BuildContext context, SyncController sync) {
    final result = sync.lastResult;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: Text(sync.user?.email ?? 'Signed in'),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule),
          title: const Text('Last sync'),
          subtitle: Text(sync.lastSyncedAt == null
              ? 'Never'
              : '${formatDate(sync.lastSyncedAt)} '
                  '${sync.lastSyncedAt!.toLocal().toString().substring(11, 19)}'),
        ),
        if (result != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
                'Pushed ${result.pushed} · pulled ${result.pulled} · deleted ${result.deleted}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        if (sync.error != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text('Sync error: ${sync.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        if (_info != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: SelectableText(_info!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : () => _run(() async {
                    final result = await sync.diagnose();
                    if (mounted) setState(() => _info = result);
                  }),
          icon: const Icon(Icons.wifi_tethering),
          label: const Text('Test connection'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: sync.isSyncing ? null : () => sync.push(),
          icon: sync.isSyncing
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(sync.isSyncing ? 'Syncing…' : 'Push to cloud'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: sync.isSyncing ? null : () => _confirmPull(context, sync),
          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Pull from cloud'),
        ),
        const SizedBox(height: 4),
        Text(
          'Push uploads this device to the cloud (overwriting it); pull replaces '
          'this device with the cloud copy. Closing the app pushes by default — '
          'change the direction in Settings → Cloud sync.',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: sync.isSyncing ? null : sync.signOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}
