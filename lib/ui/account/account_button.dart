import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'sync_scope.dart';

/// App-bar button that opens the account/sync screen, with an icon reflecting
/// the current sync state.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = SyncScope.of(context);
    final IconData icon;
    if (!sync.isConfigured) {
      icon = Icons.cloud_off_outlined;
    } else if (sync.isSignedIn) {
      icon = Icons.cloud_done_outlined;
    } else {
      icon = Icons.cloud_outlined;
    }
    return IconButton(
      tooltip: 'Account & sync',
      icon: sync.isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon),
      onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccountScreen())),
    );
  }
}
