import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';

/// A slow opacity pulse, so a loading list reads as busy rather than frozen.
/// Holds still entirely when the user has asked for reduced motion.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.prefersReducedMotion) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(
      begin: 0.45,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
    child: widget.child,
  );
}

/// A single grey placeholder block.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = AppRadius.tag,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.surfaceSunken,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Placeholder in the shape of a vendor card, so the list does not reflow when
/// the real content lands.
class VendorCardSkeleton extends StatelessWidget {
  const VendorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        constraints: const BoxConstraints(
          minHeight: AppSizes.vendorCardMinHeight,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(
              width: AppSizes.thumbnail,
              height: AppSizes.thumbnail,
              radius: AppRadius.card - 2,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 150, height: 14),
                  const SizedBox(height: AppSpacing.sm),
                  const SkeletonBox(width: 110, height: 11),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: const [
                      SkeletonBox(
                        width: 52,
                        height: 18,
                        radius: AppRadius.badge,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      SkeletonBox(width: 80, height: 11),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of [VendorCardSkeleton]s under a single pulse.
class VendorListSkeleton extends StatelessWidget {
  const VendorListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
    child: Semantics(
      label: 'Loading stalls',
      liveRegion: true,
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            const VendorCardSkeleton(),
          ],
        ],
      ),
    ),
  );
}

/// Placeholder in the shape of the Vendor Detail screen.
class VendorDetailSkeleton extends StatelessWidget {
  const VendorDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SkeletonPulse(
    child: Semantics(
      label: 'Loading stall details',
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 190, color: AppColors.surfaceSunken),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 200, height: 22),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(width: 260, height: 12),
                SizedBox(height: AppSpacing.lg),
                SkeletonBox(width: 120, height: 18, radius: AppRadius.badge),
                SizedBox(height: AppSpacing.xl),
                SkeletonBox(width: double.infinity, height: 8),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
