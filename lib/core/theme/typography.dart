import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Newsreader for titles and the ordering date, Public Sans for everything
/// read or added up. Sizes from docs/design/output/design-system.md.
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

TextStyle _display({
  required double size,
  required double height,
  FontWeight weight = FontWeight.w500,
}) => GoogleFonts.newsreader(
  fontSize: size,
  height: height / size,
  fontWeight: weight,
);

TextStyle _text({
  required double size,
  required double height,
  FontWeight weight = FontWeight.w400,
  double? letterSpacing,
  bool tabular = false,
}) => GoogleFonts.publicSans(
  fontSize: size,
  height: height / size,
  fontWeight: weight,
  letterSpacing: letterSpacing,
  fontFeatures: tabular ? tabularFigures : null,
);

TextTheme buildTextTheme({required bool laptop}) => TextTheme(
  displaySmall: _display(size: laptop ? 44 : 32, height: laptop ? 52 : 40),
  headlineMedium: _display(size: laptop ? 32 : 28, height: laptop ? 40 : 36),
  headlineSmall: _display(size: 24, height: 32),
  titleLarge: _display(size: 22, height: 28),
  titleMedium: _text(size: 16, height: 24, weight: FontWeight.w600),
  bodyLarge: _text(size: 16, height: 24),
  bodyMedium: _text(size: 14, height: 20, tabular: true),
  bodySmall: _text(size: 12, height: 16, tabular: true),
  labelLarge: _text(size: 15, height: 20, weight: FontWeight.w600),
  labelMedium: _text(size: 12, height: 16, weight: FontWeight.w700),
  labelSmall: _text(size: 11, height: 16, weight: FontWeight.w600),
);

/// Remaining on detail headers.
TextStyle moneyLargeStyle() => _text(
  size: 40,
  height: 48,
  weight: FontWeight.w600,
  letterSpacing: -0.8,
  tabular: true,
);

/// Remaining on Home.
TextStyle moneyHomeStyle() => _text(
  size: 36,
  height: 44,
  weight: FontWeight.w600,
  letterSpacing: -0.72,
  tabular: true,
);

/// Any amount in running text: the current style with tabular figures.
TextStyle tabular(TextStyle? base) =>
    (base ?? const TextStyle()).copyWith(fontFeatures: tabularFigures);
