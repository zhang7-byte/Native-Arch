import 'package:drift/drift.dart';

import 'culture_event_repository.dart';
import 'database.dart';
import 'workspace_repository.dart';

/// Reads/writes [Culture] rows. Lifecycle is status-only — terminate/archive set
/// the status + ended_date and move a culture off the active list; restore puts
/// it back. Nothing here hard-deletes.
class CultureRepository {
  CultureRepository(this._db);

  final AppDatabase _db;

  Stream<List<Culture>> watchActive() => _db
      .customSelect(
        "SELECT * FROM cultures WHERE status = 'active' AND $workspaceScopeWhere "
        'ORDER BY started_date DESC',
        readsFrom: {_db.cultures, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.cultures.map(r.data)).toList());

  Stream<List<Culture>> watchArchived() => _db
      .customSelect(
        "SELECT * FROM cultures WHERE status IN ('terminated','archived') "
        'AND $workspaceScopeWhere ORDER BY ended_date DESC',
        readsFrom: {_db.cultures, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.cultures.map(r.data)).toList());

  Stream<Culture?> watchById(String id) =>
      (_db.select(_db.cultures)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<Culture?> findById(String id) =>
      (_db.select(_db.cultures)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<Culture>> watchForStrain(String strainId) =>
      (_db.select(_db.cultures)
            ..where((t) => t.strainId.equals(strainId))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.startedDate, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<String> create(CulturesCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    final id = uuid.v4();
    await _db.into(_db.cultures).insert(values.copyWith(
          id: Value(id),
          workspaceId: ws == null ? const Value.absent() : Value(ws),
        ));
    return id;
  }

  Future<void> update(String id, CulturesCompanion values) =>
      (_db.update(_db.cultures)..where((t) => t.id.equals(id))).write(values);

  /// Sets the lifecycle [status]. Active clears ended_date; terminated/archived
  /// stamp it now.
  Future<void> setStatus(String id, String status) =>
      (_db.update(_db.cultures)..where((t) => t.id.equals(id))).write(
        CulturesCompanion(
          status: Value(status),
          endedDate: status == 'active'
              ? const Value<DateTime?>(null)
              : Value<DateTime?>(DateTime.now().toUtc()),
        ),
      );

  Future<void> terminate(String id) => setStatus(id, 'terminated');
  Future<void> archive(String id) => setStatus(id, 'archived');
  Future<void> restore(String id) => setStatus(id, 'active');

  /// Splits [parent] into one or more new active sub-cultures. Each child has
  /// its own medium/vessel/amount/annotation, inherits the strain + inoculation
  /// lineage (mother + the mother's original inoculation time) with [splitTime]
  /// as its start (the amount taken is kept as the child's inoculum and its
  /// annotation as the child's notes), and a split entry is logged on the mother
  /// recording the amount. Returns the new cultures' ids, in order.
  Future<List<String>> split({
    required Culture parent,
    required DateTime splitTime,
    required List<CultureSplitChild> children,
  }) async {
    final events = CultureEventRepository(_db);
    final ids = <String>[];
    for (final ch in children) {
      final childId = await create(CulturesCompanion(
        name: Value(ch.name),
        strainId: Value(parent.strainId),
        status: const Value('active'),
        medium: Value(ch.medium),
        vessel: Value(ch.vessel),
        startedDate: Value(splitTime),
        notes: Value(ch.annotation),
        inoculumAmount: Value(ch.amount),
        selectionMarkers: Value(parent.selectionMarkers),
        parentCultureId: Value(parent.id),
        parentInoculatedAt: Value(parent.startedDate),
      ));
      ids.add(childId);
      await events.add(
        cultureId: parent.id,
        happenedAt: splitTime,
        type: 'split',
        agent: ch.name,
        amount: ch.amount,
        note: 'Split into "${ch.name}"'
            '${ch.amount.isNotEmpty ? ' (${ch.amount})' : ''}',
      );
    }
    return ids;
  }
}

/// One sub-culture to create when splitting: its name, medium, vessel, how much
/// was taken into it, and a free-text annotation (kept as the child's notes).
class CultureSplitChild {
  const CultureSplitChild({
    required this.name,
    this.medium = '',
    this.vessel = '',
    this.amount = '',
    this.annotation = '',
  });

  final String name;
  final String medium;
  final String vessel;
  final String amount;
  final String annotation;
}
