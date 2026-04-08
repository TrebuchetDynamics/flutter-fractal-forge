import 'package:flutter/material.dart';

/// Premium color palette for the fractal forge app.
/// Deep cosmic theme with vibrant accents.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary backgrounds
  static const Color background = Color(0xFF0A0A12);
  static const Color surface = Color(0xFF12121C);
  static const Color surfaceVariant = Color(0xFF1A1A28);
  static const Color surfaceElevated = Color(0xFF22222E);

  // Accent colors - cosmic purple/blue gradient
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color primaryDark = Color(0xFF5C3DBF);

  // Secondary - cyan/teal for contrast
  static const Color secondary = Color(0xFF18FFFF);
  static const Color secondaryLight = Color(0xFF76FFFF);
  static const Color secondaryDark = Color(0xFF00E5CC);

  // Accent gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D0D1A),
      Color(0xFF1A0D26),
      Color(0xFF0D1A26),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF18FFFF)],
  );

  // Text colors
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color textMuted = Color(0xFF6E6E7A);

  // Borders and dividers
  static const Color border = Color(0xFF2A2A38);
  static const Color borderLight = Color(0xFF3A3A48);
  static const Color divider = Color(0xFF1E1E28);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);

  // Glassmorphism
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);
}

/// High contrast color palette for accessibility.
///
/// Provides WCAG AAA compliant contrast ratios (7:1) for users
/// with low vision or color perception difficulties.
class HighContrastColors {
  HighContrastColors._();

  // Primary backgrounds - pure black for maximum contrast
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF262626);

  // High contrast accent colors
  static const Color primary = Color(0xFFFFFF00); // Bright yellow
  static const Color primaryLight = Color(0xFFFFFF99);
  static const Color primaryDark = Color(0xFFCCCC00);

  // Secondary - bright cyan for contrast
  static const Color secondary = Color(0xFF00FFFF);
  static const Color secondaryLight = Color(0xFF99FFFF);
  static const Color secondaryDark = Color(0xFF00CCCC);

  // High contrast gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFF00), Color(0xFFFFCC00)],
  );

  // Text colors - pure white for maximum readability
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFFB0B0B0);

  // Borders - bright and visible
  static const Color border = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFCCCCCC);
  static const Color divider = Color(0xFF666666);

  // Status colors - bright and distinct
  static const Color success = Color(0xFF00FF00);
  static const Color warning = Color(0xFFFFFF00);
  static const Color error = Color(0xFFFF0000);

  // Focus indicator - highly visible
  static const Color focusIndicator = Color(0xFFFFFF00);
}

/// OLED-optimized color palette with pure black backgrounds.
///
/// Saves battery on OLED/AMOLED displays by using true black (#000000)
/// instead of dark grays. The cosmic accent colors remain vibrant
/// against the pure black background.
class OledColors {
  OledColors._();

  // Primary backgrounds - PURE BLACK for OLED
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceVariant = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1E1E1E);

  // Accent colors - same cosmic purple/blue
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color primaryDark = Color(0xFF5C3DBF);

  // Secondary - same cyan/teal
  static const Color secondary = Color(0xFF18FFFF);
  static const Color secondaryLight = Color(0xFF76FFFF);
  static const Color secondaryDark = Color(0xFF00E5CC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF000000),
      Color(0xFF0D0620),
      Color(0xFF000D1A),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF18FFFF)],
  );

  // Text colors - slightly brighter for contrast on black
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textMuted = Color(0xFF888888);

  // Borders - subtle gray for depth
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF404040);
  static const Color divider = Color(0xFF1A1A1A);

  // Status colors - same vibrant colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);

  // Glassmorphism - darker for OLED
  static Color glassBackground = Colors.white.withValues(alpha: 0.03);
  static Color glassBorder = Colors.white.withValues(alpha: 0.08);
}

