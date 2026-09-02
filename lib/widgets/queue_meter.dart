import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../domain/queue_estimate.dart';
import '../domain/vendor.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Live queue estimate. Shares the clock with [StatusBadge], so it moves on
/// the same tick without any extra plumbing.
class QueueMeter extends StatelessWidget {
  const QueueMeter({super.key, required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final clock = AppScope.clockOf(context);

    return ListenableBuilder(
      listenable: clock,
      builder: (context, _) {
        final wait = estimatedWaitMinutes(vendor, clock.now);
        final isOpen = vendor.statusAt(clock.now).isOpen;

        return Semantics(
          label: isOpen
              ? 'Live queue, about $wait minutes wait'
              : 'Live queue unavailable while closed',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Live Queue', style: AppTextStyles.sectionHeader),
                  const Spacer(),
                  Text(
                    isOpen ? '~$wait min wait' : 'Closed',
                    style: AppTextStyles.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.tag),
                child: TweenAnimationBuilder<double>(
                  duration: AppDuration.normal,
                  curve: Curves.easeOut,
                  tween: Tween(end: isOpen ? queueFraction(wait) : 0.0),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: AppSizes.queueBarHeight,
                    backgroundColor: AppColors.surfaceSunken,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
