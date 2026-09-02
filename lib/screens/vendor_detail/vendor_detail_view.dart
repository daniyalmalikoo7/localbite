import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/meal_period.dart';
import '../../domain/time_format.dart';
import '../../domain/vendor.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_button.dart';
import '../../widgets/primary_cta.dart';
import '../../widgets/queue_meter.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/review_card.dart';
import '../../widgets/status_badge.dart';
import 'write_review_sheet.dart';

/// Vendor Detail content, embeddable in either a pushed route or a tablet
/// detail pane. Resolves the vendor by id so newly posted reviews appear
/// without the caller passing a fresh snapshot down.
class VendorDetailView extends StatefulWidget {
  const VendorDetailView({
    super.key,
    required this.vendorId,
    this.showBackButton = true,
  });

  final String vendorId;
  final bool showBackButton;

  @override
  State<VendorDetailView> createState() => _VendorDetailViewState();
}

class _VendorDetailViewState extends State<VendorDetailView> {
  MealPeriod? _mealFilter;

  @override
  void didUpdateWidget(VendorDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switching vendors in the two-pane layout should not carry the previous
    // vendor's review filter across.
    if (oldWidget.vendorId != widget.vendorId) _mealFilter = null;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.catalogOf(context);
    final vendor = catalog.vendorById(widget.vendorId);

    if (vendor == null) {
      return const EmptyState(
        emoji: '🤷',
        title: 'Vendor unavailable',
        message: 'This stall is no longer listed.',
      );
    }

    final reviews = AppScope.reviewsOf(context);
    final heroHeight = context.isShortViewport ? 132.0 : 190.0;

    return CustomScrollView(
      key: PageStorageKey('detail-${widget.vendorId}'),
      slivers: [
        _DetailHero(
          vendor: vendor,
          height: heroHeight,
          showBackButton: widget.showBackButton,
        ),
        SliverToBoxAdapter(child: _InfoCard(vendor: vendor)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: QueueMeter(vendor: vendor),
          ),
        ),
        const SliverToBoxAdapter(child: Divider()),
        SliverToBoxAdapter(
          child: ListenableBuilder(
            listenable: reviews,
            builder: (context, _) {
              final available = reviews.periodsWithReviews(vendor.id);
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews (${reviews.countFor(vendor.id)})',
                      style: AppTextStyles.sectionHeader,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Sits directly above the first review card, the position
                    // adopted after testing showed participants read past a
                    // filter placed under the section heading.
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilterChipButton(
                          label: 'All',
                          selected: _mealFilter == null,
                          onPressed: () => setState(() => _mealFilter = null),
                        ),
                        for (final period in MealPeriod.values)
                          if (available.contains(period))
                            FilterChipButton(
                              label: period.label,
                              selected: _mealFilter == period,
                              onPressed: () => setState(
                                () => _mealFilter = _mealFilter == period
                                    ? null
                                    : period,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ListenableBuilder(
          listenable: reviews,
          builder: (context, _) {
            final visible = reviews.forVendor(
              vendor.id,
              mealPeriod: _mealFilter,
            );
            if (visible.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: EmptyState(
                    emoji: '💬',
                    title: 'No reviews for that meal yet',
                    message: 'Be the first to leave one.',
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    ReviewCard(review: visible[index]),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: PrimaryCta(
              label: 'Write a Review',
              icon: Icons.add_rounded,
              onPressed: () => showWriteReviewSheet(
                context,
                vendorId: vendor.id,
                vendorName: vendor.name,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.vendor,
    required this.height,
    required this.showBackButton,
  });

  final Vendor vendor;
  final double height;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final saved = AppScope.savedOf(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: height,
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      actions: [
        ListenableBuilder(
          listenable: saved,
          builder: (context, _) {
            final isSaved = saved.isSaved(vendor.id);
            return IconButton(
              onPressed: () => saved.toggle(vendor.id),
              tooltip: isSaved ? 'Remove from saved' : 'Save this stall',
              icon: Icon(
                isSaved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isSaved ? AppColors.primary : Colors.white,
              ),
            );
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.accent,
          alignment: Alignment.center,
          child: Text(
            vendor.emoji,
            style: const TextStyle(fontSize: 56),
            semanticsLabel: '',
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.catalogOf(context);
    final clock = AppScope.clockOf(context);
    final distance = formatDistance(vendor.distanceFrom(catalog.origin));

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vendor.name, style: AppTextStyles.vendorNameLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${vendor.cuisineLabel} · ${vendor.suburb}',
            style: AppTextStyles.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          StatusBadge(
            hours: vendor.hours,
            size: StatusBadgeSize.large,
            showChangeLabel: true,
          ),
          if (vendor.blurb.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(vendor.blurb, style: AppTextStyles.body),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RatingStars(rating: vendor.rating, size: 16),
              Text(
                '${vendor.reviewCount} reviews',
                style: AppTextStyles.secondary,
              ),
              Text('$distance away', style: AppTextStyles.secondary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ListenableBuilder(
            listenable: clock,
            builder: (context, _) => Text(
              'Listing updated '
              '${formatRelativeTime(vendor.lastUpdatedAt, now: clock.now)} '
              'by the vendor',
              style: AppTextStyles.secondary.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
