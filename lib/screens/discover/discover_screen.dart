import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import '../../theme/motion.dart';
import '../../widgets/empty_state.dart';
import '../vendor_detail/vendor_detail_view.dart';
import 'discover_view.dart';

/// Discover tab. Pushes a detail route on phones; shows the detail beside the
/// list once the window is wide enough for two panes.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String? _selectedVendorId;

  @override
  Widget build(BuildContext context) {
    if (!context.usesTwoPane) {
      return SafeArea(
        child: DiscoverView(
          onVendorSelected: (vendor) =>
              AppRouter.openVendor(context, vendor.id),
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
            child: DiscoverView(
              selectedVendorId: selectedId,
              onVendorSelected: (vendor) =>
                  setState(() => _selectedVendorId = vendor.id),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: context.motion(const Duration(milliseconds: 200)),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: selectedId == null
                  ? const EmptyState(
                      key: ValueKey('empty'),
                      emoji: '👈',
                      title: 'Pick a stall',
                      message:
                          'Choose one from the list to see hours, the live '
                          'queue and reviews.',
                    )
                  : Container(
                      key: ValueKey(selectedId),
                      color: AppColors.background,
                      child: VendorDetailView(
                        vendorId: selectedId,
                        showBackButton: false,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
