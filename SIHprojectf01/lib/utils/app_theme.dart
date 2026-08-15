import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TRIPSAFE design tokens and theme system.
///
/// Dark-first "accent panel" theme (design direction 1a):
///   charcoal surfaces, hairline borders, no elevation, pill controls,
///   one saturated accent panel per screen carrying the hierarchy.
/// Light theme is kept at working parity; dark is the default.
abstract class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE4572E); // rust — primary action
  static const Color secondary = Color(0xFFF2C230); // saffron — planning/budget
  static const Color warning = Color(0xFFF2C230); // saffron — advisories
  static const Color danger = Color(0xFFE4572E); // rust — risk
  static const Color error = Color(0xFFE4572E); // alias for danger
  static const Color success = Color(0xFF3FBF74); // safe green
  static const Color info = Color(0xFF4DA3FF); // live/tracking blue

  /// Text/icon colour to place ON a saturated accent panel.
  static const Color onPrimary = Color(0xFF150C07);
  static const Color onSecondary = Color(0xFF1A1405);
  static const Color onSuccess = Color(0xFF06180E);
  static const Color onInfo = Color(0xFF04121F);

  // ── Dark surfaces ──────────────────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF101214);
  static const Color cardDark = Color(0xFF1B1E21);
  static const Color onDark = Color(0xFFF2F0EA); // warm off-white
  static const Color mutedDark = Color(0xFF7E8582); // secondary text
  static const Color subtleDark = Color(0xFF9BA19E); // body text on cards

  // ── Light surfaces ─────────────────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFF4F2EC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color onLight = Color(0xFF14171A);
  static const Color mutedLight = Color(0xFF6B7270);

  /// Hairline border used on every card. No shadows anywhere in the app.
  static const Color borderDark = Color(0x14FFFFFF); // white @ ~8%
  static const Color borderLight = Color(0x14000000);

  /// Preferred replacement for `Colors.grey` in screen code.
  /// Resolves against the active brightness so screens stay legible in both.
  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? mutedDark : mutedLight;

  /// Body text colour — replacement for `Colors.black87` in screen code.
  static Color body(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? subtleDark : onLight;

  /// Tinted fill for an icon chip or soft badge.
  static Color tint(Color c, [double alpha = 0.14]) => c.withValues(alpha: alpha);

  // ── Dark theme (default) ───────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: danger,
      surface: surfaceDark,
      onSurface: onDark,
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: surfaceDark,
      canvasColor: surfaceDark,
      textTheme: AppTypography.textTheme(onDark),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: borderDark),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: onDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.screenTitle.copyWith(color: onDark),
        iconTheme: const IconThemeData(color: onDark, size: 22),
        actionsIconTheme: const IconThemeData(color: onDark, size: 22),
      ),
      iconTheme: const IconThemeData(color: onDark, size: 22),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: AppSpacing.md,
      ),
      elevatedButtonTheme: _elevated(primary, onPrimary),
      outlinedButtonTheme: _outlined(onDark, const Color(0x29FFFFFF)),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTypography.buttonLabel,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: onDark,
          foregroundColor: surfaceDark,
          minimumSize: const Size(double.infinity, 52),
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabel,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: onDark,
        labelStyle: AppTypography.chipLabel.copyWith(color: onDark),
        secondaryLabelStyle: AppTypography.chipLabel.copyWith(color: surfaceDark),
        side: const BorderSide(color: borderDark),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        showCheckmark: false,
      ),
      inputDecorationTheme: _input(
        fill: cardDark,
        border: const Color(0x1FFFFFFF),
        focus: primary,
        label: mutedDark,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: const Color(0x1FFFFFFF),
        thumbColor: onDark,
        overlayColor: tint(primary, 0.12),
        valueIndicatorColor: onDark,
        valueIndicatorTextStyle: AppTypography.chipLabel.copyWith(color: surfaceDark),
        trackHeight: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondary,
        linearTrackColor: Color(0x14FFFFFF),
        linearMinHeight: 7,
        circularTrackColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primary,
        unselectedItemColor: mutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardDark,
        indicatorColor: primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.chipLabel.copyWith(color: onDark),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: borderDark),
        ),
        titleTextStyle: AppTypography.titleMedium.copyWith(color: onDark),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: subtleDark),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onDark,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: surfaceDark,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: borderDark),
        ),
        textStyle: AppTypography.bodyMedium.copyWith(color: onDark),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: mutedDark,
        textColor: onDark,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onPrimary : onDark,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : const Color(0x1FFFFFFF),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onDark,
        unselectedLabelColor: mutedDark,
        indicatorColor: primary,
        dividerColor: borderDark,
        labelStyle: AppTypography.chipLabel,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: StadiumBorder(),
      ),
    );
  }

  // ── Light theme (kept working; dark is the design of record) ───────────
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: danger,
      surface: surfaceLight,
      onSurface: onLight,
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: surfaceLight,
      canvasColor: surfaceLight,
      textTheme: AppTypography.textTheme(onLight),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: borderLight),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: onLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.screenTitle.copyWith(color: onLight),
        iconTheme: const IconThemeData(color: onLight, size: 22),
        actionsIconTheme: const IconThemeData(color: onLight, size: 22),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: AppSpacing.md,
      ),
      elevatedButtonTheme: _elevated(primary, onPrimary),
      outlinedButtonTheme: _outlined(onLight, const Color(0x29000000)),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTypography.buttonLabel,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardLight,
        selectedColor: onLight,
        labelStyle: AppTypography.chipLabel.copyWith(color: onLight),
        secondaryLabelStyle: AppTypography.chipLabel.copyWith(color: cardLight),
        side: const BorderSide(color: borderLight),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      inputDecorationTheme: _input(
        fill: cardLight,
        border: const Color(0x1F000000),
        focus: primary,
        label: mutedLight,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: const Color(0x1F000000),
        thumbColor: onLight,
        overlayColor: tint(primary, 0.12),
        trackHeight: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondary,
        linearTrackColor: Color(0x14000000),
        linearMinHeight: 7,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onLight,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: cardLight,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: secondary,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: StadiumBorder(),
      ),
    );
  }

  // ── Shared button/input builders ───────────────────────────────────────
  static ElevatedButtonThemeData _elevated(Color bg, Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.35),
        disabledForegroundColor: fg.withValues(alpha: 0.5),
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const StadiumBorder(),
        textStyle: AppTypography.buttonLabel,
      ),
    );
  }

  static OutlinedButtonThemeData _outlined(Color fg, Color border) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: border, width: 1.5),
        shape: const StadiumBorder(),
        textStyle: AppTypography.buttonLabel,
      ),
    );
  }

  static InputDecorationTheme _input({
    required Color fill,
    required Color border,
    required Color focus,
    required Color label,
  }) {
    OutlineInputBorder side(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: side(border),
      enabledBorder: side(border),
      focusedBorder: side(focus, 1.8),
      errorBorder: side(danger),
      labelStyle: AppTypography.caption.copyWith(
        color: label,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      floatingLabelStyle: AppTypography.caption.copyWith(
        color: focus,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: label),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
    );
  }
}