/// Premium typography with careful weight and spacing.
/// Uses Poppins for titles, Inter for body, JetBrains Mono for numbers.
class AppTypography {
  // Font families - using google_fonts package
  static const String titleFont = 'Poppins';
  static const String bodyFont = 'Inter';
  static const String monoFont = 'JetBrains Mono';

  // Base styles
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: bodyFont,
    color: AppColors.textPrimary,
  );

  // Title styles - Poppins for more personality
  static const TextStyle displayLarge = TextStyle(
    fontFamily: titleFont,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: titleFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: titleFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: titleFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: titleFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.05,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: titleFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: titleFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  // Body styles - Inter for readability
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.textMuted,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.textMuted,
  );

  // Monospace for numeric values - JetBrains Mono
  static const TextStyle numericValue = TextStyle(
    fontFamily: monoFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle numericValueSmall = TextStyle(
    fontFamily: monoFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textSecondary,
  );
}

/// Animation durations and curves.
///
/// Use [AppAnimations.of] to get accessibility-aware durations
/// that respect the user's reduced motion preferences.
class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);

  /// Duration.zero for instant transitions (reduced motion mode).
  static const Duration instant = Duration.zero;

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve snappyCurve = Curves.easeOutQuart;

  /// Returns an accessibility-aware animation helper.
  ///
  /// If the user has enabled reduced motion (system or in-app),
  /// all durations return [Duration.zero] for instant transitions.
  ///
  /// Example:
  /// ```dart
  /// final anim = AppAnimations.of(context);
  /// AnimatedContainer(
  ///   duration: anim.normal,
  ///   // ...
  /// )
  /// ```
  static AccessibleAnimations of(BuildContext context) {
    final shouldReduce = MediaQuery.of(context).disableAnimations;
    return AccessibleAnimations(reduceMotion: shouldReduce);
  }
}

/// Accessibility-aware animation durations.
///
/// When [reduceMotion] is true, all durations return [Duration.zero]
/// to provide instant transitions for users with vestibular disorders.
class AccessibleAnimations {
  /// Whether to reduce motion (disable animations).
  final bool reduceMotion;

  const AccessibleAnimations({this.reduceMotion = false});

  /// Fast animation duration (150ms or instant).
  Duration get fast =>
      reduceMotion ? AppAnimations.instant : AppAnimations.fast;

  /// Normal animation duration (250ms or instant).
  Duration get normal =>
      reduceMotion ? AppAnimations.instant : AppAnimations.normal;

  /// Slow animation duration (350ms or instant).
  Duration get slow =>
      reduceMotion ? AppAnimations.instant : AppAnimations.slow;

  /// Slower animation duration (500ms or instant).
  Duration get slower =>
      reduceMotion ? AppAnimations.instant : AppAnimations.slower;

  /// Recommended curve for animations.
  ///
  /// Returns [Curves.linear] for reduced motion (instant feel)
  /// or the default curve otherwise.
  Curve get curve => reduceMotion ? Curves.linear : AppAnimations.defaultCurve;
}

/// Spacing and sizing constants.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double cardRadius = 16;
  static const double buttonRadius = 12;
  static const double chipRadius = 8;
  static const double inputRadius = 12;

  static const double cardElevation = 0;
  static const double modalElevation = 8;
}

/// Minimum touch target size per WCAG 2.1 guidelines.
///
/// Interactive elements should be at least 44x44 logical pixels
/// to be easily tappable for users with motor impairments.
class AccessibleSizing {
  AccessibleSizing._();

  /// Minimum touch target size (48x48 per Material guidelines).
  static const double minTouchTarget = 48.0;

  /// Larger touch target for accessibility mode.
  static const double largeTouchTarget = 56.0;

  /// Minimum focus indicator width.
  static const double focusIndicatorWidth = 3.0;

  /// Returns the appropriate touch target size.
  ///
  /// When [largeTargets] is true, returns the larger size.
  static double touchTargetSize({bool largeTargets = false}) {
    return largeTargets ? largeTouchTarget : minTouchTarget;
  }
}

