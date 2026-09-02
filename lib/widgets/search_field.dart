import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Search input. Used live on Search & Filter, and as a tappable shortcut on
/// Home where tapping opens the filter screen rather than a keyboard.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.hintText = 'Search for food or vendor...',
    this.activeFilterCount = 0,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final String hintText;

  /// Renders a count bubble on the filter icon when filters are active.
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    // The read-only variant on Discover is a shortcut into the filter screen,
    // not an editable field. Announcing it as a text box gave it two
    // contradictory roles and no activation action.
    if (readOnly) {
      return Semantics(
        button: true,
        onTap: onTap,
        label: 'Search and filter stalls',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.inkSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    hintText,
                    style: AppTextStyles.secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (activeFilterCount > 0)
                  _FilterCountBubble(count: activeFilterCount),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        style: AppTextStyles.body,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          // A hint stops being the accessible name once the user types.
          labelText: 'Search food or vendors',
          hintText: hintText,
          hintStyle: AppTextStyles.secondary,
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.inkSecondary,
          ),
          suffixIcon: activeFilterCount > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _FilterCountBubble(count: activeFilterCount),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
          border: _border(AppColors.hairline),
          enabledBorder: _border(AppColors.hairline),
          focusedBorder: _border(AppColors.primaryStrong, width: 1.6),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.chip)),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _FilterCountBubble extends StatelessWidget {
  const _FilterCountBubble({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count filters active',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 1,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryStrong,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '$count',
          style: AppTextStyles.tag.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
