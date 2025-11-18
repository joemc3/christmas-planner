import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// === COLOR SYSTEM - Frosted Hearth ===
class FrostedHearthColors {
  FrostedHearthColors._();

  // PRIMARY - Deep Spruce (sophisticated blue-tinted evergreen)
  static const Color spruce = Color(0xFF1B3A4B);
  static const Color spruceDark = Color(0xFF0D2533);
  static const Color spruceLight = Color(0xFF2C5A6F);

  // SECONDARY - Warm Ember (burnished copper-rose)
  static const Color ember = Color(0xFFB87333);
  static const Color emberGlow = Color(0xFFD4956A);
  static const Color emberDark = Color(0xFF8B4513);

  // ACCENT - Frost Gold (pale champagne gold)
  static const Color frostGold = Color(0xFFF5E6C8);
  static const Color frostGoldBright = Color(0xFFFFE8A8);
  static const Color frostGoldDark = Color(0xFFD4C4A8);

  // ACCENT 2 - Winter Berry (muted cranberry)
  static const Color winterBerry = Color(0xFF8B3A3A);
  static const Color winterBerryLight = Color(0xFFAB5A5A);
  static const Color winterBerryDark = Color(0xFF6B2A2A);

  // ACCENT 3 - Ice Blue (pale glacier blue)
  static const Color ice = Color(0xFFE8F4F8);
  static const Color iceAccent = Color(0xFFB8D4E3);
  static const Color iceDark = Color(0xFF9BC4D9);

  // BACKGROUNDS - Layered warmth
  static const Color parchment = Color(0xFFFAF8F5);
  static const Color parchmentWarm = Color(0xFFF5F0E8);
  static const Color snow = Color(0xFFFFFEFC);

  // TEXT
  static const Color inkDark = Color(0xFF1A1A1A);
  static const Color inkMedium = Color(0xFF4A4A4A);
  static const Color inkLight = Color(0xFF8A8A8A);

  // SEMANTIC
  static const Color success = Color(0xFF4A7C59);
  static const Color warning = Color(0xFFD4956A);
  static const Color error = Color(0xFF9B4444);
  static const Color info = Color(0xFF4A6B8A);

  // Legacy compatibility
  static const Color christmasRed = ember;
  static const Color christmasGreen = spruce;
  static const Color christmasGold = frostGoldBright;
  static const Color lightGrey = parchmentWarm;
  static const Color textSecondary = inkMedium;
  static const Color textPrimary = inkDark;
}

// === GRADIENTS ===
class FrostedHearthGradients {
  FrostedHearthGradients._();

