import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../data/csv_import.dart';
import '../../data/database.dart';
import '../../data/holidays.dart';
import '../../data/file_save_web.dart'
    if (dart.library.io) '../../data/file_save_io.dart';
import '../../data/seed.dart';
import '../../data/settings_repository.dart';
import '../../data/backup.dart';
import '../../data/inventory_wipe.dart';
import '../../data/workspace_repository.dart';
import '../../notifications/deadline_notifier.dart';
import '../../notifications/notification_service.dart';
import '../../sync/cloud_config.dart';
import '../../sync/supabase_config.dart';
import '../../sync/sync_prefs.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../lock.dart';
import '../trash/trash_screen.dart';
import 'about_screen.dart';
import 'app_background.dart';
import 'settings_theme.dart';

/// Appearance settings: theme mode, accent colour, density. Persisted locally
/// and synced per-user. The whole app re-themes reactively when these change.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SettingsRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: const [AccountButton()],
      ),
      body: StreamBuilder<AppSetting>(
        stream: repo.watch(),
        builder: (context, snap) {
          final s = snap.data ?? SettingsRepository.defaults();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Theme', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'light',
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light')),
                  ButtonSegment(
                      value: 'system',
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System')),
                  ButtonSegment(
                      value: 'dark',
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark')),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (sel) => repo.save(themeMode: sel.first),
              ),
              const SizedBox(height: 28),
              Text('Accent colour',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final c in accentPalette)
                    _Swatch(
                      color: Color(c),
                      selected: s.accentColor == c,
                      onTap: () => repo.save(accentColor: c),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Density', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'comfortable', label: Text('Comfortable')),
                  ButtonSegment(value: 'compact', label: Text('Compact')),
                ],
                selected: {s.density},
                onSelectionChanged: (sel) => repo.save(density: sel.first),
              ),
              const SizedBox(height: 28),
              Text('Notifications',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _NotificationsSection(setting: s, repo: repo),
              const SizedBox(height: 28),
              Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _ScheduleSection(setting: s, repo: repo),
              const SizedBox(height: 28),
              Text('Window', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _WindowSection(setting: s, repo: repo),
              const SizedBox(height: 28),
              Text('Access', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const _LockdownSection(),
              const SizedBox(height: 28),
              Text('Cloud sync', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const _CloudSyncSection(),
              const SizedBox(height: 28),
              Text('Background',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _BackgroundSection(setting: s, repo: repo),
              const SizedBox(height: 28),
              Text('CSV import templates',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const _CsvTemplatesSection(),
              const SizedBox(height: 28),
              Text('Recently deleted',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Deleted items are kept for 30 days so you can restore them.',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TrashScreen())),
                  icon: const Icon(Icons.restore_from_trash_outlined),
                  label: const Text('Open trash'),
                ),
              ),
              const SizedBox(height: 28),
              Text('Demonstration data',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const _DemoDataSection(),
              const SizedBox(height: 28),
              Text('Delete inventory',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const _DeleteInventorySection(),
              const SizedBox(height: 28),
              Text(
                'Preferences are saved on this device and synced to your account '
                'when signed in (Account & sync). Notification frequency stays on '
                'this device.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              Text('About', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen())),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('About LabTrack'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackgroundSection extends StatefulWidget {
  const _BackgroundSection({required this.setting, required this.repo});
  final AppSetting setting;
  final SettingsRepository repo;

  @override
  State<_BackgroundSection> createState() => _BackgroundSectionState();
}

class _BackgroundSectionState extends State<_BackgroundSection> {
  double? _dragDim; // transient values while dragging the sliders
  double? _dragOpacity;
  double? _dragBlur;

  Future<void> _pickImage() async {
    final res =
        await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (res == null || res.files.isEmpty) return;
    final bytes = res.files.first.bytes;
    if (bytes == null) return;
    await widget.repo.save(bgMode: 'image', bgImage: base64Encode(bytes));
  }

  Widget _sliderRow(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required String display,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onEnd,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('$label · $display',
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onEnd,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.setting;
    final repo = widget.repo;
    final mode = s.bgMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'none', label: Text('None')),
            ButtonSegment(value: 'color', label: Text('Colour')),
            ButtonSegment(value: 'gradient', label: Text('Gradient')),
            ButtonSegment(value: 'image', label: Text('Image')),
          ],
          selected: {mode},
          onSelectionChanged: (sel) {
            final m = sel.first;
            if (m == 'image') {
              _pickImage();
            } else {
              repo.save(bgMode: m);
            }
          },
        ),
        if (mode == 'color') ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in backgroundPalette)
                _Swatch(
                  color: Color(c),
                  selected: s.bgColorA == c,
                  onTap: () => repo.save(bgMode: 'color', bgColorA: c),
                ),
            ],
          ),
        ],
        if (mode == 'gradient') ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final g in gradientPresets)
                _GradientSwatch(
                  a: Color(g.$1),
                  b: Color(g.$2),
                  selected: s.bgColorA == g.$1 && s.bgColorB == g.$2,
                  onTap: () => repo.save(
                      bgMode: 'gradient', bgColorA: g.$1, bgColorB: g.$2),
                ),
            ],
          ),
        ],
        if (mode == 'image') ...[
          const SizedBox(height: 14),
          Row(
            children: [
              _ImageThumb(bgImage: s.bgImage),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Choose image'),
              ),
            ],
          ),
        ],
        if (mode != 'none') ...[
          const SizedBox(height: 12),
          // The content sits on one frosted glass surface over the background.
          _sliderRow(
            context,
            label: 'Surface opacity',
            value: (_dragOpacity ?? s.surfaceOpacity)
                .clamp(kMinSurfaceOpacity, 1.0),
            min: kMinSurfaceOpacity,
            max: 1.0,
            display: '${((_dragOpacity ?? s.surfaceOpacity) * 100).round()}%',
            onChanged: (v) => setState(() => _dragOpacity = v),
            onEnd: (v) {
              repo.save(surfaceOpacity: v);
              setState(() => _dragOpacity = null);
            },
          ),
          _sliderRow(
            context,
            label: 'Blur',
            value: (_dragBlur ?? s.surfaceBlur).clamp(0.0, kMaxSurfaceBlur),
            min: 0,
            max: kMaxSurfaceBlur,
            display: '${(_dragBlur ?? s.surfaceBlur).round()}',
            onChanged: (v) => setState(() => _dragBlur = v),
            onEnd: (v) {
              repo.save(surfaceBlur: v);
              setState(() => _dragBlur = null);
            },
          ),
          _sliderRow(
            context,
            label: 'Dim background',
            value: (_dragDim ?? s.bgDim).clamp(0.0, 1.0),
            min: 0,
            max: 1,
            display: '${((_dragDim ?? s.bgDim) * 100).round()}%',
            onChanged: (v) => setState(() => _dragDim = v),
            onEnd: (v) {
              repo.save(bgDim: v);
              setState(() => _dragDim = null);
            },
          ),
        ],
      ],
    );
  }
}

