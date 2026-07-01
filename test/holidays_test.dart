import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/holidays.dart';

void main() {
  bool has(List<Holiday> hs, DateTime d, String name) =>
      hs.any((h) => h.date == d && h.name == name);

  test('US federal holidays compute correctly for 2026', () {
    final hs = holidaysForYear(2026, 'us');
    expect(has(hs, DateTime(2026, 1, 1), "New Year's Day"), isTrue);
    expect(has(hs, DateTime(2026, 1, 19), 'Martin Luther King Jr. Day'),
        isTrue); // 3rd Mon Jan
    expect(has(hs, DateTime(2026, 7, 4), 'Independence Day'), isTrue);
    expect(has(hs, DateTime(2026, 11, 26), 'Thanksgiving'),
        isTrue); // 4th Thu Nov
    expect(has(hs, DateTime(2026, 12, 25), 'Christmas Day'), isTrue);
    // returned ascending by date
    for (var i = 1; i < hs.length; i++) {
      expect(hs[i].date.isBefore(hs[i - 1].date), isFalse);
    }
  });

  test("'none' has no holidays; Hawaiʻi adds state days on top of federal", () {
    expect(holidaysForYear(2026, 'none'), isEmpty);
    final hi = holidaysForYear(2026, 'us-hi');
    expect(has(hi, DateTime(2026, 6, 11), 'Kamehameha Day'), isTrue);
    expect(has(hi, DateTime(2026, 3, 26), 'Prince Kūhiō Day'), isTrue);
    expect(hi.any((h) => h.name == 'Independence Day'), isTrue); // federal kept
  });
}
