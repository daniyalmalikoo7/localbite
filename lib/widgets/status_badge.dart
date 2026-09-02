import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../domain/opening_hours.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum StatusBadgeSize { small, large }

/// Live OPEN/CLOSED pill.
///
/// Takes [OpeningHours] rather than a precomputed boolean on purpose: every
/// caller is forced onto the ticking path, so it is not possible to render a
/// status that has gone stale.
///
/// Subscribes to the shared clock itself, which is why a minute tick repaints
/// only these pills and not the screens containing them.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.hours,
    this.size = StatusBadgeSize.small,
    this.showChangeLabel = false,
  });

  final OpeningHours hours;
  final StatusBadgeSize size;

  /// Appends "· Closes 9 PM" beside the pill.
  final bool showChangeLabel;

  @override
  Widget build(BuildContext context) {
    final clock = AppScope.clockOf(context);

    return ListenableBuilder(
      listenable: clock,
      builder: (context, _) {
        final now = clock.now;
        final status = hours.statusAt(now);
        final isOpen = status.isOpen;
        final word = isOpen ? 'OPEN' : 'CLOSED';
        final changeLabel = status.label(now: now);

        final pill = Container(
          padding: EdgeInsets.symmetric(
            horizontal: size == StatusBadgeSize.large
                ? AppSpacing.sm
                : AppSpacing.xs + 2,
            vertical: AppSpacing.xxs + 1,
          ),
          decoration: BoxDecoration(
            color: isOpen
                ? AppColors.statusOpenSurface
                : AppColors.statusClosedSurface,
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Text(
            word,
            style: AppTextStyles.badge.copyWith(
              color: isOpen ? AppColors.statusOpen : AppColors.statusClosed,
              fontSize: size == StatusBadgeSize.large ? 12 : 11,
            ),
          ),
        );

        return Semantics(
          // The word is always present, so status is never colour-only.
          label: '$word. $changeLabel',
          excludeSemantics: true,
          child: showChangeLabel
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    pill,
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        '· $changeLabel',
                        style: AppTextStyles.secondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : pill,
        );
      },
    );
  }
}
