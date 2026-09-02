import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// LocalBite design tokens.
///
/// Brand values come from the Assessment 3 design specification. Status and
/// meal-period colours are named for their *meaning* rather than their hue, so
/// the palette can be retuned in one place without touching call sites.
///
/// Every foreground/background pair below was measured against WCAG 2.1 AA
/// (4.5:1 for body text, 3:1 for large text and UI components) before use.
abstract final class AppColors {
  // --- Brand -------------------------------------------------------------
  /// Brand orange. Used for fills that carry no small text: the active tab
  /// underline, the queue meter, and the 22sp bold wordmark (large text,
  /// 3.50:1 on white — passes AA at that size).
  static const primary = Color(0xFFE85D04);

  /// Darkened orange for anywhere small text meets the brand colour: filled
  /// CTAs and active chips with white labels (5.01:1), and orange labels on
  /// light grounds (5.01:1 on white, 4.68:1 on sand). The A3 report claimed
  /// #E85D04 passed at body size; measured, it is 3.50:1 and does not.
  static const primaryStrong = Color(0xFFBF4A02);

  /// Deep green. Vendor Detail hero and the "Bite" half of the wordmark.
  static const accent = Color(0xFF1B4332);

  // --- Surfaces ----------------------------------------------------------
  static const background = Color(0xFFFAF7F2); // sand
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFF1EDE6);

  // --- Text --------------------------------------------------------------
  static const ink = Color(0xFF1A1A1A); // 16.29:1 on sand
  static const inkSecondary = Color(0xFF6B6B6B); // 4.99:1 on sand
  static const inkMuted = Color(0xFF9E9E9E); // decorative only, never text

  // --- Lines and shadows -------------------------------------------------
  static const hairline = Color(0x141A1A1A);
  static const cardShadow = Color(0x0F000000);

  // --- Semantic: trading status ------------------------------------------
  // Green/red rather than the report's orange/grey: orange collides with the
  // primary action colour (an OPEN badge would read as tappable), and
  // green/red carries pre-learned meaning. The badge always spells the word
  // "OPEN"/"CLOSED" so the state is never conveyed by colour alone (WCAG 1.4.1).
  static const statusOpen = Color(0xFF16692F); // 5.97:1 on its surface
  static const statusOpenSurface = Color(0xFFE6F4EA);
  static const statusClosed = Color(0xFFC5221F); // 4.92:1 on its surface
  static const statusClosedSurface = Color(0xFFFCE8E6);

  // --- Semantic: meal period ---------------------------------------------
  // Three distinguishable hues per the A3 spec. The Figma's amber/red pairing
  // collided with the CLOSED red, so the documented palette is used instead.
  static const mealBreakfast = Color(0xFF8A5C00); // 5.31:1
  static const mealBreakfastSurface = Color(0xFFFFF4D6);
  static const mealLunch = Color(0xFF1A5FB4); // 5.36:1
  static const mealLunchSurface = Color(0xFFE3EEFB);
  static const mealDinner = Color(0xFF6B3FA0); // 6.20:1
  static const mealDinnerSurface = Color(0xFFF0E8FA);
}

abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AppRadius {
  static const tag = 4.0;
  static const badge = 6.0;
  static const card = 12.0;
  static const button = 12.0;
  static const chip = 16.0;
  static const pill = 999.0;
}

abstract final class AppDuration {
  static const fast = Duration(milliseconds: 140);
  static const normal = Duration(milliseconds: 240);
}

/// Minimum heights from the A3 component table.
///
/// Deliberately *minimums*, not fixed heights: at large system text scales a
/// fixed height clips its own label, which would fail the accessibility
/// requirement the same spec sets out.
abstract final class AppSizes {
  static const vendorCardMinHeight = 96.0;
  static const chipMinHeight = 32.0;
  static const bottomNavMinHeight = 64.0;
  static const ctaMinHeight = 52.0;
  static const thumbnail = 72.0;
  static const queueBarHeight = 8.0;
  static const minTapTarget = 48.0;
}

/// Icon sizes as tokens rather than arbitrary per-call values, so the set
/// keeps a consistent rhythm across the interface.
abstract final class AppIconSize {
  static const xs = 14.0;
  static const sm = 16.0;
  static const md = 20.0;
  static const lg = 24.0;
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          surface: AppColors.background,
          onSurface: AppColors.ink,
          error: AppColors.statusClosed,
        );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryStrong,
          foregroundColor: Colors.white,
          // An explicit disabled pair: the default dims the fill and the label
          // together until the button is barely perceptible.
          disabledBackgroundColor: AppColors.surfaceSunken,
          disabledForegroundColor: AppColors.inkSecondary,
          minimumSize: const Size.fromHeight(AppSizes.ctaMinHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }

  /// Dark status-bar icons, for the sand-background screens.
  static const overlayDarkIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  /// Light status-bar icons, for the deep-green Vendor Detail hero.
  static const overlayLightIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
}
