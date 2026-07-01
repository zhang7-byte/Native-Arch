import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/settings_repository.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('labtrack_settings');
    file = File('${dir.path}/settings.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('settings default to system / teal / comfortable', () async {
    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final s = await SettingsRepository(db).get();
    expect(s.themeMode, 'system');
    expect(s.accentColor, defaultAccent);
    expect(s.density, 'comfortable');
  });

  test('settings (incl. background) persist across a restart', () async {
    final db1 = AppDatabase(NativeDatabase(file));
    await SettingsRepository(db1).save(
        themeMode: 'dark',
        accentColor: 0xFFD81B60,
        density: 'compact',
        bgMode: 'gradient',
        bgColorA: 0xFF1A2980,
        bgColorB: 0xFF26D0CE,
        bgDim: 0.5,
        surfaceOpacity: 0.6,
        surfaceBlur: 24);
    await db1.close();

    // Reopen the same on-disk database (= app restart).
    final db2 = AppDatabase(NativeDatabase(file));
    addTearDown(db2.close);
    final s = await SettingsRepository(db2).get();
    expect(s.themeMode, 'dark');
    expect(s.accentColor, 0xFFD81B60);
    expect(s.density, 'compact');
    expect(s.bgMode, 'gradient');
    expect(s.bgColorA, 0xFF1A2980);
    expect(s.bgColorB, 0xFF26D0CE);
    expect(s.bgDim, 0.5);
    expect(s.surfaceOpacity, 0.6);
    expect(s.surfaceBlur, 24);
  });

  test('background defaults to none', () async {
    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final s = await SettingsRepository(db).get();
    expect(s.bgMode, 'none');
  });
}