/// Spacing and radius scale.
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 12.0;
  static const double radiusMd = 18.0;
  static const double radiusLg = 22.0;
  static const double radiusXl = 28.0;

  /// Fully rounded — buttons, chips, pills, location bars.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(100));
}

/// Typography scale — Space Grotesk via google_fonts.
///
/// Display and screen titles are set tight and UPPERCASE at the call site
/// (`'Explore'.toUpperCase()`); the styles here only carry size/weight/tracking.
abstract class AppTypography {
  AppTypography._();

  static TextStyle _gs({
    required double size,
    required FontWeight weight,
    double? spacing,
    double? height,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
      );

  static TextStyle get displayLarge =>
      _gs(size: 34, weight: FontWeight.w700, spacing: -1.4, height: 1.0);

  static TextStyle get displayMedium =>
      _gs(size: 27, weight: FontWeight.w700, spacing: -0.9, height: 1.05);

  /// App-bar / screen heading. Use with `.toUpperCase()`.
  static TextStyle get screenTitle =>
      _gs(size: 22, weight: FontWeight.w700, spacing: -0.7, height: 1.05);

  static TextStyle get titleLarge =>
      _gs(size: 19, weight: FontWeight.w700, spacing: -0.5, height: 1.15);

  static TextStyle get titleMedium =>
      _gs(size: 16, weight: FontWeight.w700, spacing: -0.3, height: 1.25);

  static TextStyle get titleSmall =>
      _gs(size: 14.5, weight: FontWeight.w700, spacing: -0.2, height: 1.3);

  static TextStyle get bodyLarge =>
      _gs(size: 15, weight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      _gs(size: 13, weight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      _gs(size: 12, weight: FontWeight.w400, height: 1.45);

  static TextStyle get labelLarge =>
      _gs(size: 14, weight: FontWeight.w700, spacing: 0.2);

  static TextStyle get buttonLabel =>
      _gs(size: 14, weight: FontWeight.w700, spacing: 0.3);

  static TextStyle get chipLabel =>
      _gs(size: 11.5, weight: FontWeight.w700, spacing: 0.3);

  static TextStyle get caption =>
      _gs(size: 11, weight: FontWeight.w400, spacing: 0.2, height: 1.4);

  /// Small all-caps section label: "WHAT'S THE PLAN TODAY".
  static TextStyle get sectionLabel =>
      _gs(size: 11, weight: FontWeight.w700, spacing: 2.0);

  /// Big figures — safety score, stop counts, budget totals.
  static TextStyle get statNumber =>
      _gs(size: 26, weight: FontWeight.w700, spacing: -1.0, height: 1.0);

  static TextTheme textTheme(Color color) => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineSmall: screenTitle,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelSmall: chipLabel,
      ).apply(bodyColor: color, displayColor: color);
}
