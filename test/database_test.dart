import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/project_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory SQLite exercises the real schema without touching disk.
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('all six tables are created', () async {
    final names = db.allTables.map((t) => t.actualTableName).toSet();
    expect(
      names,
      containsAll(<String>[
        'projects',
        'experiments',
        'tasks',
        'strains',
        'reagents',
        'manuscripts',
      ]),
    );
  });

  test('project insert: UUID id, enum defaults, list converter', () async {
    await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            title: 'CRISPR knock-in screen',
            tags: const Value(['crispr', 'screen']),
          ),
        );

    final project = await db.select(db.projects).getSingle();
    expect(project.id, isNotEmpty); // UUID assigned by clientDefault
    expect(project.status, ProjectStatus.planning); // enum default
    expect(project.priority, Priority.medium); // Priority enum default
    expect(project.description, ''); // non-null string default
    expect(project.tags, ['crispr', 'screen']); // list converter round-trip
    expect(project.createdAt, isNotNull);
  });

  test('experiment stores strain_ids and string defaults', () async {
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'P'));
    final p = await db.select(db.projects).getSingle();

    await db.into(db.experiments).insert(
          ExperimentsCompanion.insert(
            projectId: p.id,
            title: 'GFP spectra',
            strainIds: const Value(['str-2419', 'str-2542']),
          ),
        );
    final e = await db.select(db.experiments).getSingle();
    expect(e.strainIds, ['str-2419', 'str-2542']); // logical FK array
    expect(e.hypothesis, ''); // non-null string default
    expect(e.dataLinks, isEmpty);
    expect(e.status, ExperimentStatus.planned);
  });

  test('task defaults: status todo, priority medium, optional links', () async {
    await db.into(db.tasks).insert(TasksCompanion.insert(title: 'Order primers'));
    final t = await db.select(db.tasks).getSingle();
    expect(t.status, TaskStatus.todo);
    expect(t.priority, Priority.medium);
    expect(t.projectId, isNull);
    expect(t.experimentId, isNull);
    expect(t.description, '');
  });

  test('a task can attach to a project and experiment, or neither', () async {
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'P'));
    final p = await db.select(db.projects).getSingle();
    await db
        .into(db.experiments)
        .insert(ExperimentsCompanion.insert(projectId: p.id, title: 'E'));
    final e = await db.select(db.experiments).getSingle();

    await db.into(db.tasks).insert(TasksCompanion.insert(
          title: 'linked',
          projectId: Value(p.id),
          experimentId: Value(e.id),
        ));
    await db.into(db.tasks).insert(TasksCompanion.insert(title: 'standalone'));

    final tasks = await db.select(db.tasks).get();
    final linked = tasks.firstWhere((t) => t.title == 'linked');
    expect(linked.projectId, p.id);
    expect(linked.experimentId, e.id);
    final standalone = tasks.firstWhere((t) => t.title == 'standalone');
    expect(standalone.projectId, isNull);
    expect(standalone.experimentId, isNull);
  });

  test('deleting an experiment cascades to its tasks', () async {
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'P'));
    final p = await db.select(db.projects).getSingle();
    await db
        .into(db.experiments)
        .insert(ExperimentsCompanion.insert(projectId: p.id, title: 'E'));
    final e = await db.select(db.experiments).getSingle();
    await db.into(db.tasks).insert(
        TasksCompanion.insert(title: 'child', experimentId: Value(e.id)));
    expect(await db.select(db.tasks).get(), hasLength(1));

    await (db.delete(db.experiments)..where((t) => t.id.equals(e.id))).go();
    expect(await db.select(db.tasks).get(), isEmpty);
  });

  test('deleting a project tombstones it and its cascaded children', () async {
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'P'));
    final p = await db.select(db.projects).getSingle();
    await db
        .into(db.experiments)
        .insert(ExperimentsCompanion.insert(projectId: p.id, title: 'E'));
    final e = await db.select(db.experiments).getSingle();
    await db.into(db.tasks).insert(
        TasksCompanion.insert(title: 'T', experimentId: Value(e.id)));
    await db
        .into(db.manuscripts)
        .insert(ManuscriptsCompanion.insert(projectId: p.id, title: 'M'));

    await ProjectRepository(db).delete(p.id);

    expect(await db.select(db.projects).get(), isEmpty);
    expect(await db.select(db.experiments).get(), isEmpty);
    expect(await db.select(db.tasks).get(), isEmpty);
    expect(await db.select(db.manuscripts).get(), isEmpty);

    final tombstones = await db.select(db.tombstones).get();
    expect(tombstones.map((t) => t.entityTable).toSet(),
        {'projects', 'experiments', 'tasks', 'manuscripts'});
    expect(tombstones, hasLength(4));
  });

  test('foreign keys cascade: deleting a project removes its experiments',
      () async {
    await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(title: 'Parent project'));
    final project = await db.select(db.projects).getSingle();

    await db.into(db.experiments).insert(
          ExperimentsCompanion.insert(
            projectId: project.id,
            title: 'Gel electrophoresis',
          ),
        );
    expect(await db.select(db.experiments).get(), hasLength(1));

    await (db.delete(db.projects)..where((t) => t.id.equals(project.id))).go();
    expect(await db.select(db.experiments).get(), isEmpty);
  });

  test('AFTER UPDATE trigger refreshes updatedAt on a row edit', () async {
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'T'));
    final before = await db.select(db.projects).getSingle();

    await Future<void>.delayed(const Duration(milliseconds: 25));
    await (db.update(db.projects)..where((t) => t.id.equals(before.id)))
        .write(const ProjectsCompanion(title: Value('T2')));

    final after = await (db.select(db.projects)
          ..where((t) => t.id.equals(before.id)))
        .getSingle();
    expect(after.title, 'T2');
    expect(after.updatedAt.isAfter(before.updatedAt), isTrue,
        reason: 'the AFTER UPDATE trigger should bump updated_at');
  });

  test('enum constant names match the SPEC.md wire format', () {
    // These names are the strings persisted in SQLite (drift textEnum stores
    // Enum.name) and must stay identical to SPEC.md Section 3.
    expect(ProjectStatus.values.map((e) => e.name).toList(), [
      'planning',
      'active',
      'manuscript_prep',
      'under_review',
      'published',
      'shelved',
    ]);
    expect(Priority.values.map((e) => e.name).toList(),
        ['low', 'medium', 'high']);
    expect(ExperimentStatus.values.map((e) => e.name).toList(),
        ['planned', 'running', 'done', 'failed']);
    expect(TaskStatus.values.map((e) => e.name).toList(),
        ['todo', 'doing', 'done', 'blocked']);
    expect(ManuscriptStatus.values.map((e) => e.name).toList(), [
      'drafting',
      'submitted',
      'revision',
      'accepted',
      'published',
    ]);
  });
}
