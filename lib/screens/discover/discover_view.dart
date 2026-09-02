import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../app/app_scope.dart';
import '../../domain/food_category.dart';
import '../../domain/vendor.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/search_field.dart';
import '../../widgets/vendor_card.dart';
import '../../widgets/wordmark.dart';

/// The Discover content.
///
/// Deliberately owns no `Scaffold` and calls no `Navigator` itself — selection
/// is reported through [onVendorSelected]. That is what lets the tablet
/// two-pane layout embed this beside a detail pane without changes.
class DiscoverView extends StatelessWidget {
  const DiscoverView({
    super.key,
    required this.onVendorSelected,
    this.selectedVendorId,
  });

  final ValueChanged<Vendor> onVendorSelected;
  final String? selectedVendorId;

  Future<void> _openSearchFilter(BuildContext context) async {
    final catalog = AppScope.catalogOf(context);
    final result = await AppRouter.openSearchFilter(context, catalog.query);
    if (result != null) catalog.applyQuery(result);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.catalogOf(context);

    return ListenableBuilder(
      listenable: catalog,
      builder: (context, _) {
        final vendors = catalog.visibleVendors;
        final query = catalog.query;
        final activeCategory = query.categories.isEmpty
            ? null
            : query.categories.first;

        return CustomScrollView(
          key: const PageStorageKey('discover-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DiscoverHeader(),
                    const SizedBox(height: AppSpacing.md),
                    SearchField(
                      readOnly: true,
                      onTap: () => _openSearchFilter(context),
                      activeFilterCount: query.activeFilterCount,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      header: true,
                      child: Text(
                        'What are you craving?',
                        style: AppTextStyles.sectionHeader,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryChipRow(
                active: activeCategory,
                onSelect: catalog.selectCategory,
                onMore: () => _openSearchFilter(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: SectionHeader(
                  title: query.isDefault
                      ? 'Near you'
                      : '${vendors.length} '
                            '${vendors.length == 1 ? 'result' : 'results'}',
                  actionLabel: query.isDefault ? null : 'Clear',
                  onAction: query.isDefault ? null : catalog.clearFilters,
                ),
              ),
            ),
            if (vendors.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: 'No stalls match those filters',
                  message:
                      'Try widening the distance, or clearing the food type.',
                  actionLabel: 'Clear filters',
                  onAction: catalog.clearFilters,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverList.separated(
                  itemCount: vendors.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return VendorCard(
                      vendor: vendor,
                      selected: vendor.id == selectedVendorId,
                      onTap: () => onVendorSelected(vendor),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wordmark(),
              SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 14,
                    color: AppColors.inkSecondary,
                  ),
                  SizedBox(width: AppSpacing.xxs),
                  // Flexible: the icon is a fixed 14dp but the label scales.
                  Flexible(
                    child: Text(
                      'Sydney CBD',
                      style: AppTextStyles.secondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.hairline),
          ),
          child: ExcludeSemantics(
            child: Text('Hi 👋', style: AppTextStyles.chipLabel),
          ),
        ),
      ],
    );
  }
}

class _CategoryChipRow extends StatelessWidget {
  const _CategoryChipRow({
    required this.active,
    required this.onSelect,
    required this.onMore,
  });

  final FoodCategory? active;
  final ValueChanged<FoodCategory?> onSelect;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          FilterChipButton(
            label: 'All',
            selected: active == null,
            onPressed: () => onSelect(null),
          ),
          for (final category in FoodCategory.homeRow) ...[
            const SizedBox(width: AppSpacing.sm),
            FilterChipButton(
              label: category.label,
              leadingEmoji: category.emoji,
              selected: active == category,
              onPressed: () => onSelect(active == category ? null : category),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          // Routes to Search & Filter rather than being an inert chip.
          FilterChipButton(
            label: 'More',
            selected: false,
            trailingIcon: Icons.add_rounded,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}
