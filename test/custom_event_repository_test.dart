import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/custom_event_repository.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/trash_repository.dart';

void main() {
  test('create, list, and delete-to-trash (restorable) custom events',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CustomEventRepository(db);

    await repo.create(CustomEventsCompanion.insert(
        title: 'Birthday',
        date: DateTime(2026, 6, 11),
        category: const Value('birthday'),
        repeatAnnually: const Value(true)));
    var all = await repo.all();
    expect(all.length, 1);
    expect(all.first.title, 'Birthday');
    expect(all.first.repeatAnnually, isTrue);

    // Delete parks it in the Trash rather than destroying it.
    await repo.delete(all.first.id);
    expect(await repo.all(), isEmpty);
    final trash = TrashRepository(db);
    final parked = await trash.watchAll().first;
    expect(parked.length, 1);
    expect(parked.first.kind, 'Event');

    // …and it can be restored.
    await trash.restore(parked.first.id);
    expect((await repo.all()).length, 1);
  });
}
