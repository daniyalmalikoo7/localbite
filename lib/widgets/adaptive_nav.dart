import 'package:flutter/material.dart';

import '../app/app_tab.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';

/// Bottom bar on phones, side rail on tablets.
///
/// The one-handed constraint that puts navigation at the bottom is a phone
/// constraint; on a 1024pt tablet the same controls are better placed in a
/// rail, where they stay reachable without stretching a phone layout.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.current,
    required this.onSelected,
    required this.body,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (context.usesTwoPane) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: current.index,
              onDestinationSelected: (index) =>
                  onSelected(AppTab.values[index]),
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primary.withValues(alpha: 0.14),
              selectedIconTheme: const IconThemeData(
                color: AppColors.primaryStrong,
              ),
              selectedLabelTextStyle: AppTextStyles.chipLabel.copyWith(
                color: AppColors.primaryStrong,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: AppTextStyles.chipLabel.copyWith(
                color: AppColors.inkSecondary,
              ),
              destinations: [
                for (final tab in AppTab.values)
                  NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.activeIcon),
                    label: Text(tab.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: LocalBiteBottomNav(
        current: current,
        onSelected: onSelected,
      ),
    );
  }
}

/// Four tabs with an orange underline marking the active one.
class LocalBiteBottomNav extends StatelessWidget {
  const LocalBiteBottomNav({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.bottomNavMinHeight,
          ),
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    selected: tab == current,
                    onTap: () => onSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryStrong : AppColors.inkSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? tab.activeIcon : tab.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tab.label,
                style: AppTextStyles.tag.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              AnimatedContainer(
                duration: AppDuration.fast,
                height: 2,
                width: selected ? 32 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