/// Premium app theme data.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppSpacing.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColors.border,
        dragHandleSize: const Size(40, 4),
        elevation: AppSpacing.modalElevation,
        showDragHandle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle:
              AppTypography.labelLarge.copyWith(color: AppColors.primary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.all(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide:
              BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        labelStyle: AppTypography.bodyMedium,
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            AppTypography.labelMedium.copyWith(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.4);
          }
          return AppColors.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        disabledColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle:
            AppTypography.labelMedium.copyWith(color: AppColors.primary),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: false,
        iconColor: AppColors.textMuted,
        textColor: AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
        circularTrackColor: AppColors.surfaceVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
      ),
    );
  }

  /// High contrast theme for accessibility.
  ///
  /// Uses WCAG AAA compliant color combinations with maximum contrast
  /// ratios for users with low vision or color perception difficulties.
  static ThemeData get highContrast {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: HighContrastColors.background,
      primaryColor: HighContrastColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: HighContrastColors.primary,
        primaryContainer: HighContrastColors.primaryDark,
        secondary: HighContrastColors.secondary,
        secondaryContainer: HighContrastColors.secondaryDark,
        surface: HighContrastColors.surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: HighContrastColors.textPrimary,
        error: HighContrastColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: HighContrastColors.textSecondary,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: HighContrastColors.textSecondary,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: HighContrastColors.textMuted,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: HighContrastColors.textSecondary,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: HighContrastColors.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: HighContrastColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: HighContrastColors.textPrimary,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        color: HighContrastColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: HighContrastColors.border, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HighContrastColors.surface,
        selectedItemColor: HighContrastColors.primary,
        unselectedItemColor: HighContrastColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HighContrastColors.surface,
        modalBackgroundColor: HighContrastColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: HighContrastColors.border, width: 2),
        ),
        dragHandleColor: HighContrastColors.textPrimary,
        dragHandleSize: Size(40, 4),
        elevation: 0,
        showDragHandle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HighContrastColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(
              AccessibleSizing.minTouchTarget, AccessibleSizing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            side: const BorderSide(color: HighContrastColors.border, width: 2),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HighContrastColors.textPrimary,
          side: const BorderSide(color: HighContrastColors.border, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(
              AccessibleSizing.minTouchTarget, AccessibleSizing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      focusColor: HighContrastColors.focusIndicator,
      hoverColor: HighContrastColors.primary.withValues(alpha: 0.2),
      splashColor: HighContrastColors.primary.withValues(alpha: 0.3),
      highlightColor: HighContrastColors.primary.withValues(alpha: 0.2),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HighContrastColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide:
              const BorderSide(color: HighContrastColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide:
              const BorderSide(color: HighContrastColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide:
              const BorderSide(color: HighContrastColors.primary, width: 3),
        ),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: HighContrastColors.textMuted),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: HighContrastColors.textPrimary),
        prefixIconColor: HighContrastColors.textSecondary,
        suffixIconColor: HighContrastColors.textSecondary,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: HighContrastColors.primary,
        inactiveTrackColor: HighContrastColors.surfaceVariant,
        thumbColor: HighContrastColors.primary,
        overlayColor: Color(0x40FFFF00),
        trackHeight: 8,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
        valueIndicatorColor: HighContrastColors.primary,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HighContrastColors.primary;
          }
          return HighContrastColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HighContrastColors.primaryDark;
          }
          return HighContrastColors.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(HighContrastColors.border),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HighContrastColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: HighContrastColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HighContrastColors.border, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: HighContrastColors.primary,
        linearTrackColor: HighContrastColors.surfaceVariant,
        circularTrackColor: HighContrastColors.surfaceVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: HighContrastColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HighContrastColors.border, width: 2),
        ),
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: HighContrastColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: HighContrastColors.textSecondary,
        ),
      ),
    );
  }

  /// OLED-optimized theme for AMOLED displays.
  ///
  /// Uses pure black (#000000) backgrounds for maximum battery savings
  /// on OLED/AMOLED screens. Cosmic purple accents remain vibrant
  /// against the true black background.
  static ThemeData get oled {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: OledColors.background,
      primaryColor: OledColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: OledColors.primary,
        primaryContainer: OledColors.primaryDark,
        secondary: OledColors.secondary,
        secondaryContainer: OledColors.secondaryDark,
        surface: OledColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: OledColors.textPrimary,
        error: OledColors.error,
      ),
      textTheme: TextTheme(
        displayLarge:
            AppTypography.displayLarge.copyWith(color: OledColors.textPrimary),
        displayMedium:
            AppTypography.displayMedium.copyWith(color: OledColors.textPrimary),
        headlineLarge:
            AppTypography.headlineLarge.copyWith(color: OledColors.textPrimary),
        headlineMedium: AppTypography.headlineMedium
            .copyWith(color: OledColors.textPrimary),
        titleLarge:
            AppTypography.titleLarge.copyWith(color: OledColors.textPrimary),
        titleMedium:
            AppTypography.titleMedium.copyWith(color: OledColors.textPrimary),
        bodyLarge:
            AppTypography.bodyLarge.copyWith(color: OledColors.textSecondary),
        bodyMedium:
            AppTypography.bodyMedium.copyWith(color: OledColors.textSecondary),
        bodySmall:
            AppTypography.bodySmall.copyWith(color: OledColors.textMuted),
        labelLarge:
            AppTypography.labelLarge.copyWith(color: OledColors.textPrimary),
        labelMedium:
            AppTypography.labelMedium.copyWith(color: OledColors.textSecondary),
        labelSmall:
            AppTypography.labelSmall.copyWith(color: OledColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: OledColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTypography.titleLarge.copyWith(color: OledColors.textPrimary),
        iconTheme: const IconThemeData(color: OledColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: OledColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: OledColors.border.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: OledColors.background,
        selectedItemColor: OledColors.primary,
        unselectedItemColor: OledColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: OledColors.surface,
        modalBackgroundColor: OledColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: OledColors.border,
        dragHandleSize: const Size(40, 4),
        elevation: AppSpacing.modalElevation,
        showDragHandle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OledColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OledColors.textPrimary,
          side: BorderSide(color: OledColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OledColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle:
              AppTypography.labelLarge.copyWith(color: OledColors.primary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: OledColors.textPrimary,
          padding: const EdgeInsets.all(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OledColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide:
              BorderSide(color: OledColors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: OledColors.primary, width: 1.5),
        ),
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: OledColors.textMuted),
        labelStyle: AppTypography.bodyMedium,
        prefixIconColor: OledColors.textMuted,
        suffixIconColor: OledColors.textMuted,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: OledColors.primary,
        inactiveTrackColor: OledColors.surfaceVariant,
        thumbColor: OledColors.primary,
        overlayColor: OledColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        valueIndicatorColor: OledColors.primary,
        valueIndicatorTextStyle:
            AppTypography.labelMedium.copyWith(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OledColors.primary;
          }
          return OledColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OledColors.primary.withValues(alpha: 0.4);
          }
          return OledColors.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: OledColors.surfaceVariant,
        selectedColor: OledColors.primary.withValues(alpha: 0.2),
        disabledColor: OledColors.surfaceVariant.withValues(alpha: 0.5),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle:
            AppTypography.labelMedium.copyWith(color: OledColors.primary),
        side: BorderSide(color: OledColors.border.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: false,
        iconColor: OledColors.textMuted,
        textColor: OledColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: OledColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OledColors.surfaceElevated,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: OledColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OledColors.primary,
        linearTrackColor: OledColors.surfaceVariant,
        circularTrackColor: OledColors.surfaceVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: OledColors.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.headlineMedium
            .copyWith(color: OledColors.textPrimary),
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: OledColors.textSecondary),
      ),
    );
  }
}
