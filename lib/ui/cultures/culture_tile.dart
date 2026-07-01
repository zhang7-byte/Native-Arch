import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../labels.dart';
import '../widgets.dart';
import 'culture_detail_screen.dart';
import 'culture_labels.dart';

class CultureTile extends StatelessWidget {
  const CultureTile({super.key, required this.culture, this.trailing});

  final Culture culture;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ended = culture.endedDate != null;
    return ListTile(
      leading: const Icon(Icons.bubble_chart_outlined),
      title: Text(culture.name.isEmpty ? 'Culture' : culture.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LabelChip(cultureStatusLabel(culture.status),
                color: cultureStatusColor(culture.status, scheme)),
            if (culture.medium.isNotEmpty) OutlineChip(culture.medium),
            Text(
              ended
                  ? 'Ended ${formatDate(culture.endedDate)}'
                  : 'Started ${formatDate(culture.startedDate)}',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: trailing,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CultureDetailScreen(cultureId: culture.id))),
    );
  }
}
