import 'database.dart';
import 'holidays.dart';

/// The kinds of dated content shown on the Schedule calendar.
enum ScheduleKind {
  task,
  experiment,
  projectStart,
  projectTarget,
  manuscript,
  culture,
  reagentExpiry,
  birthday,
  personal,
  holiday,
}

extension ScheduleKindLabel on ScheduleKind {
  String get label => switch (this) {
        ScheduleKind.task => 'Task due',
        ScheduleKind.experiment => 'Experiment',
        ScheduleKind.projectStart => 'Project start',
        ScheduleKind.projectTarget => 'Project target',
        ScheduleKind.manuscript => 'Manuscript',
        ScheduleKind.culture => 'Culture started',
        ScheduleKind.reagentExpiry => 'Reagent expires',
        ScheduleKind.birthday => 'Birthday',
        ScheduleKind.personal => 'Event',
        ScheduleKind.holiday => 'Holiday',
      };
}

/// A single dated item placed on a calendar day. [entityId] points back at the
/// source row so the UI can navigate to it.
class ScheduleEvent {
  ScheduleEvent({
    required this.date,
    required this.title,
    required this.kind,
    required this.entityId,
  });

  final DateTime date; // local, date-only
  final String title;
  final ScheduleKind kind;
  final String entityId;
}

DateTime _dayOf(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// Aggregates every dated entity into a flat, date-sorted list of calendar
/// events. Pure, so the calendar and its PDF stay in sync and are testable.
List<ScheduleEvent> buildSchedule({
  required List<Task> tasks,
  required List<Experiment> experiments,
  required List<Project> projects,
  required List<Manuscript> manuscripts,
  required List<Culture> cultures,
  required List<Reagent> reagents,
}) {
  final events = <ScheduleEvent>[];
  for (final t in tasks) {
    if (t.dueDate != null) {
      events.add(ScheduleEvent(
          date: _dayOf(t.dueDate!),
          title: t.title,
          kind: ScheduleKind.task,
          entityId: t.id));
    }
  }
  for (final e in experiments) {
    if (e.date != null) {
      events.add(ScheduleEvent(
          date: _dayOf(e.date!),
          title: e.title,
          kind: ScheduleKind.experiment,
          entityId: e.id));
    }
  }
  for (final p in projects) {
    if (p.startDate != null) {
      events.add(ScheduleEvent(
          date: _dayOf(p.startDate!),
          title: p.title,
          kind: ScheduleKind.projectStart,
          entityId: p.id));
    }
    if (p.targetDate != null) {
      events.add(ScheduleEvent(
          date: _dayOf(p.targetDate!),
          title: p.title,
          kind: ScheduleKind.projectTarget,
          entityId: p.id));
    }
  }
  for (final m in manuscripts) {
    if (m.submittedDate != null) {
      events.add(ScheduleEvent(
          date: _dayOf(m.submittedDate!),
          title: m.title,
          kind: ScheduleKind.manuscript,
          entityId: m.id));
    }
  }
  for (final c in cultures) {
    events.add(ScheduleEvent(
        date: _dayOf(c.startedDate),
        title: c.name.isEmpty ? '(culture)' : c.name,
        kind: ScheduleKind.culture,
        entityId: c.id));
  }
  for (final r in reagents) {
    if (r.expiryDate != null) {
      events.add(ScheduleEvent(
          date: _dayOf(r.expiryDate!),
          title: r.name,
          kind: ScheduleKind.reagentExpiry,
          entityId: r.id));
    }
  }
  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
}

/// Expands user [events] into concrete calendar occurrences across [years]
/// (annual ones repeat each year on the same month/day; others appear once).
List<ScheduleEvent> customEventOccurrences(
    List<CustomEvent> events, Iterable<int> years) {
  final out = <ScheduleEvent>[];
  for (final e in events) {
    final kind = e.category == 'birthday'
        ? ScheduleKind.birthday
        : ScheduleKind.personal;
    if (e.repeatAnnually) {
      for (final y in years) {
        out.add(ScheduleEvent(
            date: DateTime(y, e.date.month, e.date.day),
            title: e.title,
            kind: kind,
            entityId: e.id));
      }
    } else {
      out.add(ScheduleEvent(
          date: _dayOf(e.date),
          title: e.title,
          kind: kind,
          entityId: e.id));
    }
  }
  return out;
}

/// Calendar events for the holidays in [region] across [years].
List<ScheduleEvent> holidayOccurrences(Iterable<int> years, String region) => [
      for (final y in years)
        for (final h in holidaysForYear(y, region))
          ScheduleEvent(
              date: DateTime(h.date.year, h.date.month, h.date.day),
              title: h.name,
              kind: ScheduleKind.holiday,
              entityId: '')
    ];

/// Groups events by their (date-only) day.
Map<DateTime, List<ScheduleEvent>> groupByDay(List<ScheduleEvent> events) {
  final map = <DateTime, List<ScheduleEvent>>{};
  for (final e in events) {
    (map[e.date] ??= []).add(e);
  }
  return map;
}

/// The 7×N grid of days to render for the month containing [monthStart],
/// padded with the trailing days of the previous month and leading days of the
/// next so each week is full. Weeks start on Monday.
List<DateTime> monthCells(DateTime monthStart) {
  final first = DateTime(monthStart.year, monthStart.month, 1);
  final leading = first.weekday - 1; // Monday=1 → 0 leading
  final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
  final rows = ((leading + daysInMonth) / 7).ceil();
  // Build with the DateTime constructor (not Duration arithmetic) so every cell
  // is an exact local midnight — no DST drift, so day-equality lookups work.
  return [
    for (var i = 0; i < rows * 7; i++)
      DateTime(first.year, first.month, first.day - leading + i)
  ];
}

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December'
];

String monthName(int month) => _monthNames[(month - 1) % 12];

const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
