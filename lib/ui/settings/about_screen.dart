import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// About page: logo, app name, version (per build), and the developer + their
/// affiliation.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.science_outlined,
                      size: 52, color: scheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text('LabTrack',
                  textAlign: TextAlign.center, style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Local-first project management for bioscience research',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  final v = snap.data;
                  return Text(
                    v == null
                        ? ''
                        : 'Version ${v.version}   (build ${v.buildNumber})',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  );
                },
              ),
              const Divider(height: 40),
              _row(context, Icons.biotech_outlined, 'Developed by', 'Su Lab'),
              const SizedBox(height: 14),
              _row(context, Icons.school_outlined, 'Affiliation',
                  'Molecular Biosciences & Bioengineering\nUniversity of Hawaiʻi at Mānoa'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context, IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
