import 'package:flutter/foundation.dart';

/// Bookmarked vendors.
///
/// In-memory only: persisting across launches would need a storage plugin,
/// which is out of scope for a front-end build and is listed in the report as
/// remaining work.
class SavedController extends ChangeNotifier {
  SavedController({Set<String>? initial}) : _savedIds = {...?initial};

  final Set<String> _savedIds;

  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  int get count => _savedIds.length;

  bool isSaved(String vendorId) => _savedIds.contains(vendorId);

  void toggle(String vendorId) {
    if (!_savedIds.remove(vendorId)) _savedIds.add(vendorId);
    notifyListeners();
  }
}
