import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../app_database_provider.dart';
import 'culture_tile.dart';

/// Sub-page listing terminated and archived cultures, each restorable to active.
class ArchivedCulturesScreen extends StatelessWidget {
  const ArchivedCulturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CultureRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Archived & Terminated')),
      body: StreamBuilder<List<Culture>>(
        stream: repo.watchArchived(),
        builder: (context, snap) {
          final items = snap.data ?? const <Culture>[];
          if (items.isEmpty) {
            return Center(
              child: Text('No archived or terminated cultures.',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => CultureTile(
              culture: items[i],
              trailing: IconButton(
                tooltip: 'Restore to active',
                icon: const Icon(Icons.restart_alt),
                onPressed: () => repo.restore(items[i].id),
              ),
            ),
          );
        },
      ),
    );
  }
}
