import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/csv_import.dart';
import 'package:labtrack/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<ImportSummary> import(ImportEntity entity, String content) {
    final csv = parseCsv(content);
    return runImport(db, entity, csv, autoMapping(csv.headers, entity));
  }

  test('strains: import inserts, re-import updates in place (no duplicates)',
      () async {
    const csv = 'name,host_organism,plasmid\n'
        'S1,Yarrowia lipolytica,p1\n'
        'S2,E. coli,p2\n';
    final first = await import(ImportEntity.strain, csv);
    expect(first.inserted, 2);
    expect(first.updated, 0);
    expect(await db.select(db.strains).get(), hasLength(2));

    // Re-import the "same file", with one field edited.
    const csv2 = 'name,host_organism,plasmid\n'
        'S1,Yarrowia lipolytica,pEDITED\n'
        'S2,E. coli,p2\n';
    final second = await import(ImportEntity.strain, csv2);
    expect(second.inserted, 0); // matched by name -> no new rows
    expect(second.updated, 2);
    expect(await db.select(db.strains).get(), hasLength(2)); // still 2

    final s1 = (await db.select(db.strains).get())
        .firstWhere((s) => s.name == 'S1');
    expect(s1.plasmid, 'pEDITED'); // updated in place
  });

  test('serial_number imports for strains and primers + is in templates',
      () async {
    await import(
        ImportEntity.strain, 'name,serial_number,host_organism\nS1,SU-S001,Yl\n');
    expect((await db.select(db.strains).getSingle()).serialNumber, 'SU-S001');

    await import(
        ImportEntity.primer, 'name,serial_number,sequence\nP1,SU-P001,ACGT\n');
    expect((await db.select(db.primers).getSingle()).serialNumber, 'SU-P001');

    expect(sampleCsv(ImportEntity.strain).split('\n').first,
        contains('serial_number'));
    expect(sampleCsv(ImportEntity.primer).split('\n').first,
        contains('serial_number'));
  });

  test('reagents: upsert matches on catalog_no + lot', () async {
    const csv = 'name,catalog_no,lot,expiry_date\n'
        'Auxin,I2886,LOT1,2026-12-31\n';
    expect((await import(ImportEntity.reagent, csv)).inserted, 1);

    // Same catalog_no + lot, different name -> update (not duplicate).
    const sameKey = 'name,catalog_no,lot,expiry_date\n'
        'Auxin (IAA),I2886,LOT1,2026-12-31\n';
    final r2 = await import(ImportEntity.reagent, sameKey);
    expect(r2.updated, 1);
    expect(r2.inserted, 0);
    expect(await db.select(db.reagents).get(), hasLength(1));

    // Different lot -> a new row.
    const newLot = 'name,catalog_no,lot,expiry_date\n'
        'Auxin,I2886,LOT2,2026-12-31\n';
    expect((await import(ImportEntity.reagent, newLot)).inserted, 1);
    expect(await db.select(db.reagents).get(), hasLength(2));
  });

  test('validation: missing required fields and bad dates are skipped',
      () async {
    const strains = 'name,host_organism\n'
        ',Yarrowia\n' // missing name -> skipped
        'Good,E. coli\n';
    final s = await import(ImportEntity.strain, strains);
    expect(s.inserted, 1);
    expect(s.skipped, 1);

    const reagents = 'name,catalog_no,lot,expiry_date\n'
        'Bad,C1,L1,not-a-date\n' // bad date -> skipped
        'OK,C2,L2,2026-01-01\n';
    final r = await import(ImportEntity.reagent, reagents);
    expect(r.inserted, 1);
    expect(r.skipped, 1);
  });

  test('real sample files import, and re-importing updates (no duplicates)',
      () async {
    final strainsCsv = File('sample_data/strains.csv').readAsStringSync();
    expect((await import(ImportEntity.strain, strainsCsv)).inserted, 3);
    expect(await db.select(db.strains).get(), hasLength(3));
    final reStrains = await import(ImportEntity.strain, strainsCsv);
    expect(reStrains.inserted, 0);
    expect(reStrains.updated, 3);
    expect(await db.select(db.strains).get(), hasLength(3)); // no duplicates

    final reagentsCsv = File('sample_data/reagents.csv').readAsStringSync();
    expect((await import(ImportEntity.reagent, reagentsCsv)).inserted, 3);
    final reReagents = await import(ImportEntity.reagent, reagentsCsv);
    expect(reReagents.inserted, 0);
    expect(reReagents.updated, 3);
    expect(await db.select(db.reagents).get(), hasLength(3)); // no duplicates
  });

  test('expiry date parses to the right calendar day', () async {
    const csv = 'name,catalog_no,lot,expiry_date\n'
        'R,C,L,2026-07-15\n';
    await import(ImportEntity.reagent, csv);
    final r = await db.select(db.reagents).getSingle();
    final d = r.expiryDate!.toLocal();
    expect([d.year, d.month, d.day], [2026, 7, 15]);
  });
}
