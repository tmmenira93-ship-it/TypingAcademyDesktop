import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF2563EB);
  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);

  /// Font used for the text being typed. 'monospace' alone is not a real family
  /// on Windows, so name real fonts first and keep the generic one as last resort.
  static const String monoFamily = 'Consolas';
  static const List<String> monoFallback = [
    'Menlo',
    'DejaVu Sans Mono',
    'Liberation Mono',
    'Courier New',
    'monospace',
  ];

  static const List<String> _uiFallback = [
    'Segoe UI',
    'Noto Sans Arabic',
    'Tahoma',
    'Arial',
  ];

  static ThemeData light() => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(seedColor: const Color(0xFF60A5FA), brightness: Brightness.dark),
      );

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      fontFamilyFallback: _uiFallback,
      appBarTheme: const AppBarTheme(centerTitle: false),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: scheme.primaryContainer,
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
