import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [CultureEvent] rows — the timestamped operations log on a
/// culture (sampling, reagent additions, induction, split, measurements, notes).
/// Newest first. Deleting routes through the Trash.
class CultureEventRepository {
  CultureEventRepository(this._db);

  final AppDatabase _db;

  Stream<List<CultureEvent>> watchForCulture(String cultureId) =>
      (_db.select(_db.cultureEvents)
            ..where((t) => t.cultureId.equals(cultureId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.happenedAt, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<String> add({
    required String cultureId,
    required DateTime happenedAt,
    required String type,
    String agent = '',
    String amount = '',
    String note = '',
  }) async {
    final ws = (await (_db.select(_db.cultures)
                  ..where((t) => t.id.equals(cultureId)))
                .getSingleOrNull())
            ?.workspaceId ??
        await currentWorkspaceId(_db) ??
        '';
    final id = uuid.v4();
    await _db.into(_db.cultureEvents).insert(CultureEventsCompanion.insert(
          id: Value(id),
          cultureId: cultureId,
          happenedAt: Value(happenedAt),
          type: Value(type),
          agent: Value(agent),
          amount: Value(amount),
          note: Value(note),
          workspaceId: Value(ws),
        ));
    return id;
  }

  Future<void> edit(String id,
          {required DateTime happenedAt,
          required String agent,
          required String amount,
          required String note}) =>
      (_db.update(_db.cultureEvents)..where((t) => t.id.equals(id))).write(
          CultureEventsCompanion(
              happenedAt: Value(happenedAt),
              agent: Value(agent),
              amount: Value(amount),
              note: Value(note)));

  Future<void> delete(String id) =>
      TrashRepository(_db).trash('culture_events', id);
}
