import '../domain/review.dart';
import '../domain/vendor.dart';
import 'seed_data.dart';

/// Source of vendor and review data.
///
/// The interface exists so the in-memory seed can be swapped for a real
/// backend without touching the UI. Calls are synchronous: this build has no
/// network, and returning futures would only manufacture loading states that
/// exercise nothing.
abstract interface class VendorRepository {
  List<Vendor> loadVendors();
  List<Review> loadReviews();
}

class InMemoryVendorRepository implements VendorRepository {
  InMemoryVendorRepository({DateTime? seededAt})
    : _seededAt = seededAt ?? DateTime.now();

  final DateTime _seededAt;

  @override
  List<Vendor> loadVendors() => List.unmodifiable(buildSeedVendors(_seededAt));

  @override
  List<Review> loadReviews() => List.unmodifiable(buildSeedReviews(_seededAt));
}
