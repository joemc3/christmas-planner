import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'season_theme.dart';
import 'typography.dart';

/// Spacing scale from the design system.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii from the design system.
abstract final class Radii {
  static const double field = 12;
  static const double tag = 12;
  static const double stepper = 22;
  static const double hero = 24;
  static const double sheet = 28;
}

/// Motion from the design system: state changes and the bar easing.
abstract final class Motion {
  static const Duration state = Duration(milliseconds: 200);
  static const Duration bar = Duration(milliseconds: 300);
  static const Curve curve = Curves.easeInOut;
}

ThemeData buildTheme({required Brightness brightness, bool laptop = false}) {
  final light = brightness == Brightness.light;
  final scheme = light ? lightColorScheme : darkColorScheme;
  final text = buildTextTheme(
    laptop: laptop,
  ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  final season = light
      ? SeasonTheme(
          heroSurface: const Color(0xFF1E4D3B),
          onHero: const Color(0xFFF4F1E8),
          heroMuted: const Color(0xFFBFD6C9),
          alertSurface: const Color(0xFF8E1F33),
          onAlert: const Color(0xFFFFF4F4),
          alertMuted: const Color(0xFFF6CDD3),
          ribbon: const Color(0xFFC9A14C),
          ribbonEdge: const Color(0xFFA68337),
          moneyLarge: moneyLargeStyle().copyWith(color: scheme.onSurface),
          moneyHome: moneyHomeStyle().copyWith(color: scheme.onSurface),
        )
      : SeasonTheme(
          heroSurface: const Color(0xFF1F4D3B),
          onHero: const Color(0xFFF1EEE4),
          heroMuted: const Color(0xFFB5CDBF),
          alertSurface: const Color(0xFF8A1D32),
          onAlert: const Color(0xFFFFF1F2),
          alertMuted: const Color(0xFFF3C6CC),
          ribbon: const Color(0xFFB8924A),
          ribbonEdge: const Color(0xFF8C6C2E),
          moneyLarge: moneyLargeStyle().copyWith(color: scheme.onSurface),
          moneyHome: moneyHomeStyle().copyWith(color: scheme.onSurface),
        );

  final fieldFill = light ? Colors.white : scheme.surface;
  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
  final buttonHeight = laptop ? 44.0 : 48.0;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text,
    extensions: [season],
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.headlineMedium,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size(64, buttonHeight),
        shape: pill,
        textStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(64, buttonHeight),
        shape: pill,
        side: BorderSide(color: scheme.outline),
        textStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: pill,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      extendedTextStyle: text.labelLarge,
      shape: pill,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      // Labels sit above the field (brief A1): screens render their own.
      floatingLabelBehavior: FloatingLabelBehavior.never,
      hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
      height: 80,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      selectedLabelTextStyle: text.labelMedium?.copyWith(
        color: scheme.onSurface,
      ),
      unselectedLabelTextStyle: text.labelMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      labelType: NavigationRailLabelType.all,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.sheet),
      ),
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.field),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: scheme.secondaryContainer,
        selectedForegroundColor: scheme.onSecondaryContainer,
        side: BorderSide(color: scheme.outline),
        textStyle: text.labelLarge,
        minimumSize: const Size(44, 44),
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: text.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.tag),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: Space.md,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
      titleTextStyle: text.titleMedium,
      subtitleTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 8,
    ),
    focusColor: scheme.primary,
  );
}
