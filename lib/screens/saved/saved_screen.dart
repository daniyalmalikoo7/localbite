import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../app/app_scope.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/vendor_card.dart';
import '../../widgets/wordmark.dart';
import '../vendor_detail/vendor_detail_view.dart';

/// Saved tab. Reuses the Home card with a filled heart in place of the
/// chevron, and shows each stall's live trading status.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String? _selectedVendorId;

  @override
  Widget build(BuildContext context) {
    if (!context.usesTwoPane) {
      return SafeArea(
        child: _SavedList(
          onVendorSelected: (id) => AppRouter.openVendor(context, id),
        ),
      );
    }

    final selectedId = _selectedVendorId;
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 400,
            child: _SavedList(
              selectedVendorId: selectedId,
              onVendorSelected: (id) => setState(() => _selectedVendorId = id),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedId == null
                ? const EmptyState(
                    emoji: '👈',
                    title: 'Pick a saved stall',
                    message: 'Choose one from the list to see its details.',
                  )
                : Container(
                    color: AppColors.background,
                    child: VendorDetailView(
                      vendorId: selectedId,
                      showBackButton: false,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SavedList extends StatelessWidget {
  const _SavedList({required this.onVendorSelected, this.selectedVendorId});

  final ValueChanged<String> onVendorSelected;
  final String? selectedVendorId;

  @override
  Widget build(BuildContext context) {
    final saved = AppScope.savedOf(context);
    final catalog = AppScope.catalogOf(context);

    return ListenableBuilder(
      listenable: saved,
      builder: (context, _) {
        final vendors = catalog.vendorsByIds(saved.savedIds);

        return CustomScrollView(
          key: const PageStorageKey('saved-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wordmark(),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Saved Vendors', style: AppTextStyles.screenTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      vendors.isEmpty
                          ? 'No saved spots yet'
                          : '${vendors.length} saved '
                                '${vendors.length == 1 ? 'spot' : 'spots'}',
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ),
              ),
            ),
            if (vendors.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  emoji: '🤍',
                  title: 'Nothing saved yet',
                  message:
                      'Tap the heart on a stall to keep it here, with its '
                      'opening status kept up to date.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverList.separated(
                  itemCount: vendors.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return VendorCard(
                      vendor: vendor,
                      selected: vendor.id == selectedVendorId,
                      onTap: () => onVendorSelected(vendor.id),
                      trailing: _SaveHeartButton(vendorId: vendor.id),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SaveHeartButton extends StatelessWidget {
  const _SaveHeartButton({required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context) {
    final saved = AppScope.savedOf(context);
    return IconButton(
      onPressed: () => saved.toggle(vendorId),
      iconSize: 20,
      constraints: const BoxConstraints(
        minWidth: AppSizes.minTapTarget,
        minHeight: AppSizes.minTapTarget,
      ),
      tooltip: 'Remove from saved',
      icon: const Icon(Icons.favorite_rounded, color: AppColors.primary),
    );
  }
}
