import 'package:flutter/material.dart';

import 'app_theme.dart';

/// The named type roles from the Assessment 3 typography table.
///
/// Sizes are logical pixels, which Flutter scales by the user's system text
/// setting. Nothing here sets a fixed container height, so a larger scale grows
/// the line rather than clipping it.
abstract final class AppTextStyles {
  static const wordmark = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.1,
  );

  static const sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.25,
  );

  static const screenTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  static const vendorName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.25,
  );

  static const vendorNameLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  static const secondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSecondary,
    height: 1.3,
  );

  static const chipLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.4,
  );

  static const cta = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static const tag = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
