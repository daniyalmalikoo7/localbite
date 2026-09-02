import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/wordmark.dart';

/// Planned, not built. Accounts require a backend, which is outside the scope
/// of a front-end assessment.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              emoji: '👤',
              title: 'Profiles need an account system',
              message:
                  'Sign-in, saved preferences and vendor self-management all '
                  'depend on a backend. This build covers the front end only.',
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
