import 'package:christmas_planner/core/theme/app_theme.dart';
import 'package:christmas_planner/core/theme/season_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('light scheme carries the Evergreen & Brass roles', (
    tester,
  ) async {
    final t = buildTheme(brightness: Brightness.light);
    expect(t.colorScheme.primary, const Color(0xFF1E4D3B));
    expect(t.colorScheme.tertiary, const Color(0xFF8A6414));
    expect(t.colorScheme.error, const Color(0xFFA3263A));
    expect(t.colorScheme.surface, const Color(0xFFFBFAF7));
    expect(t.scaffoldBackgroundColor, const Color(0xFFFBFAF7));
  });

  testWidgets('dark scheme is designed, not inverted', (tester) async {
    final t = buildTheme(brightness: Brightness.dark);
    expect(t.colorScheme.primary, const Color(0xFF94D2B2));
    expect(t.colorScheme.error, const Color(0xFFFFB1B8));
    expect(t.colorScheme.surface, const Color(0xFF0F1512));
  });

  testWidgets('the season extension resolves in both themes', (tester) async {
    for (final b in Brightness.values) {
      final season = buildTheme(brightness: b).extension<SeasonTheme>();
      expect(season, isNotNull);
      expect(
        season!.moneyLarge.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    }
    final light = buildTheme(
      brightness: Brightness.light,
    ).extension<SeasonTheme>()!;
    expect(light.ribbon, const Color(0xFFC9A14C));
    expect(light.alertSurface, const Color(0xFF8E1F33));
  });

  testWidgets('money text uses tabular figures', (tester) async {
    final t = buildTheme(brightness: Brightness.light);
    expect(
      t.textTheme.bodyMedium!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
