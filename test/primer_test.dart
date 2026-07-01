import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/csv_import.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/primer_repository.dart';

const _csv = 'name,sequence,target_gene,direction,tm\n'
    'pUSP7-F,ATGCATGCATGCATGCATGC,USP7,forward,58\n'
    'pUSP7-R,GGCCGGCCGGCCGGCC,USP7,reverse,60\n';

Future<ImportSummary> _import(AppDatabase db) async {
  final parsed = parseCsv(_csv);
  final mapping = autoMapping(parsed.headers, ImportEntity.primer);
  return runImport(db, ImportEntity.primer, parsed, mapping);
}

void main() {
  test('primer CSV imports, shows sequence length, and re-import updates '
      'instead of duplicating', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = PrimerRepository(db);

    final first = await _import(db);
    expect(first.inserted, 2);
    expect(first.updated, 0);
    expect(first.skipped, 0);

    var primers = await repo.watchAll().first;
    expect(primers.length, 2);
    final f = primers.firstWhere((p) => p.name == 'pUSP7-F');
    expect(f.sequence, 'ATGCATGCATGCATGCATGC');
    expect(f.targetGene, 'USP7');
    expect(f.direction, 'forward');
    expect(f.sequence.length, 20); // length derivable for display

    // Re-import the SAME file: existing primers update, nothing duplicates.
    final second = await _import(db);
    expect(second.inserted, 0);
    expect(second.updated, 2);
    primers = await repo.watchAll().first;
    expect(primers.length, 2); // still two
  });
}
