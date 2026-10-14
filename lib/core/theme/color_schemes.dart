import 'package:flutter/material.dart';

/// Evergreen & Brass colour roles, from docs/design/output/design-system.md.
/// Seeded from Evergreen and then every role set explicitly so the result
/// does not drift between Flutter versions.
const Color evergreenSeed = Color(0xFF1E4D3B);

final ColorScheme lightColorScheme =
    ColorScheme.fromSeed(
      seedColor: evergreenSeed,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1E4D3B),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFCFE5D8),
      onPrimaryContainer: const Color(0xFF0B2A1F),
      secondary: const Color(0xFF52635A),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFD7E5DC),
      onSecondaryContainer: const Color(0xFF102019),
      tertiary: const Color(0xFF8A6414),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFF5E4BC),
      onTertiaryContainer: const Color(0xFF3B2A00),
      error: const Color(0xFFA3263A),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFADCDF),
      onErrorContainer: const Color(0xFF5C0E1C),
      surface: const Color(0xFFFBFAF7),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF5F3EE),
      surfaceContainer: const Color(0xFFEFECE6),
      surfaceContainerHigh: const Color(0xFFE8E5DE),
      surfaceContainerHighest: const Color(0xFFE1DED6),
      onSurface: const Color(0xFF1B1F1C),
      onSurfaceVariant: const Color(0xFF4A524D),
      outline: const Color(0xFF78807A),
      outlineVariant: const Color(0xFFD4D6CF),
      inverseSurface: const Color(0xFF2E3330),
      onInverseSurface: const Color(0xFFEFF1EC),
      inversePrimary: const Color(0xFF94D2B2),
    );

final ColorScheme darkColorScheme =
    ColorScheme.fromSeed(
      seedColor: evergreenSeed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF94D2B2),
      onPrimary: const Color(0xFF00382A),
      primaryContainer: const Color(0xFF1F4D3B),
      onPrimaryContainer: const Color(0xFFC9EEDA),
      secondary: const Color(0xFFB8CCC0),
      onSecondary: const Color(0xFF23352C),
      secondaryContainer: const Color(0xFF33463C),
      onSecondaryContainer: const Color(0xFFD4E8DC),
      tertiary: const Color(0xFFE6C47C),
      onTertiary: const Color(0xFF3F2E00),
      tertiaryContainer: const Color(0xFF5B4407),
      onTertiaryContainer: const Color(0xFFFDE3A8),
      error: const Color(0xFFFFB1B8),
      onError: const Color(0xFF67001B),
      errorContainer: const Color(0xFF8A1D32),
      onErrorContainer: const Color(0xFFFFDADC),
      surface: const Color(0xFF0F1512),
      surfaceContainerLowest: const Color(0xFF0A100D),
      surfaceContainerLow: const Color(0xFF151C18),
      surfaceContainer: const Color(0xFF19211D),
      surfaceContainerHigh: const Color(0xFF212A25),
      surfaceContainerHighest: const Color(0xFF2A342F),
      onSurface: const Color(0xFFE4E9E4),
      onSurfaceVariant: const Color(0xFFB4BEB7),
      outline: const Color(0xFF87918A),
      outlineVariant: const Color(0xFF38433D),
      inverseSurface: const Color(0xFFE1E4DF),
      onInverseSurface: const Color(0xFF2C322E),
      inversePrimary: const Color(0xFF1E4D3B),
    );
