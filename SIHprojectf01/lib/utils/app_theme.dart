import 'package:flutter/material.dart';

/// TRIPSAFE design tokens and theme system.
/// All colors, typography, and spacing defined here.
abstract class AppTheme {
  AppTheme._();

  // ── Brand colours (const constants for safe const TextStyle usage) ──
  static const Color primary = Color(0xFF1A6FBF); // ocean blue
  static const Color secondary = Color(0xFF00BFA6); // teal accent
  static const Color warning = Color(0xFFFF8C00); // amber
  static const Color danger = Color(0xFFD32F2F); // risk red
  static const Color error = Color(0xFFD32F2F); // alias for danger
  static const Color success = Color(0xFF2E7D32); // safe green

  static const Color _surfaceLight = Color(0xFFF8FAFC);
  static const Color _surfaceDark = Color(0xFF121417); // neutral charcoal, not navy-tinted
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF1E2124); // neutral, desaturated

  // ── Light theme ────────────────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      error: danger,
      surface: _surfaceLight,
    );
    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: _surfaceLight,
      cardTheme: CardThemeData(
        color: _cardLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF4DA3FF),
      secondary: secondary,
      error: const Color(0xFFEF5350),
      surface: _surfaceDark,
    );
    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: _surfaceDark,
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _cardDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4DA3FF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4DA3FF),
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: Color(0xFF4DA3FF), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: Color(0xFF2C3E50)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: Color(0xFF2C3E50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: Color(0xFF4DA3FF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

/// Spacing scale.
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 32.0;
}

/// Typography scale — uses system fonts (no external packages needed).
abstract class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );
}
