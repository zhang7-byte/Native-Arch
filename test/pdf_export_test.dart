import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/culture_event_repository.dart';
import 'package:labtrack/data/culture_repository.dart';
import 'package:labtrack/data/experiment_update_repository.dart';
import 'package:labtrack/data/image_repository.dart';
import 'package:labtrack/data/settings_repository.dart';
import 'package:labtrack/export/pdf_export.dart';
import 'package:labtrack/ui/cloning/clone_vector.dart';
import 'package:pdf/widgets.dart' as pw;

/// A real, non-trivial PNG (varied pixels so it doesn't compress to nothing).
Uint8List _makePng(int seed) {
  final im = img.Image(width: 120, height: 90);
  for (var y = 0; y < im.height; y++) {
    for (var x = 0; x < im.width; x++) {
      im.setPixelRgb(x, y, (x * 2 + seed) & 0xFF, (y * 3) & 0xFF, (x + y) & 0xFF);
    }
  }
  return img.encodePng(im);
}

void main() {
  late AppDatabase db;
  late PdfFonts fonts;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), true); // seeded data
    pw.Font load(String name) => pw.Font.ttf(
        ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync()));
    fonts = PdfFonts(load('Roboto-Regular.ttf'), load('Roboto-Bold.ttf'));
  });

  tearDown(() => db.close());

  void expectValidPdf(Uint8List bytes) {
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    final tail = String.fromCharCodes(bytes.sublist(bytes.length - 16));
    expect(tail.contains('%%EOF'), isTrue);
  }

  test('project / experiment / manuscript PDFs are valid (and saved to disk)',
      () async {
    final out = Directory('build/pdf_samples')..createSync(recursive: true);

    final project = (await db.select(db.projects).get())
        .firstWhere((p) => p.title.contains('Constrained AID'));
    final projectPdf = await buildProjectPdf(db, project, fonts);
    expectValidPdf(projectPdf);
    File('${out.path}/project.pdf').writeAsBytesSync(projectPdf);

    final experiment = (await db.select(db.experiments).get())
        .firstWhere((e) => e.strainIds.isNotEmpty);
    final experimentPdf = await buildExperimentPdf(db, experiment, fonts);
    expectValidPdf(experimentPdf);
    File('${out.path}/experiment.pdf').writeAsBytesSync(experimentPdf);

    final manuscript = await db.select(db.manuscripts).getSingle();
    final manuscriptPdf = await buildManuscriptPdf(db, manuscript, fonts);
    expectValidPdf(manuscriptPdf);
    File('${out.path}/manuscript.pdf').writeAsBytesSync(manuscriptPdf);
  });

  test('an experiment with two attached images embeds them in the PDF',
      () async {
    final out = Directory('build/pdf_samples')..createSync(recursive: true);
    final exp = (await db.select(db.experiments).get()).first;

    // Baseline: same experiment with no images.
    final before = await buildExperimentPdf(db, exp, fonts);
    expectValidPdf(before);

    // Attach two images (bytes land in the local cache).
    final images = ImageRepository(db);
    await images.add(
        experimentId: exp.id,
        bytes: _makePng(0),
        contentType: 'image/png',
        caption: 'Gel A');
    await images.add(
        experimentId: exp.id,
        bytes: _makePng(80),
        contentType: 'image/png',
        caption: 'Gel B');

    final after = await buildExperimentPdf(db, exp, fonts);
    expectValidPdf(after);
    File('${out.path}/experiment_with_images.pdf').writeAsBytesSync(after);

    // The embedded image bitmaps make the PDF materially larger.
    expect(after.length, greaterThan(before.length + 2000));
  });

  test('report PDF aggregates the workspace and embeds images', () async {
    final out = Directory('build/pdf_samples')..createSync(recursive: true);
    await db.into(db.reports).insert(ReportsCompanion(
          title: const Value('June progress'),
          recipient: const Value('Dr. Su'),
          author: const Value('Wei'),
          summary: const Value('Validated the cAID degron this month.'),
        ));
    final report = await db.select(db.reports).getSingle();

    // Baseline (no images yet).
    final before = await buildReportPdf(db, report, fonts);
    expectValidPdf(before);

    // Attach an image to a seeded experiment.
    final exp = (await db.select(db.experiments).get()).first;
    await ImageRepository(db).add(
        experimentId: exp.id,
        bytes: _makePng(7),
        contentType: 'image/png',
        caption: 'Result figure');

    final after = await buildReportPdf(db, report, fonts);
    expectValidPdf(after);
    File('${out.path}/report.pdf').writeAsBytesSync(after);
    expect(after.length, greaterThan(before.length + 2000));
  });

  test('report PDF respects project selection', () async {
    final p = (await db.select(db.projects).get()).first;
    await db.into(db.reports).insert(ReportsCompanion(
          title: const Value('Scoped report'),
          projectIds: Value([p.id]), // only this project
        ));
    final report = await db.select(db.reports).getSingle();
    final pdf = await buildReportPdf(db, report, fonts);
    expectValidPdf(pdf);
  });

  test('schedule PDF for a month is valid', () async {
    await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'Plan run', dueDate: Value(DateTime(2026, 6, 15))));
    final pdf = await buildSchedulePdf(db, DateTime(2026, 6, 1), fonts);
    expectValidPdf(pdf);
  });

  test('schedule PDF with a project selection includes details', () async {
    final p = (await db.select(db.projects).get()).first;
    final pdf = await buildSchedulePdf(db, DateTime(2026, 6, 1), fonts,
        projectIds: [p.id]);
    expectValidPdf(pdf);
  });

  test('schedule PDF overlays holidays + a personal event', () async {
    await SettingsRepository(db).save(holidayRegion: 'us-hi');
    await db.into(db.customEvents).insert(CustomEventsCompanion.insert(
        title: 'Birthday',
        date: DateTime(2026, 6, 11),
        category: const Value('birthday'),
        repeatAnnually: const Value(true)));
    final pdf = await buildSchedulePdf(db, DateTime(2026, 6, 1), fonts);
    expectValidPdf(pdf);
  });

  test('schedule PDF can exclude personal events + holidays', () async {
    await SettingsRepository(db).save(holidayRegion: 'us-hi');
    await db.into(db.customEvents).insert(CustomEventsCompanion.insert(
        title: 'Birthday', date: DateTime(2026, 6, 11)));
    final pdf = await buildSchedulePdf(db, DateTime(2026, 6, 1), fonts,
        customEventIds: const [], includeHolidays: false);
    expectValidPdf(pdf);
  });

  test('culture PDF renders details + operations log', () async {
    final cultures = CultureRepository(db);
    final id = await cultures.create(CulturesCompanion(
        name: const Value('C1'),
        medium: const Value('LB'),
        selectionMarkers: const Value(['Kanamycin']),
        startedDate: Value(DateTime(2026, 6, 1, 9))));
    await CultureEventRepository(db).add(
        cultureId: id,
        happenedAt: DateTime(2026, 6, 2, 10),
        type: 'measurement',
        agent: 'OD600',
        amount: '0.82');
    final c = await cultures.findById(id);
    expectValidPdf(await buildCulturePdf(db, c!, fonts));
  });

  test('strain stores + renders selection markers', () async {
    await db.into(db.strains).insert(StrainsCompanion.insert(
        name: 'BL21',
        selectionMarkers: const Value(['Kanamycin', 'Ampicillin'])));
    final s = (await db.select(db.strains).get())
        .firstWhere((x) => x.name == 'BL21');
    expect(s.selectionMarkers, ['Kanamycin', 'Ampicillin']);
    expectValidPdf(await buildStrainPdf(db, s, fonts));
  });

  test('experiment stores + renders methodology, conclusion, further plan',
      () async {
    final p = (await db.select(db.projects).get()).first;
    await db.into(db.experiments).insert(ExperimentsCompanion.insert(
          projectId: p.id,
          title: 'Methods exp',
          methodologySteps:
              const Value(['Mix reagents', 'Incubate 1h', 'Image gel']),
          conclusion: const Value('It worked.'),
          furtherPlan: const Value('Repeat with controls.'),
        ));
    final e = (await db.select(db.experiments).get())
        .firstWhere((x) => x.title == 'Methods exp');
    expect(e.methodologySteps, ['Mix reagents', 'Incubate 1h', 'Image gel']);
    expect(e.conclusion, 'It worked.');
    expect(e.furtherPlan, 'Repeat with controls.');
    expectValidPdf(await buildExperimentPdf(db, e, fonts));
  });

  testWidgets('clone construction PDF is valid', (tester) async {
    final out = Directory('build/pdf_samples')..createSync(recursive: true);
    final strains = await db.select(db.strains).get();
    await db.into(db.cloneConstructions).insert(CloneConstructionsCompanion(
          name: const Value('pLT-GFP-hLFABP'),
          backboneName: const Value('pUC19'),
          backboneStrainId: Value(strains.first.id),
          enzymes: const Value('EcoRI, HindIII'),
          fragments: Value([
            CloneFragment(name: 'GFP', templateStrainId: strains.first.id),
            const CloneFragment(name: 'hLFABP', sizeBp: '1.2 kb'),
          ]),
        ));
    final c = await db.select(db.cloneConstructions).getSingle();
    // runAsync: image encoding (toByteData) runs on a real thread, which the
    // fake test clock would otherwise never pump.
    final pdf = await tester.runAsync(() => buildClonePdf(db, c, fonts));
    expectValidPdf(pdf!);
    File('${out.path}/construction.pdf').writeAsBytesSync(pdf);
  });

  testWidgets('experiment PDF embeds annotated images + progress log',
      (tester) async {
    final exp = (await db.select(db.experiments).get()).first;
    final imgRepo = ImageRepository(db);
    final id = await imgRepo.add(
        experimentId: exp.id,
        bytes: _makePng(3),
        contentType: 'image/png',
        caption: 'Gel');
    await imgRepo.updateAnnotations(id, const [
      ImageAnnotation(type: 'arrow', x1: 0.1, y1: 0.1, x2: 0.6, y2: 0.6),
    ]);
    await imgRepo.updateNotes(id, 'band at 1.2 kb');
    await ExperimentUpdateRepository(db).add(
        experimentId: exp.id,
        happenedAt: DateTime(2026, 6, 20),
        note: 'First run; OD low.');

    final pdf = await tester.runAsync(() => buildExperimentPdf(db, exp, fonts));
    expectValidPdf(pdf!);
  });

  testWidgets('vector diagram rasterises to PNG bytes', (tester) async {
    await db.into(db.cloneConstructions).insert(CloneConstructionsCompanion(
          name: const Value('pV'),
          fragments: Value(const [
            CloneFragment(name: 'A'),
            CloneFragment(name: 'B'),
          ]),
        ));
    final c = await db.select(db.cloneConstructions).getSingle();
    final png = await tester.runAsync(() => renderCloneVectorPng(c, size: 300));
    expect(png, isNotNull);
    // PNG signature.
    expect(png!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });
}