  // Hero gradient - warm to cool transition
  static const LinearGradient hearthToFrost = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB87333), Color(0xFF8B4513), Color(0xFF1B3A4B)],
    stops: [0.0, 0.4, 1.0],
  );

  // Subtle background gradient
  static const LinearGradient parchmentGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF8F5), Color(0xFFF5F0E8), Color(0xFFEDE8E0)],
  );

  // Night sky gradient for headers
  static const LinearGradient winterNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D2533), Color(0xFF1B3A4B), Color(0xFF2C5A6F)],
  );

  // Progress fill gradient
  static const LinearGradient progressEmber = LinearGradient(
    colors: [Color(0xFFD4956A), Color(0xFFB87333)],
  );

  // Berry gradient for highlights
  static const LinearGradient berryGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAB5A5A), Color(0xFF8B3A3A)],
  );

  // Legacy compatibility
  static const LinearGradient christmasGradient = hearthToFrost;
  static const LinearGradient greenGradient = winterNight;
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE8A8), Color(0xFFD4C4A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// === TIMING CONSTANTS ===
class FrostedHearthTiming {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration stagger = Duration(milliseconds: 100);
}

// === CURVES ===
class FrostedHearthCurves {
  static const Curve gentle = Curves.easeOutCubic;
  static const Curve playful = Curves.easeOutBack;
  static const Curve reveal = Curves.easeInOutCubic;
}

// === MAIN THEME CLASS ===
class AppTheme {
  AppTheme._();

  // Legacy color references for compatibility
  static const Color christmasRed = FrostedHearthColors.ember;
  static const Color christmasGreen = FrostedHearthColors.spruce;
  static const Color christmasGold = FrostedHearthColors.frostGoldBright;
  static const Color christmasSilver = FrostedHearthColors.iceAccent;
  static const Color snowWhite = FrostedHearthColors.snow;
  static const Color darkRed = FrostedHearthColors.winterBerry;
  static const Color forestGreen = FrostedHearthColors.spruceDark;
  static const Color warmGold = FrostedHearthColors.frostGoldDark;

  static const Color success = FrostedHearthColors.success;
  static const Color warning = FrostedHearthColors.warning;
  static const Color error = FrostedHearthColors.error;
  static const Color info = FrostedHearthColors.info;

  static const Color darkGrey = FrostedHearthColors.inkDark;
  static const Color mediumGrey = FrostedHearthColors.inkMedium;
  static const Color lightGrey = FrostedHearthColors.parchmentWarm;
  static const Color extraLightGrey = FrostedHearthColors.parchment;

  static const Color textPrimary = FrostedHearthColors.inkDark;
  static const Color textSecondary = FrostedHearthColors.inkMedium;
  static const Color textHint = FrostedHearthColors.inkLight;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FrostedHearthColors.spruce,
        primary: FrostedHearthColors.spruce,
        secondary: FrostedHearthColors.ember,
        tertiary: FrostedHearthColors.frostGold,
        surface: FrostedHearthColors.snow,
        error: FrostedHearthColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: FrostedHearthColors.parchment,
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: FrostedHearthColors.inkDark,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: FrostedHearthColors.inkDark,
        ),
        iconTheme: const IconThemeData(color: FrostedHearthColors.inkDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: FrostedHearthColors.snow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FrostedHearthColors.spruce,
          foregroundColor: FrostedHearthColors.frostGold,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.fraunces(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: FrostedHearthColors.spruce.withOpacity(0.3), width: 1.5),
          textStyle: GoogleFonts.fraunces(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.fraunces(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FrostedHearthColors.snow,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: FrostedHearthColors.parchmentWarm),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: FrostedHearthColors.parchmentWarm),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: FrostedHearthColors.ember, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: FrostedHearthColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.sourceSerif4(
          fontSize: 14,
          color: FrostedHearthColors.inkMedium,
        ),
        hintStyle: GoogleFonts.sourceSerif4(
          fontSize: 14,
          color: FrostedHearthColors.inkLight,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FrostedHearthColors.parchmentWarm,
        deleteIconColor: FrostedHearthColors.inkMedium,
        labelStyle: GoogleFonts.sourceSerif4(
          fontSize: 14,
          color: FrostedHearthColors.inkDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: FrostedHearthColors.ember,
        foregroundColor: FrostedHearthColors.frostGold,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: FrostedHearthColors.inkDark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: FrostedHearthColors.spruce,
        selectedItemColor: FrostedHearthColors.frostGoldBright,
        unselectedItemColor: FrostedHearthColors.frostGold.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: FrostedHearthColors.parchmentWarm,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: FrostedHearthColors.ember,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FrostedHearthColors.spruce,
        contentTextStyle: GoogleFonts.sourceSerif4(
          fontSize: 14,
          color: FrostedHearthColors.frostGold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FrostedHearthColors.spruce,
        primary: FrostedHearthColors.ember,
        secondary: FrostedHearthColors.frostGold,
        tertiary: FrostedHearthColors.iceAccent,
        surface: const Color(0xFF1E1E1E),
        error: FrostedHearthColors.error,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: FrostedHearthColors.frostGold,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: FrostedHearthColors.frostGold,
        ),
        iconTheme: const IconThemeData(color: FrostedHearthColors.frostGold),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: FrostedHearthColors.ember,
          foregroundColor: FrostedHearthColors.frostGold,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.fraunces(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: FrostedHearthColors.ember, width: 2),
        ),
        labelStyle: GoogleFonts.sourceSerif4(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme({bool isDark = false}) {
    final color = isDark ? FrostedHearthColors.frostGold : FrostedHearthColors.inkDark;
    final secondaryColor = isDark ? Colors.white70 : FrostedHearthColors.inkMedium;
    final tertiaryColor = isDark ? Colors.white54 : FrostedHearthColors.inkLight;

    return TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.fraunces(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: GoogleFonts.fraunces(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.sourceSerif4(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      ),
      bodyMedium: GoogleFonts.sourceSerif4(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodySmall: GoogleFonts.sourceSerif4(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: tertiaryColor,
      ),
      labelLarge: GoogleFonts.dmMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      labelMedium: GoogleFonts.dmMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.dmMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: tertiaryColor,
      ),
    );
  }

  // Custom Gradients (Legacy)
  static const LinearGradient christmasGradient = FrostedHearthGradients.hearthToFrost;
  static const LinearGradient greenGradient = FrostedHearthGradients.winterNight;
  static const LinearGradient goldGradient = FrostedHearthGradients.goldGradient;

  // Custom Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: FrostedHearthColors.spruce.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: FrostedHearthColors.ember.withOpacity(0.03),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: FrostedHearthColors.ember.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: FrostedHearthColors.spruce.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
}
