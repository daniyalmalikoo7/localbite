import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// "Local" in brand orange, "Bite" in deep green.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 22});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.wordmark.copyWith(fontSize: fontSize);
    return Semantics(
      header: true,
      label: 'LocalBite',
      excludeSemantics: true,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Local',
              style: style.copyWith(color: AppColors.primary),
            ),
            TextSpan(
              text: 'Bite',
              style: style.copyWith(color: AppColors.accent),
            ),
          ],
        ),
        textScaler: MediaQuery.textScalerOf(context),
      ),
    );
  }
}
