import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'vendor_detail_view.dart';

/// Route wrapper around [VendorDetailView] for the phone push navigation.
class VendorDetailScreen extends StatelessWidget {
  const VendorDetailScreen({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: VendorDetailView(vendorId: vendorId),
    );
  }
}
