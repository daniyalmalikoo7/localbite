import 'package:flutter/foundation.dart';

import 'time_format.dart';

/// Whether a vendor is trading right now, and when that next changes.
///
/// Always derived from opening hours and the current time — never stored — so
/// the badge cannot go stale.
@immutable
class VendorStatus {
  const VendorStatus._({required this.isOpen, this.changeAt});

  const VendorStatus.open(DateTime closesAt)
    : this._(isOpen: true, changeAt: closesAt);

  const VendorStatus.closed(DateTime opensAt)
    : this._(isOpen: false, changeAt: opensAt);

  /// No trading hours on record for the next seven days.
  const VendorStatus.indefinitelyClosed() : this._(isOpen: false);

  final bool isOpen;

  /// When the vendor next opens or closes. Null only when indefinitely closed.
  final DateTime? changeAt;

  /// "Closes 9 PM", "Opens 11 AM", "Opens tomorrow 7 AM", "Opens Mon 7 AM".
  String label({required DateTime now}) {
    final change = changeAt;
    if (change == null) return 'Closed';

    final time = formatClockTime(change);
    if (isOpen) return 'Closes $time';

    final today = DateTime(now.year, now.month, now.day);
    final changeDay = DateTime(change.year, change.month, change.day);
    final daysAhead = changeDay.difference(today).inDays;

    return switch (daysAhead) {
      <= 0 => 'Opens $time',
      1 => 'Opens tomorrow $time',
      _ => 'Opens ${formatWeekday(change.weekday)} $time',
    };
  }

  @override
  bool operator ==(Object other) =>
      other is VendorStatus &&
      other.isOpen == isOpen &&
      other.changeAt == changeAt;

  @override
  int get hashCode => Object.hash(isOpen, changeAt);
}
