import 'package:flutter/material.dart';

String cultureStatusLabel(String s) => switch (s) {
      'active' => 'Active',
      'terminated' => 'Terminated',
      'archived' => 'Archived',
      _ => s,
    };

Color cultureStatusColor(String s, ColorScheme scheme) => switch (s) {
      'active' => Colors.green,
      'terminated' => Colors.red,
      'archived' => Colors.blueGrey,
      _ => scheme.outline,
    };

/// The kinds of operation logged on a culture.
const cultureOpTypes = ['sampling', 'reagent', 'induction', 'measurement',
    'split', 'note'];

String cultureOpLabel(String t) => switch (t) {
      'sampling' => 'Sampling',
      'reagent' => 'Reagent added',
      'induction' => 'Induction',
      'measurement' => 'Measurement',
      'split' => 'Split',
      'note' => 'Note',
      _ => t,
    };

IconData cultureOpIcon(String t) => switch (t) {
      'sampling' => Icons.colorize_outlined,
      'reagent' => Icons.science_outlined,
      'induction' => Icons.bolt_outlined,
      'measurement' => Icons.show_chart,
      'split' => Icons.call_split,
      'note' => Icons.sticky_note_2_outlined,
      _ => Icons.circle_outlined,
    };

Color cultureOpColor(String t, ColorScheme scheme) => switch (t) {
      'sampling' => const Color(0xFF00897B),
      'reagent' => const Color(0xFF1E88E5),
      'induction' => const Color(0xFFFB8C00),
      'measurement' => const Color(0xFF8E24AA),
      'split' => const Color(0xFFC96442),
      'note' => scheme.onSurfaceVariant,
      _ => scheme.outline,
    };

/// A one-line summary of a logged operation from its parts.
String cultureOpSummary(
    {required String type,
    required String agent,
    required String amount,
    required String note}) {
  switch (type) {
    case 'sampling':
      return amount.isEmpty ? 'Sampling' : 'Sampled $amount';
    case 'reagent':
      final a = agent.isEmpty ? 'reagent' : agent;
      return amount.isEmpty ? 'Added $a' : 'Added $a ($amount)';
    case 'induction':
      final a = agent.isEmpty ? 'inducer' : agent;
      return amount.isEmpty ? 'Induced with $a' : 'Induced with $a ($amount)';
    case 'measurement':
      final a = agent.isEmpty ? 'Measurement' : agent;
      return amount.isEmpty ? a : '$a = $amount';
    case 'split':
      return note.isEmpty ? 'Split' : note;
    default:
      return note.isEmpty ? cultureOpLabel(type) : note;
  }
}
