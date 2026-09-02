import 'package:flutter/material.dart';

import '../domain/meal_period.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Small coloured pill marking which meal window a review belongs to.
class MealPeriodTag extends StatelessWidget {
  const MealPeriodTag({super.key, required this.period});

  final MealPeriod period;

  static (Color foreground, Color background) colorsFor(MealPeriod period) =>
      switch (period) {
        MealPeriod.breakfast => (
          AppColors.mealBreakfast,
          AppColors.mealBreakfastSurface,
        ),
        MealPeriod.lunch => (AppColors.mealLunch, AppColors.mealLunchSurface),
        MealPeriod.dinner => (
          AppColors.mealDinner,
          AppColors.mealDinnerSurface,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = colorsFor(period);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(
        period.label,
        style: AppTextStyles.tag.copyWith(color: foreground),
      ),
    );
  }
}
