/// A public holiday on a specific date.
class Holiday {
  const Holiday(this.date, this.name);
  final DateTime date; // local, date-only (midnight)
  final String name;
}

/// Selectable holiday calendars. The value is stored in app_settings.
const holidayRegions = <(String, String)>[
  ('none', 'None'),
  ('us', 'United States — federal'),
  ('us-hi', "United States — Hawaiʻi"),
  ('us-ca', 'United States — California'),
  ('us-ny', 'United States — New York'),
];

String holidayRegionLabel(String code) {
  for (final (c, label) in holidayRegions) {
    if (c == code) return label;
  }
  return 'None';
}

/// The nth [weekday] (DateTime.monday..sunday) of [month] in [year].
DateTime _nth(int year, int month, int weekday, int n) {
  final first = DateTime(year, month, 1);
  var offset = (weekday - first.weekday) % 7;
  if (offset < 0) offset += 7;
  return DateTime(year, month, 1 + offset + (n - 1) * 7);
}

/// The last [weekday] of [month] in [year].
DateTime _last(int year, int month, int weekday) {
  final lastDay = DateTime(year, month + 1, 0); // day 0 of next month
  var offset = (lastDay.weekday - weekday) % 7;
  if (offset < 0) offset += 7;
  return DateTime(year, month, lastDay.day - offset);
}

/// Gregorian Easter Sunday (Anonymous Computus).
DateTime _easter(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

List<Holiday> _federal(int year) => [
      Holiday(DateTime(year, 1, 1), "New Year's Day"),
      Holiday(_nth(year, 1, DateTime.monday, 3), 'Martin Luther King Jr. Day'),
      Holiday(_nth(year, 2, DateTime.monday, 3), "Presidents' Day"),
      Holiday(_last(year, 5, DateTime.monday), 'Memorial Day'),
      Holiday(DateTime(year, 6, 19), 'Juneteenth'),
      Holiday(DateTime(year, 7, 4), 'Independence Day'),
      Holiday(_nth(year, 9, DateTime.monday, 1), 'Labor Day'),
      Holiday(_nth(year, 10, DateTime.monday, 2), 'Columbus Day'),
      Holiday(DateTime(year, 11, 11), 'Veterans Day'),
      Holiday(_nth(year, 11, DateTime.thursday, 4), 'Thanksgiving'),
      Holiday(DateTime(year, 12, 25), 'Christmas Day'),
    ];

List<Holiday> _hawaii(int year) {
  final easter = _easter(year);
  return [
    Holiday(DateTime(year, 3, 26), "Prince Kūhiō Day"),
    Holiday(DateTime(easter.year, easter.month, easter.day - 2), 'Good Friday'),
    Holiday(DateTime(year, 6, 11), 'Kamehameha Day'),
    Holiday(_nth(year, 8, DateTime.friday, 3), 'Statehood Day'),
  ];
}

List<Holiday> _california(int year) => [
      Holiday(DateTime(year, 3, 31), 'César Chávez Day'),
      Holiday(
          DateTime(_nth(year, 11, DateTime.thursday, 4).year,
              11, _nth(year, 11, DateTime.thursday, 4).day + 1),
          'Day after Thanksgiving'),
    ];

List<Holiday> _newYork(int year) => [
      Holiday(DateTime(year, 2, 12), "Lincoln's Birthday"),
      // Election Day: first Tuesday after the first Monday in November.
      Holiday(
          _nth(year, 11, DateTime.monday, 1).add(const Duration(days: 1)),
          'Election Day'),
    ];

/// Public holidays for [year] under [region] (federal + the state's extras).
List<Holiday> holidaysForYear(int year, String region) {
  if (region == 'none') return const [];
  final list = [..._federal(year)];
  switch (region) {
    case 'us-hi':
      list.addAll(_hawaii(year));
    case 'us-ca':
      list.addAll(_california(year));
    case 'us-ny':
      list.addAll(_newYork(year));
  }
  list.sort((a, b) => a.date.compareTo(b.date));
  return list;
}
