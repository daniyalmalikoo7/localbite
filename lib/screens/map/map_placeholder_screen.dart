import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/wordmark.dart';

/// Planned, not built. Shown honestly rather than left as a tab that does
/// nothing when tapped.
class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Wordmark(),
          ),
          const Divider(),
          Expanded(
            child: EmptyState(
              emoji: '🗺️',
              title: 'Map view is coming next',
              message:
                  'Stalls move. A live map was the most requested addition in '
                  'user testing, and is the next thing to be built after this '
                  'front end.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Not implemented in this build.',
              style: AppTextStyles.secondary,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
