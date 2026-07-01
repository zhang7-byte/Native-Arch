import 'package:drift/drift.dart';

import 'database.dart';

/// Default accent — warm terracotta (Section 9) — used until the user picks one.
const defaultAccent = 0xFFC96442;

/// Reads/writes the single-row [AppSetting] (user preferences). Returns defaults
/// when no row exists yet.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static AppSetting defaults() => AppSetting(
        id: 0,
        themeMode: 'system',
        accentColor: defaultAccent,
        density: 'comfortable',
        bgMode: 'none',
        bgColorA: 0xFF0F2027,
        bgColorB: 0xFF2C5364,
        bgImage: '',
        bgDim: 0.35,
        surfaceOpacity: 0.78,
        surfaceBlur: 18.0,
        notifyFrequency: 'daily',
        holidayRegion: 'none',
        scheduleNotify: true,
        allowMultipleInstances: true,
        updatedAt: DateTime.now().toUtc(),
      );

  Stream<AppSetting> watch() =>
      (_db.select(_db.appSettings)..where((t) => t.id.equals(0)))
          .watchSingleOrNull()
          .map((row) => row ?? defaults());

  Future<AppSetting> get() async =>
      (await (_db.select(_db.appSettings)..where((t) => t.id.equals(0)))
          .getSingleOrNull()) ??
      defaults();

  Future<void> save({
    String? themeMode,
    int? accentColor,
    String? density,
    String? bgMode,
    int? bgColorA,
    int? bgColorB,
    String? bgImage,
    double? bgDim,
    double? surfaceOpacity,
    double? surfaceBlur,
    String? notifyFrequency,
    String? holidayRegion,
    bool? scheduleNotify,
    bool? allowMultipleInstances,
  }) async {
    final current = await get();
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion(
            id: const Value(0),
            themeMode: Value(themeMode ?? current.themeMode),
            accentColor: Value(accentColor ?? current.accentColor),
            density: Value(density ?? current.density),
            bgMode: Value(bgMode ?? current.bgMode),
            bgColorA: Value(bgColorA ?? current.bgColorA),
            bgColorB: Value(bgColorB ?? current.bgColorB),
            bgImage: Value(bgImage ?? current.bgImage),
            bgDim: Value(bgDim ?? current.bgDim),
            surfaceOpacity: Value(surfaceOpacity ?? current.surfaceOpacity),
            surfaceBlur: Value(surfaceBlur ?? current.surfaceBlur),
            notifyFrequency: Value(notifyFrequency ?? current.notifyFrequency),
            holidayRegion: Value(holidayRegion ?? current.holidayRegion),
            scheduleNotify: Value(scheduleNotify ?? current.scheduleNotify),
            allowMultipleInstances: Value(
                allowMultipleInstances ?? current.allowMultipleInstances),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }
}
