import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Shown when a filter combination matches nothing, or a list is empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.emoji = '🔍',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String emoji;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final action = actionLabel;
    // Scrollable: on the Map and Profile tabs this sits inside an Expanded,
    // which cannot scroll, so at large text scales the body was unreachable.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.sectionHeader,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.secondary,
              textAlign: TextAlign.center,
            ),
            if (action != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryStrong,
                  minimumSize: const Size(0, AppSizes.minTapTarget),
                ),
                child: Text(action),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
