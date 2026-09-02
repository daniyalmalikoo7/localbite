import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Star row with an optional numeric value.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.showValue = true,
    this.starCount = 1,
  });

  final double rating;
  final double size;
  final bool showValue;

  /// 1 renders a single star beside the number (compact card style); 5 renders
  /// a full row (review style).
  final int starCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${rating.toStringAsFixed(1)} out of 5 stars',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < starCount; i++)
            Icon(
              starCount == 1
                  ? Icons.star_rounded
                  : (i < rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded),
              size: size,
              color: AppColors.primary,
            ),
          if (showValue) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              rating.toStringAsFixed(1),
              style: AppTextStyles.vendorName.copyWith(
                color: AppColors.primaryStrong,
                fontSize: size,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