class _GradientSwatch extends StatelessWidget {
  const _GradientSwatch(
      {required this.a,
      required this.b,
      required this.selected,
      required this.onTap});
  final Color a;
  final Color b;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, b]),
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface, width: 3)
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.bgImage});
  final String bgImage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bytes = decodeBgImage(bgImage);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 54,
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: bytes == null
            ? Icon(Icons.image_not_supported_outlined,
                color: scheme.onSurfaceVariant)
            : Image.memory(bytes,
                width: 72, height: 54, fit: BoxFit.cover, gaplessPlayback: true),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(
      {required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface, width: 3)
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 22)
            : null,
      ),
    );
  }
}

/// Deadline-reminder cadence + a test button. Frequency is device-local.
class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({required this.setting, required this.repo});
  final AppSetting setting;
  final SettingsRepository repo;

  Future<void> _test(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final svc = NotificationService();
    await svc.init();
    await svc.show('LabTrack', 'Test notification — reminders are working.');
    messenger.showSnackBar(
        const SnackBar(content: Text('Sent a test notification.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final freq = NotifyFrequency.fromKey(setting.notifyFrequency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
                child: Text('Remind me about due & overdue deadlines')),
            const SizedBox(width: 12),
            DropdownButton<NotifyFrequency>(
              value: freq,
              onChanged: (v) {
                if (v != null) repo.save(notifyFrequency: v.key);
              },
              items: [
                for (final f in NotifyFrequency.values)
                  DropdownMenuItem(value: f, child: Text(f.label)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Reminders appear while LabTrack is open. '
          '${kIsWeb ? 'Allow notifications when your browser asks. ' : ''}'
          'On desktop they show as system notifications.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _test(context),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Send a test notification'),
          ),
        ),
      ],
    );
  }
}

