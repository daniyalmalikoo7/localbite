import 'dart:async';

import 'package:flutter/foundation.dart';

/// The app's shared sense of "now".
///
/// Ticks on the minute boundary rather than every second: nothing in the UI
/// displays seconds, so a one-second timer would cost sixty times the rebuilds
/// for no visible difference.
///
/// Widgets that show time-derived content subscribe to this directly, which is
/// what lets a tick repaint the open/closed badges on Home, Saved and Vendor
/// Detail simultaneously without any screen-to-screen wiring.
class ClockController extends ChangeNotifier {
  ClockController({DateTime Function()? now})
    : _readClock = now ?? DateTime.now {
    _current = _readClock();
  }

  final DateTime Function() _readClock;
  late DateTime _current;
  Timer? _timer;

  DateTime get now => _current;

  /// Aligns to the next minute boundary, then ticks every minute.
  void start() {
    _timer?.cancel();
    final time = _readClock();
    final untilNextMinute = Duration(
      seconds: 60 - time.second,
      milliseconds: -time.millisecond,
    );
    _timer = Timer(untilNextMinute, () {
      _tick();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
    });
  }

  /// Test seam: move the clock without waiting on a real timer.
  @visibleForTesting
  void setNow(DateTime value) {
    _current = value;
    notifyListeners();
  }

  void _tick() {
    final next = _readClock();
    if (next.hour == _current.hour && next.minute == _current.minute) return;
    _current = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
