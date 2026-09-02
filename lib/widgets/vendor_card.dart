import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../domain/time_format.dart';
import '../domain/vendor.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import 'meal_period_tag.dart';
import 'rating_stars.dart';
import 'status_badge.dart';

/// The vendor row used on both Home and Saved.
///
/// The trailing chevron is the affordance added after user testing: two of the
/// five participants hesitated over whether the card was tappable, so a
/// right-facing arrow now signals it explicitly.
class VendorCard extends StatefulWidget {
  const VendorCard({
    super.key,
    required this.vendor,
    required this.onTap,
    this.trailing,
    this.selected = false,
  });

  final Vendor vendor;
  final VoidCallback onTap;

  /// Replaces the chevron. Saved passes a filled heart.
  final Widget? trailing;

  /// Highlights the row in the tablet two-pane layout.
  final bool selected;

  @override
  State<VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final selected = widget.selected;
    final trailing = widget.trailing;
    final catalog = AppScope.catalogOf(context);
    final reviews = AppScope.reviewsOf(context);
    final distance = formatDistance(vendor.distanceFrom(catalog.origin));

    // No explicit label and no excludeSemantics: the merged children already
    // read well and keep the live trading status reachable.
    return Semantics(
      button: true,
      child: AnimatedScale(
        // Transform-only, so surrounding content never shifts.
        scale: _pressed ? 0.98 : 1,
        duration: context.motion(const Duration(milliseconds: 160)),
        curve: Curves.easeOut,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.hairline,
                  width: selected ? 2 : 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.vendorCardMinHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Thumbnail(emoji: vendor.emoji),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vendor.name,
                              style: AppTextStyles.vendorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              vendor.cuisineLabel,
                              style: AppTextStyles.secondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.sm - 2),
                            StatusBadge(
                              hours: vendor.hours,
                              showChangeLabel: true,
                            ),
                            const SizedBox(height: AppSpacing.sm - 2),
                            _RatingLine(vendor: vendor, distance: distance),
                            ListenableBuilder(
                              listenable: reviews,
                              builder: (context, _) {
                                final periods =
                                    reviews
                                        .periodsWithReviews(vendor.id)
                                        .toList()
                                      ..sort(
                                        (a, b) => a.index.compareTo(b.index),
                                      );
                                if (periods.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.sm - 2,
                                  ),
                                  child: Wrap(
                                    spacing: AppSpacing.xs + 2,
                                    runSpacing: AppSpacing.xs,
                                    children: [
                                      for (final period in periods)
                                        MealPeriodTag(period: period),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      trailing ??
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: AppIconSize.md,
                            color: AppColors.inkSecondary,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.thumbnail,
      height: AppSizes.thumbnail,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.card - 2),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 30),
        // The emoji is decorative; the name carries the meaning.
        semanticsLabel: '',
      ),
    );
  }
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.vendor, required this.distance});

  final Vendor vendor;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingStars(rating: vendor.rating),
        const SizedBox(width: AppSpacing.xs + 2),
        Flexible(
          child: Text(
            '(${vendor.reviewCount}) · $distance',
            style: AppTextStyles.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
