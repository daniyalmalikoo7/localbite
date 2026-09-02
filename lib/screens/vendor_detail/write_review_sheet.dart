import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../app/app_scope.dart';
import '../../domain/meal_period.dart';
import '../../domain/review.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/filter_chip_button.dart';
import '../../widgets/primary_cta.dart';

/// Compose a review.
///
/// The meal period defaults to whichever window it currently is — the tag is
/// captured when the review is written rather than chosen by the reader, which
/// is what makes the time-of-day filter trustworthy.
Future<void> showWriteReviewSheet(
  BuildContext context, {
  required String vendorId,
  required String vendorName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) =>
        _WriteReviewSheet(vendorId: vendorId, vendorName: vendorName),
  );
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.vendorId, required this.vendorName});

  final String vendorId;
  final String vendorName;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  final _controller = TextEditingController();
  int _rating = 5;
  MealPeriod? _period;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reviews = AppScope.reviewsOf(context);
    final now = AppScope.clockOf(context).now;
    final period = _period ?? MealPeriod.at(now) ?? MealPeriod.dinner;

    reviews.addReview(
      Review(
        id: 'local-${now.microsecondsSinceEpoch}',
        vendorId: widget.vendorId,
        authorName: 'You',
        authorEmoji: '🙂',
        rating: _rating,
        body: _controller.text.trim(),
        postedAt: now,
        mealPeriod: period,
      ),
    );
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Review posted',
      Directionality.of(context),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = AppScope.clockOf(context).now;
    final activePeriod = _period ?? MealPeriod.at(now) ?? MealPeriod.dinner;
    final canSubmit = _controller.text.trim().length >= 3;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Review ${widget.vendorName}',
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Your rating', style: AppTextStyles.sectionHeader),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              container: true,
              label: 'Your rating',
              value: '$_rating out of 5 stars',
              child: Row(
                children: [
                  for (var star = 1; star <= 5; star++)
                    Semantics(
                      checked: star <= _rating,
                      inMutuallyExclusiveGroup: true,
                      child: IconButton(
                        onPressed: () {
                          setState(() => _rating = star);
                          SemanticsService.sendAnnouncement(
                            View.of(context),
                            '$star of 5 stars',
                            Directionality.of(context),
                          );
                        },
                        iconSize: 30,
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        constraints: const BoxConstraints(
                          minWidth: AppSizes.minTapTarget,
                          minHeight: AppSizes.minTapTarget,
                        ),
                        tooltip: 'Rate $star star${star == 1 ? '' : 's'}',
                        icon: Icon(
                          star <= _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('When did you eat?', style: AppTextStyles.sectionHeader),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final period in MealPeriod.values)
                  FilterChipButton(
                    label: period.label,
                    selected: period == activePeriod,
                    onPressed: () => setState(() => _period = period),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              maxLines: 4,
              maxLength: 240,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Your review',
                helperText: 'At least 3 characters',
                hintText: 'What was it like?',
                hintStyle: AppTextStyles.secondary,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: const BorderSide(color: AppColors.hairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: const BorderSide(color: AppColors.hairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: const BorderSide(
                    color: AppColors.primaryStrong,
                    width: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryCta(
              label: 'Post review',
              onPressed: canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
