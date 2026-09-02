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
    return Semantics(
      textField: !readOnly,
      button: readOnly,
      label: readOnly ? 'Search and filter stalls' : null,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        style: AppTextStyles.body,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
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
