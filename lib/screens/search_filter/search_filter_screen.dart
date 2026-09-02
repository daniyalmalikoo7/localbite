import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../domain/food_category.dart';
import '../../domain/meal_period.dart';
import '../../domain/vendor_query.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/filter_chip_button.dart';
import '../../widgets/primary_cta.dart';
import '../../widgets/search_field.dart';

/// All five filter dimensions on one screen.
///
/// Edits a *draft* query and returns it through `Navigator.pop`, so backing out
/// leaves the Home results untouched. The result count updates live as chips
/// are toggled, which is what makes "Show Results (N)" honest.
///
/// The bottom navigation from the prototype is intentionally absent here: this
/// is a focused route pushed above the tab shell, and rendering a nav bar that
/// could not switch tabs would be a control that does nothing.
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key, required this.initialQuery});

  final VendorQuery initialQuery;

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late VendorQuery _draft = widget.initialQuery;
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialQuery.searchTerm,
  );

  /// null represents "5 km+", i.e. no distance limit.
  static const _distanceOptions = <(String, int?)>[
    ('500 m', 500),
    ('1 km', 1000),
    ('2 km', 2000),
    ('5 km+', null),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _update(VendorQuery next) => setState(() => _draft = next);

  /// Clears the field as well as the draft. Resetting only the query would
  /// leave the search box showing text that is no longer being applied.
  void _reset() {
    _searchController.clear();
    _update(VendorQuery.empty);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.catalogOf(context);
    final clock = AppScope.clockOf(context);
    final matchCount = _draft
        .applyTo(catalog.allVendors, now: clock.now, origin: catalog.origin)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text('Search & Filter', style: AppTextStyles.sectionHeader),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
        ),
        actions: [
          TextButton(
            onPressed: _draft.isDefault ? null : _reset,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryStrong,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            SearchField(
              controller: _searchController,
              onChanged: (value) => _update(_draft.copyWith(searchTerm: value)),
            ),
            _ChipSection(
              title: 'Food Type',
              children: [
                FilterChipButton(
                  label: 'All',
                  selected: _draft.categories.isEmpty,
                  onPressed: () =>
                      _update(_draft.copyWith(categories: const {})),
                ),
                for (final category in FoodCategory.values)
                  FilterChipButton(
                    label: category.label,
                    leadingEmoji: category.emoji,
                    selected: _draft.categories.contains(category),
                    onPressed: () {
                      final next = {..._draft.categories};
                      if (!next.remove(category)) next.add(category);
                      _update(_draft.copyWith(categories: next));
                    },
                  ),
              ],
            ),
            _ChipSection(
              title: 'Distance',
              children: [
                for (final (label, metres) in _distanceOptions)
                  FilterChipButton(
                    label: label,
                    selected: _draft.maxDistanceMetres == metres,
                    onPressed: () => _update(
                      metres == null
                          ? _draft.copyWith(clearMaxDistance: true)
                          : _draft.copyWith(maxDistanceMetres: metres),
                    ),
                  ),
              ],
            ),
            _ChipSection(
              title: 'Status',
              children: [
                FilterChipButton(
                  label: 'Open now',
                  selected: _draft.openNowOnly,
                  onPressed: () => _update(_draft.copyWith(openNowOnly: true)),
                ),
                FilterChipButton(
                  label: 'All',
                  selected: !_draft.openNowOnly,
                  onPressed: () => _update(_draft.copyWith(openNowOnly: false)),
                ),
              ],
            ),
            _ChipSection(
              title: 'Sort by',
              children: [
                for (final sort in VendorSort.values)
                  FilterChipButton(
                    label: sort.label,
                    selected: _draft.sort == sort,
                    onPressed: () => _update(_draft.copyWith(sort: sort)),
                  ),
              ],
            ),
            _ChipSection(
              title: 'Time of day',
              subtitle: 'Stalls trading during that meal window',
              children: [
                FilterChipButton(
                  label: 'Any',
                  selected: _draft.mealPeriod == null,
                  onPressed: () =>
                      _update(_draft.copyWith(clearMealPeriod: true)),
                ),
                for (final period in MealPeriod.values)
                  FilterChipButton(
                    label: period.label,
                    selected: _draft.mealPeriod == period,
                    onPressed: () =>
                        _update(_draft.copyWith(mealPeriod: period)),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryCta(
              label: matchCount == 0
                  ? 'No matching stalls'
                  : 'Show Results ($matchCount)',
              onPressed: matchCount == 0
                  ? null
                  : () => Navigator.of(context).pop(_draft),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionHeader),
          if (sub != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(sub, style: AppTextStyles.secondary),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: children,
          ),
        ],
      ),
    );
  }
}
