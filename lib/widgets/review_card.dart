import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../domain/review.dart';
import '../domain/time_format.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'meal_period_tag.dart';
import 'rating_stars.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final now = AppScope.clockOf(context).now;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSunken,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  review.authorEmoji,
                  style: const TextStyle(fontSize: 15),
                  semanticsLabel: '',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: AppTextStyles.vendorName.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    MealPeriodTag(period: review.mealPeriod),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(review.body, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              RatingStars(
                rating: review.rating.toDouble(),
                starCount: 5,
                showValue: false,
                size: 15,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  formatRelativeTime(review.postedAt, now: now),
                  style: AppTextStyles.secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
