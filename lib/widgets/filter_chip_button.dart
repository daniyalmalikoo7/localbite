import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// The chip used on the Home filter row, the Search & Filter sections and the
/// review meal-period filter.
///
/// Height is a minimum rather than a fixed 32dp so the label still fits when
/// the system text size is turned up.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.leadingEmoji,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final String? leadingEmoji;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final emoji = leadingEmoji;
    final icon = trailingIcon;

    return Semantics(
      button: true,
      selected: selected,
      // Without an onTap here the surrounding excludeSemantics strips the
      // InkWell's tap action, leaving a control that Switch Access and Voice
      // Control cannot activate at all.
      onTap: onPressed,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        // The pill stays 32dp tall for visual density; the tappable area is
        // padded out to the 48dp minimum.
        constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: selected ? AppColors.primaryStrong : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              child: AnimatedContainer(
                duration: AppDuration.fast,
                constraints: const BoxConstraints(
                  minHeight: AppSizes.chipMinHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm - 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryStrong
                        : AppColors.hairline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (emoji != null) ...[
                      Text(emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: AppSpacing.xs + 2),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.chipLabel.copyWith(
                        color: selected ? Colors.white : AppColors.ink,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        icon,
                        size: 14,
                        color: selected ? Colors.white : AppColors.inkSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
