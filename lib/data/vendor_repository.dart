import '../domain/review.dart';
import '../domain/vendor.dart';
import 'repository_exception.dart';
import 'seed_data.dart';

/// Source of vendor and review data.
///
/// Asynchronous even though this build reads from memory. A real listing
/// service is a network call, and an interface that pretends otherwise pushes
/// every caller into a shape that cannot express waiting or failing — which is
/// how apps end up with no loading or error states at all.
abstract interface class VendorRepository {
  Future<List<Vendor>> loadVendors();
  Future<List<Review>> loadReviews();

  /// Persists a review. Throws [RepositoryException] if it cannot.
  Future<void> submitReview(Review review);
}

class InMemoryVendorRepository implements VendorRepository {
  InMemoryVendorRepository({
    DateTime? seededAt,
    this.latency = const Duration(milliseconds: 700),
    this.failLoads = false,
  }) : _seededAt = seededAt ?? DateTime.now();

  final DateTime _seededAt;

  /// Stands in for network round-trip time. Tests pass [Duration.zero].
  final Duration latency;

  /// Makes every load fail, so the error and retry paths are exercisable.
  final bool failLoads;

  @override
  Future<List<Vendor>> loadVendors() async {
    await _simulateRequest();
    return List.unmodifiable(buildSeedVendors(_seededAt));
  }

  @override
  Future<List<Review>> loadReviews() async {
    await _simulateRequest();
    return List.unmodifiable(buildSeedReviews(_seededAt));
  }

  @override
  Future<void> submitReview(Review review) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (failLoads) {
      throw const RepositoryException(
        "Your review couldn't be posted. It has been kept — try again.",
      );
    }
  }

  Future<void> _simulateRequest() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (failLoads) {
      throw const RepositoryException(
        "Couldn't reach the vendor listings. Check your connection and try "
        'again.',
      );
    }
  }
}