/// Schedule preferences: which holiday calendar to overlay, and whether to be
/// notified of each day's plan on launch / close.
class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.setting, required this.repo});
  final AppSetting setting;
  final SettingsRepository repo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Show public holidays for')),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: setting.holidayRegion,
              onChanged: (v) {
                if (v != null) repo.save(holidayRegion: v);
              },
              items: [
                for (final (code, label) in holidayRegions)
                  DropdownMenuItem(value: code, child: Text(label)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Holidays appear on the Schedule calendar and its PDF.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: setting.scheduleNotify,
          onChanged: (v) => repo.save(scheduleNotify: v),
          title: const Text("Notify me of the day's schedule"),
          subtitle: const Text("Today's plan on launch; tomorrow's on close."),
        ),
      ],
    );
  }
}

/// In-app Supabase config so cloud sync can be enabled without rebuilding.
/// Values are saved locally and take effect on the next launch.
class _CloudSyncSection extends StatefulWidget {
  const _CloudSyncSection();

  @override
  State<_CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends State<_CloudSyncSection> {
  final _url = TextEditingController();
  final _key = TextEditingController();
  bool _loaded = false;
  bool _dirty = false;
  bool _obscureKey = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    readCloudConfig(AppDatabaseProvider.of(context)).then((cfg) {
      if (!mounted) return;
      setState(() {
        _url.text = cfg.$1;
        _key.text = cfg.$2;
      });
    });
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    await saveCloudConfig(AppDatabaseProvider.of(context),
        url: _url.text, anonKey: _key.text);
    if (!mounted) return;
    setState(() => _dirty = true);
    messenger.showSnackBar(const SnackBar(
        content: Text('Saved. Restart LabTrack to connect.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = SupabaseConfig.isConfigured;
    final byEnv = SupabaseConfig.configuredByEnv;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(active ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                size: 20,
                color: active ? Colors.green : scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                active
                    ? 'Connected to ${SupabaseConfig.activeUrl}'
                    : 'Not connected — enter your Supabase project, then '
                        'restart LabTrack.',
                style:
                    TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (byEnv)
          Text(
            'This build is configured via --dart-define, which takes priority '
            'over these fields.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          )
        else ...[
          TextField(
            controller: _url,
            decoration: const InputDecoration(
                labelText: 'Supabase project URL',
                hintText: 'https://YOUR.supabase.co'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _key,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              labelText: 'Anon / publishable key',
              suffixIcon: IconButton(
                tooltip: _obscureKey ? 'Show' : 'Hide',
                icon: Icon(_obscureKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ),
          if (_dirty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Restart LabTrack to apply.',
                  style:
                      TextStyle(color: scheme.primary, fontSize: 12)),
            ),
        ],
        const SizedBox(height: 12),
        StreamBuilder<CloseSync>(
          stream: watchCloseSync(AppDatabaseProvider.of(context)),
          builder: (context, snap) {
            final mode = snap.data ?? CloseSync.push;
            return Row(
              children: [
                const Expanded(child: Text('Sync on close')),
                const SizedBox(width: 12),
                DropdownButton<CloseSync>(
                  value: mode,
                  onChanged: (v) {
                    if (v != null) {
                      saveCloseSync(AppDatabaseProvider.of(context), v);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: CloseSync.push, child: Text('Push')),
                    DropdownMenuItem(value: CloseSync.pull, child: Text('Pull')),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'When you close the app it syncs in this direction (default: push your '
          'changes up). Choose Push or Pull explicitly from Account & sync any '
          'time. First run supabase/schema.sql in your Supabase SQL editor.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}

/// Window/app behaviour preferences.
class _WindowSection extends StatelessWidget {
  const _WindowSection({required this.setting, required this.repo});
  final AppSetting setting;
  final SettingsRepository repo;

  @override
  Widget build(BuildContext context) {
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: setting.allowMultipleInstances,
          onChanged: (v) => repo.save(allowMultipleInstances: v),
          title: const Text('Allow multiple instances'),
          subtitle: const Text(
              'When off, launching LabTrack again focuses the running window '
              'instead of opening a second one (Windows). Takes effect next '
              'launch.'),
        ),
        if (isDesktop) const _StartupTile(),
      ],
    );
  }
}

/// Toggles launching LabTrack automatically when the user signs in (desktop).
/// The OS startup registration is the source of truth, read on build.
class _StartupTile extends StatefulWidget {
  const _StartupTile();

  @override
  State<_StartupTile> createState() => _StartupTileState();
}

class _StartupTileState extends State<_StartupTile> {
  bool? _enabled;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final v = await launchAtStartup.isEnabled();
      if (mounted) setState(() => _enabled = v);
    } catch (_) {
      if (mounted) setState(() => _enabled = false);
    }
  }

  Future<void> _set(bool v) async {
    setState(() => _busy = true);
    try {
      if (v) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
      if (mounted) setState(() => _enabled = v);
    } catch (_) {
      // Platform refused — leave the toggle as it was.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: _enabled ?? false,
      onChanged: (_enabled == null || _busy) ? null : _set,
      title: const Text('Launch at login'),
      subtitle: const Text(
          'Start LabTrack automatically when you sign in to this computer.'),
    );
  }
}

/// Downloadable example CSVs that match exactly what the importer expects.
class _CsvTemplatesSection extends StatelessWidget {
  const _CsvTemplatesSection();

  static String _label(ImportEntity e) => switch (e) {
        ImportEntity.strain => 'Strains',
        ImportEntity.reagent => 'Reagents',
        ImportEntity.primer => 'Primers',
        ImportEntity.protocol => 'Protocols',
      };

  Future<void> _download(BuildContext context, ImportEntity e) async {
    final messenger = ScaffoldMessenger.of(context);
    final bytes = Uint8List.fromList(utf8.encode(sampleCsv(e)));
    final name = 'labtrack-${_label(e).toLowerCase()}-template.csv';
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save CSV template',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      bytes: bytes,
    );
    if (!kIsWeb) {
      if (path == null) return; // cancelled
      await writeBytes(path, bytes);
    }
    messenger.showSnackBar(SnackBar(content: Text('Saved $name')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Download a sample CSV showing the columns the importer expects '
          '(matched by header name), then replace the example rows with your '
          'own before importing from the Strains, Reagents or Primers screens.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final e in ImportEntity.values)
              OutlinedButton.icon(
                onPressed: () => _download(context, e),
                icon: const Icon(Icons.description_outlined),
                label: Text('${_label(e)} template'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Removes the bundled SPEC.md example data (kept separate from the user's own).
class _DemoDataSection extends StatefulWidget {
  const _DemoDataSection();

  @override
  State<_DemoDataSection> createState() => _DemoDataSectionState();
}

class _DemoDataSectionState extends State<_DemoDataSection> {
  bool _busy = false;

  Future<void> _remove() async {
    final db = AppDatabaseProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (appLock.value) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Turn off Read-only mode to delete.')));
      return;
    }
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove demonstration data?'),
        content: const Text(
            'This deletes the example projects, experiments and strains that '
            'ship with LabTrack (and anything attached to them). Your own data '
            'is not affected. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      final n = await removeSeedData(db);
      messenger.showSnackBar(SnackBar(
          content: Text(n == 0
              ? 'No demonstration data to remove.'
              : 'Removed $n demonstration item${n == 1 ? '' : 's'}.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LabTrack ships with example projects, experiments and strains so the "
          "app isn't empty on first launch. Remove them once you've added your "
          'own work — your own entries are kept, and the examples will not come '
          'back.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _remove,
            style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_sweep_outlined),
            label: const Text('Remove demonstration data'),
          ),
        ),
      ],
    );
  }
}

/// Bulk-delete whole inventory categories (strains / reagents / primers /
/// cultures) for the current workspace, prompting the user to back up first.
/// This is a permanent delete (not routed through the Trash), so the backup is
/// the recovery path.
class _DeleteInventorySection extends StatefulWidget {
  const _DeleteInventorySection();

  @override
  State<_DeleteInventorySection> createState() =>
      _DeleteInventorySectionState();
}

class _DeleteInventorySectionState extends State<_DeleteInventorySection> {
  final Set<InventoryKind> _selected = {};
  Map<InventoryKind, int>? _counts;
  bool _loaded = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final c = await inventoryCounts(AppDatabaseProvider.of(context));
    if (mounted) setState(() => _counts = c);
  }

  /// Exports a full-workspace backup before deleting. Returns false if the user
  /// cancelled the save dialog (so we abort the delete).
  Future<bool> _backup(AppDatabase db) async {
    final wsId = await currentWorkspaceId(db);
    final wsName =
        wsId == null ? null : (await WorkspaceRepository(db).findById(wsId))?.name;
    final backup = await buildWorkspaceBackup(db,
        workspaceId: wsId, workspaceName: wsName);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save a backup before deleting',
      fileName: 'labtrack-backup-before-delete.json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );
    if (!kIsWeb) {
      if (path == null) return false; // cancelled
      await writeBytes(path, bytes);
    }
    return true;
  }

  Future<void> _delete() async {
    final db = AppDatabaseProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (appLock.value) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Turn off Read-only mode to delete.')));
      return;
    }
    final selected = _selected.toList();
    final total =
        selected.fold<int>(0, (a, k) => a + (_counts?[k] ?? 0));
    if (total == 0) return;
    final names = selected.map((k) => k.label.toLowerCase()).join(', ');

    // Ask to back up before proceeding.
    final choice = await showGlassDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete inventory?'),
        content: Text(
            'This permanently deletes ALL $names ($total item'
            '${total == 1 ? '' : 's'}) in this workspace, including their '
            'attached images. It cannot be undone and does NOT go to the Trash. '
            'Back up first.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: Text('Delete without backup',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, 'backup'),
            icon: const Icon(Icons.download),
            label: const Text('Back up & delete'),
          ),
        ],
      ),
    );
    if (choice == null || choice == 'cancel') return;

    setState(() => _busy = true);
    try {
      if (choice == 'backup') {
        final saved = await _backup(db);
        if (!saved) {
          messenger.showSnackBar(const SnackBar(
              content: Text('Backup cancelled — nothing was deleted.')));
          return;
        }
      }
      // Second and final confirmation before the irreversible wipe.
      if (!mounted) return;
      final reallyDelete = await showGlassDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete — are you sure?'),
          content: Text(
              'Final confirmation: permanently delete $names ($total item'
              '${total == 1 ? '' : 's'})? This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep')),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete permanently'),
            ),
          ],
        ),
      );
      if (reallyDelete != true) return;
      final n = await wipeInventory(db, _selected);
      if (!mounted) return;
      setState(() => _selected.clear());
      await _loadCounts();
      messenger.showSnackBar(SnackBar(
          content:
              Text('Deleted $n inventory item${n == 1 ? '' : 's'}.')));
    } catch (e) {
      messenger
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final counts = _counts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permanently delete every item of the chosen inventory types in the '
          'current workspace. Use this to clear out a workspace — to remove a '
          'single item, delete it from its own screen (that keeps it in the '
          'Trash). You will be asked to back up first; this delete cannot be '
          'undone.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (counts == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          for (final kind in InventoryKind.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _selected.contains(kind),
              onChanged: ((counts[kind] ?? 0) == 0 || _busy)
                  ? null
                  : (v) => setState(() => v == true
                      ? _selected.add(kind)
                      : _selected.remove(kind)),
              title: Text('${kind.label} (${counts[kind] ?? 0})'),
            ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: (_busy || _selected.isEmpty) ? null : _delete,
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_forever_outlined),
            label: const Text('Delete selected inventory'),
          ),
        ),
      ],
    );
  }
}

/// Read-only ("lockdown") mode toggle — blocks adding, editing and deleting
/// across the app (device-local).
class _LockdownSection extends StatelessWidget {
  const _LockdownSection();

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: appLock,
      builder: (context, locked, _) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: locked,
        onChanged: (v) => setAppLock(db, v),
        title: const Text('Read-only mode'),
        subtitle: const Text(
            'Lock the app to prevent adding, editing and deleting. Viewing and '
            'exporting stay available. Saved on this device.'),
      ),
    );
  }
}
