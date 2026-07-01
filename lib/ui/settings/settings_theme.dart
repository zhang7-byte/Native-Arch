import 'package:flutter/material.dart';

/// Accent (seed) colours offered in the picker.
const accentPalette = <int>[
  0xFFC96442, // terracotta (default)
  0xFF009688, // teal
  0xFF1976D2, // blue
  0xFF6750A4, // purple
  0xFF2E7D32, // green
  0xFFD81B60, // pink
  0xFFF4511E, // deep orange
  0xFF5D4037, // brown
  0xFF455A64, // blue grey
];

/// Solid background colours offered in the picker.
const backgroundPalette = <int>[
  0xFF0F2027, // deep teal
  0xFF1A237E, // indigo
  0xFF311B92, // deep purple
  0xFF004D40, // dark green
  0xFF3E2723, // espresso
  0xFF263238, // blue grey
  0xFFECEFF1, // light grey
  0xFFFFF8E1, // cream
];

/// Gradient endpoint pairs (start, end) for the gradient background.
const gradientPresets = <(int, int)>[
  (0xFF0F2027, 0xFF2C5364), // teal night
  (0xFF42275A, 0xFF734B6D), // plum
  (0xFF1A2980, 0xFF26D0CE), // ocean
  (0xFF232526, 0xFF414345), // graphite
  (0xFFFFB75E, 0xFFED8F03), // amber
  (0xFF8E9EAB, 0xFFEEF2F3), // mist (light)
];

ThemeMode themeModeFromString(String s) => switch (s) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

VisualDensity densityFromString(String s) =>
    s == 'compact' ? VisualDensity.compact : VisualDensity.standard;
