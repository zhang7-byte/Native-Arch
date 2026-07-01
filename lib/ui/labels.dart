import 'package:flutter/material.dart';

import '../data/database.dart';

/// Turns an enum constant name into a human label, e.g.
/// `manuscript_prep` -> "Manuscript prep".
String enumLabel(Enum value) {
  final words = value.name.split('_');
  return words
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

Color projectStatusColor(ProjectStatus status, ColorScheme scheme) {
  return switch (status) {
    ProjectStatus.planning => Colors.blueGrey,
    ProjectStatus.active => Colors.teal,
    ProjectStatus.manuscript_prep => Colors.indigo,
    ProjectStatus.under_review => Colors.orange,
    ProjectStatus.published => Colors.green,
    ProjectStatus.shelved => scheme.outline,
  };
}

Color experimentStatusColor(ExperimentStatus status, ColorScheme scheme) {
  return switch (status) {
    ExperimentStatus.planned => Colors.blueGrey,
    ExperimentStatus.running => Colors.teal,
    ExperimentStatus.done => Colors.green,
    ExperimentStatus.failed => Colors.red,
  };
}

Color taskStatusColor(TaskStatus status, ColorScheme scheme) {
  return switch (status) {
    TaskStatus.todo => Colors.blueGrey,
    TaskStatus.doing => Colors.teal,
    TaskStatus.done => Colors.green,
    TaskStatus.blocked => Colors.red,
  };
}

Color manuscriptStatusColor(ManuscriptStatus status, ColorScheme scheme) {
  return switch (status) {
    ManuscriptStatus.drafting => Colors.blueGrey,
    ManuscriptStatus.submitted => Colors.orange,
    ManuscriptStatus.revision => Colors.amber,
    ManuscriptStatus.accepted => Colors.teal,
    ManuscriptStatus.published => Colors.green,
  };
}

Color priorityColor(Priority priority, ColorScheme scheme) {
  return switch (priority) {
    Priority.low => scheme.outline,
    Priority.medium => Colors.orange,
    Priority.high => Colors.deepOrange,
  };
}

/// Whole days from [now] until [date] (date-only, local). Negative if past,
/// null if [date] is null. Pure, so the "expiring soon" flag is testable.
int? daysUntil(DateTime? date, DateTime now) {
  if (date == null) return null;
  final d = date.toLocal();
  return DateTime(d.year, d.month, d.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
}

/// Expiry classification for a reagent. "soon" means within 30 days (SPEC).
enum ExpiryState { none, expired, soon, ok }

ExpiryState expiryState(DateTime? expiry, DateTime now) {
  final days = daysUntil(expiry, now);
  if (days == null) return ExpiryState.none;
  if (days < 0) return ExpiryState.expired;
  if (days <= 30) return ExpiryState.soon;
  return ExpiryState.ok;
}

/// A short ISO date (yyyy-MM-dd) for display; null-safe.
String formatDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}';
}

/// Date + time to the minute (yyyy-MM-dd HH:mm) for display; null-safe.
String formatDateTime(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${formatDate(date)}  ${two(local.hour)}:${two(local.minute)}';
}

const _clockWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _clockMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// Friendly date for a live clock, e.g. "Wed 27 Jun 2026".
String clockDate(DateTime d) {
  final l = d.toLocal();
  return '${_clockWeekdays[l.weekday - 1]} ${l.day} '
      '${_clockMonths[l.month - 1]} ${l.year}';
}

/// Current time to the second, e.g. "12:25:30".
String clockTime(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
}
