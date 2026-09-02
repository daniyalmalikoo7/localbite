import 'package:flutter/material.dart';

import '../domain/vendor_query.dart';
import '../screens/root_shell.dart';
import '../screens/search_filter/search_filter_screen.dart';
import '../screens/vendor_detail/vendor_detail_screen.dart';

@immutable
class VendorDetailArgs {
  const VendorDetailArgs(this.vendorId);
  final String vendorId;
}

@immutable
class SearchFilterArgs {
  const SearchFilterArgs(this.initialQuery);
  final VendorQuery initialQuery;
}

/// Named routes plus typed helpers.
///
/// Four screens at one push depth do not justify a routing package; a single
/// route table is also easier to point at as evidence that the pages link
/// together correctly. The typed helpers keep argument casting out of widgets.
abstract final class AppRouter {
  static const shell = '/';
  static const vendorDetail = '/vendor';
  static const searchFilter = '/search';

  static Route<Object?>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute<void>(
          builder: (_) => const RootShell(),
          settings: settings,
        );
      case vendorDetail:
        final args = settings.arguments;
        if (args is! VendorDetailArgs) return null;
        return MaterialPageRoute<void>(
          builder: (_) => VendorDetailScreen(vendorId: args.vendorId),
          settings: settings,
        );
      case searchFilter:
        final args = settings.arguments;
        if (args is! SearchFilterArgs) return null;
        return MaterialPageRoute<VendorQuery>(
          builder: (_) => SearchFilterScreen(initialQuery: args.initialQuery),
          settings: settings,
        );
      default:
        return null;
    }
  }

  /// Passes the id rather than the vendor object, so the detail screen always
  /// reads current state — a review added while it is open shows immediately.
  static Future<void> openVendor(BuildContext context, String vendorId) =>
      Navigator.of(context)
          .pushNamed(vendorDetail, arguments: VendorDetailArgs(vendorId));

  static Future<VendorQuery?> openSearchFilter(
    BuildContext context,
    VendorQuery current,
  ) => Navigator.of(
    context,
  ).pushNamed<VendorQuery>(searchFilter, arguments: SearchFilterArgs(current));
}
